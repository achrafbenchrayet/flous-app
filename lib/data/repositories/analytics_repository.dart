import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

enum AnalyticsPeriod { today, yesterday, thisWeek, thisMonth, lastMonth, thisYear, custom }

class AnalyticsFilter {
  final AnalyticsPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  const AnalyticsFilter({this.period = AnalyticsPeriod.thisMonth, this.customStartDate, this.customEndDate});
  AnalyticsFilter copyWith({AnalyticsPeriod? period, DateTime? customStartDate, DateTime? customEndDate}) =>
      AnalyticsFilter(period: period ?? this.period, customStartDate: customStartDate ?? this.customStartDate, customEndDate: customEndDate ?? this.customEndDate);
}

class AnalyticsReport {
  final int totalIncome;
  final int totalExpense;
  final int netBalance;
  final int transactionCount;
  final int averageExpense;
  final int maxExpense;
  final double savingsRate;
  final List> monthlyData;
final List> timelineData;
final List> categoryDistribution;
final List> paymentMethodDistribution;

  const AnalyticsReport({
    required this.totalIncome, required this.totalExpense, required this.netBalance,
    required this.transactionCount, required this.averageExpense, required this.maxExpense,
    required this.savingsRate, required this.timelineData, required this.categoryDistribution,
    required this.paymentMethodDistribution,
  });
}

class AnalyticsRepository {
  final AppDatabase _appDb = AppDatabase.instance;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  (DateTime, DateTime) _resolveDates(AnalyticsFilter filter) {
    final now = DateTime.now();
    switch (filter.period) {
      case AnalyticsPeriod.today: return (DateTime(now.year, now.month, now.day), DateTime(now.year, now.month, now.day, 23, 59, 59));
      case AnalyticsPeriod.yesterday:
        final y = now.subtract(const Duration(days: 1));
        return (DateTime(y.year, y.month, y.day), DateTime(y.year, y.month, y.day, 23, 59, 59));
      case AnalyticsPeriod.thisWeek: return (DateTime(now.year, now.month, now.day - (now.weekday - 1)), DateTime(now.year, now.month, now.day, 23, 59, 59));
      case AnalyticsPeriod.thisMonth: return (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0, 23, 59, 59));
      case AnalyticsPeriod.lastMonth: return (DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 0, 23, 59, 59));
      case AnalyticsPeriod.thisYear: return (DateTime(now.year, 1, 1), DateTime(now.year, 12, 31, 23, 59, 59));
      case AnalyticsPeriod.custom: return (filter.customStartDate ?? DateTime(now.year, now.month, 1), filter.customEndDate ?? DateTime(now.year, now.month, now.day, 23, 59, 59));
    }
  }

  Future<AnalyticsReport> generateReport(String userId, AnalyticsFilter filter) async {
    final db = await _appDb.database;
    final (start, end) = _resolveDates(filter);
    final startStr = _dateFormat.format(start);
    final endStr = _dateFormat.format(end);

    final mainResult = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense,
        COALESCE(COUNT(*), 0) AS tx_count,
        COALESCE(AVG(CASE WHEN type = 'expense' THEN amount END), 0) AS avg_expense,
        COALESCE(MAX(CASE WHEN type = 'expense' THEN amount END), 0) AS max_expense
      FROM ${DatabaseTables.tableTransactions}
      WHERE user_id = ? AND date BETWEEN ? AND ?
    ''', [userId, startStr, endStr]);

    final row = mainResult.first;
    final int totalIncome = row['total_income'] as int;
    final int totalExpense = row['total_expense'] as int;
    final int netBalance = totalIncome - totalExpense;
    final int transactionCount = row['tx_count'] as int;
    final int averageExpense = (row['avg_expense'] as num).round();
    final int maxExpense = row['max_expense'] as int;
    final double savingsRate = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100).clamp(0.0, 100.0) : 0.0;

    final catRows = await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) AS total
      FROM ${DatabaseTables.tableTransactions} t
      JOIN ${DatabaseTables.tableCategories} c ON t.category_id = c.id
      WHERE t.user_id = ? AND t.type = 'expense' AND t.date BETWEEN ? AND ?
      GROUP BY c.id ORDER BY total DESC
    ''', [userId, startStr, endStr]);

    final categoryDistribution = catRows.map((r) => {'name': r['name'] as String, 'color': r['color'] as int, 'amount': r['total'] as int}).toList();

    final payRows = await db.rawQuery('''
      SELECT payment_method, SUM(amount) AS total
      FROM ${DatabaseTables.tableTransactions}
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY payment_method ORDER BY total DESC
    ''', [userId, startStr, endStr]);

    final paymentMethodDistribution = payRows.map((r) => {'method': r['payment_method'] as String, 'amount': r['total'] as int}).toList();

    final timelineRows = await db.rawQuery('''
      SELECT date,
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS inc,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS exp
      FROM ${DatabaseTables.tableTransactions}
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY date ORDER BY date ASC
    ''', [userId, startStr, endStr]);

    final timelineData = timelineRows.map((r) => {'date': r['date'] as String, 'income': r['inc'] as int, 'expense': r['exp'] as int}).toList();

    return AnalyticsReport(
      totalIncome: totalIncome, totalExpense: totalExpense, netBalance: netBalance,
      transactionCount: transactionCount, averageExpense: averageExpense, maxExpense: maxExpense,
      savingsRate: savingsRate, timelineData: timelineData, categoryDistribution: categoryDistribution,
      paymentMethodDistribution: paymentMethodDistribution,
    );
  }
}
