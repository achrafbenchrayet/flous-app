import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/transaction_model.dart';

class DashboardData {
  final int totalBalance;
  final int monthIncome;
  final int monthExpense;
  final double savingsRate;
  final String topExpenseCategory;
  final int dailyAverageExpense;
  final List<TransactionModel> recentTransactions;
  final List> last7DaysExpenses;
  final List> categoryDistribution;
  final List> monthlyComparison;

  DashboardData({
    required this.totalBalance,
    required this.monthIncome,
    required this.monthExpense,
    required this.savingsRate,
    required this.topExpenseCategory,
    required this.dailyAverageExpense,
    required this.recentTransactions,
    required this.last7DaysExpenses,
    required this.categoryDistribution,
    required this.monthlyComparison,
  });
}

class DashboardRepository {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<DashboardData> getDashboardData(String userId) async {
    final db = await _appDb.database;
    final now = DateTime.now();
    final currentMonthPrefix = DateFormat('yyyy-MM').format(now);

    final userRes = await db.query(DatabaseTables.tableUsers, columns: ['initial_balance'], where: 'id = ?', whereArgs: [userId]);
    final int initialBalance = userRes.isNotEmpty ? (userRes.first['initial_balance'] as int? ?? 0) : 0;

    final totalsResult = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense
      FROM ${DatabaseTables.tableTransactions}
      WHERE user_id = ?
    ''', [userId]);

    final int globalIncome = totalsResult.first['total_income'] as int;
    final int globalExpense = totalsResult.first['total_expense'] as int;

    final savingsResult = await db.rawQuery('SELECT COALESCE(SUM(current_amount), 0) AS total_saved FROM ${DatabaseTables.tableSavingsGoals} WHERE user_id = ? AND status != \'completed\'', [userId]);
    final int totalSavingsLocked = savingsResult.first['total_saved'] as int;
    final int totalAvailableBalance = (initialBalance + globalIncome) - globalExpense - totalSavingsLocked;

    final monthTotals = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS month_income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS month_expense
      FROM ${DatabaseTables.tableTransactions}
      WHERE user_id = ? AND date LIKE '$currentMonthPrefix%'
    ''', [userId]);

    final int monthIncome = monthTotals.first['month_income'] as int;
    final int monthExpense = monthTotals.first['month_expense'] as int;
    final double savingsRate = monthIncome > 0 ? ((monthIncome - monthExpense) / monthIncome * 100).clamp(0.0, 100.0) : 0.0;
    final int daysPassed = now.day > 0 ? now.day : 1;
    final int dailyAverageExpense = (monthExpense / daysPassed).round();

    final topCatResult = await db.rawQuery('''
      SELECT c.name, SUM(t.amount) AS total
      FROM ${DatabaseTables.tableTransactions} t
      JOIN ${DatabaseTables.tableCategories} c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = 'expense' AND t.date LIKE '$currentMonthPrefix%'
      GROUP BY c.id ORDER BY total DESC LIMIT 1
    ''', [userId]);
    final String topExpenseCategory = topCatResult.isNotEmpty ? (topCatResult.first['name'] as String) : 'Aucune';

    final recentRaw = await db.rawQuery('''
      SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
      FROM ${DatabaseTables.tableTransactions} t
      JOIN ${DatabaseTables.tableCategories} c ON t.category_id = c.id
      WHERE t.user_id = ?
      ORDER BY t.date DESC, t.time DESC LIMIT 10
    ''', [userId]);
    final recentTransactions = recentRaw.map((row) => TransactionModel.fromMap(row)).toList();

    final List> last7Days = [];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dStr = DateFormat('yyyy-MM-dd').format(d);
      final res = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) AS total FROM ${DatabaseTables.tableTransactions} WHERE user_id = ? AND type = \'expense\' AND date = ?', [userId, dStr]);
      last7Days.add({'day': DateFormat('E', 'fr_FR').format(d), 'amount': res.first['total'] as int});
    }

    final catDistRaw = await db.rawQuery('''
      SELECT c.name, c.color, COALESCE(SUM(t.amount), 0) AS total
      FROM ${DatabaseTables.tableTransactions} t
      JOIN ${DatabaseTables.tableCategories} c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = 'expense' AND t.date LIKE '$currentMonthPrefix%'
      GROUP BY c.id ORDER BY total DESC
    ''', [userId]);

    final categoryDistribution = catDistRaw.map((row) => {'name': row['name'] as String, 'color': row['color'] as int, 'amount': row['total'] as int}).toList();

    final List> monthlyComp = [];
    for (int i = 3; i >= 0; i--) {
      final mDate = DateTime(now.year, now.month - i, 1);
      final mStr = DateFormat('yyyy-MM').format(mDate);
      final res = await db.rawQuery('''
        SELECT 
          COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS income,
          COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS expense
        FROM ${DatabaseTables.tableTransactions}
        WHERE user_id = ? AND date LIKE '$mStr%'
      ''', [userId]);
      monthlyComp.add({'month': DateFormat('MMM', 'fr_FR').format(mDate), 'income': res.first['income'] as int, 'expense': res.first['expense'] as int});
    }

    return DashboardData(
      totalBalance: totalAvailableBalance,
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      savingsRate: savingsRate,
      topExpenseCategory: topExpenseCategory,
      dailyAverageExpense: dailyAverageExpense,
      recentTransactions: recentTransactions,
      last7DaysExpenses: last7Days,
      categoryDistribution: categoryDistribution,
      monthlyComparison: monthlyComp,
    );
  }
}
