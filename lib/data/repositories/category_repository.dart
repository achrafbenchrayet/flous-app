import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final AppDatabase _appDb = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<List<CategoryModel>> getCategories(String userId, {String? type}) async {
    final db = await _appDb.database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type);
    }
    final results = await db.query(DatabaseTables.tableCategories, where: whereClause, whereArgs: whereArgs, orderBy: 'name ASC');
    return results.map((e) => CategoryModel.fromMap(e)).toList();
  }

  Future<void> addCategory({
    required String userId, required String name, required String icon,
    required int color, required String type, String? description,
  }) async {
    final db = await _appDb.database;
    await db.insert(DatabaseTables.tableCategories, {
      'id': _uuid.v4(), 'user_id': userId, 'name': name.trim(),
      'description': description?.trim(), 'icon': icon, 'color': color,
      'type': type, 'is_default': 0, 'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateCategory({
    required String id, required String name, required String icon,
    required int color, String? description,
  }) async {
    final db = await _appDb.database;
    await db.update(DatabaseTables.tableCategories, {'name': name.trim(), 'description': description?.trim(), 'icon': icon, 'color': color}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countTransactionsForCategory(String categoryId) async {
    final db = await _appDb.database;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.tableTransactions} WHERE category_id = ?', [categoryId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> deleteCategory(String categoryId, {String? fallbackCategoryId}) async {
    final db = await _appDb.database;
    await db.transaction((txn) async {
      final res = await txn.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.tableTransactions} WHERE category_id = ?', [categoryId]);
      final count = Sqflite.firstIntValue(res) ?? 0;

      if (count > 0) {
        if (fallbackCategoryId == null || fallbackCategoryId.isEmpty) throw Exception('Réaffectation requise.');
        await txn.update(DatabaseTables.tableTransactions, {'category_id': fallbackCategoryId}, where: 'category_id = ?', whereArgs: [categoryId]);
      }
      await txn.delete(DatabaseTables.tableCategories, where: 'id = ?', whereArgs: [categoryId]);
    });
  }
}
