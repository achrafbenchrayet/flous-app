import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final AppDatabase _appDb = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<List<BudgetModel>> getActiveBudgets(String userId) async {
    final db = await _appDb.database;
    final monthPrefix = DateFormat('yyyy-MM').format(DateTime.now());

    final rawBudgets = await db.rawQuery('''
      SELECT b.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
      FROM ${DatabaseTables.tableBudgets} b
      LEFT JOIN ${DatabaseTables.tableCategories} c ON b.category_id = c.id
      WHERE b.user_id = ?
    ''', [userId]);

    final List<BudgetModel> result = [];
    for (final row in rawBudgets) {
      final categoryId = row['category_id'] as String?;
      final spentRes = await db.rawQuery(
        categoryId != null
            ? 'SELECT COALESCE(SUM(amount), 0) AS total FROM ${DatabaseTables.tableTransactions} WHERE user_id = ? AND category_id = ? AND type = \'expense\' AND date LIKE \'$monthPrefix%\''
            : 'SELECT COALESCE(SUM(amount), 0) AS total FROM ${DatabaseTables.tableTransactions} WHERE user_id = ? AND type = \'expense\' AND date LIKE \'$monthPrefix%\'',
        categoryId != null ? [userId, categoryId] : [userId],
      );
      result.add(BudgetModel.fromMap(row, spent: spentRes.first['total'] as int));
    }
    return result;
  }

  Future<void> setBudget({required String userId, String? categoryId, required int amountMillimes}) async {
    final db = await _appDb.database;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
    final endDate = DateTime(now.year, now.month + 1, 0).toIso8601String().substring(0, 10);

    final existing = await db.query(
      DatabaseTables.tableBudgets,
      where: categoryId != null ? 'user_id = ? AND category_id = ?' : 'user_id = ? AND category_id IS NULL',
      whereArgs: categoryId != null ? [userId, categoryId] : [userId],
    );

    if (existing.isNotEmpty) {
      await db.update(DatabaseTables.tableBudgets, {'amount': amountMillimes}, where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      await db.insert(DatabaseTables.tableBudgets, {
        'id': _uuid.v4(), 'user_id': userId, 'category_id': categoryId,
        'amount': amountMillimes, 'period': 'monthly', 'start_date': startDate, 'end_date': endDate,
      });
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    final db = await _appDb.database;
    await db.delete(DatabaseTables.tableBudgets, where: 'id = ?', whereArgs: [budgetId]);
  }
}
