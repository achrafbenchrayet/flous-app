import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/transaction_model.dart';

class TransactionFilterOptions {
  final String? type;
  final String? categoryId;
  final String? paymentMethod;
  final String? searchQuery;
  final String sortBy;

  const TransactionFilterOptions({
    this.type, this.categoryId, this.paymentMethod,
    this.searchQuery, this.sortBy = 'date_desc',
  });

  TransactionFilterOptions copyWith({
    String? type, String? categoryId, String? paymentMethod,
    String? searchQuery, String? sortBy, bool clearType = false,
  }) => TransactionFilterOptions(
    type: clearType ? null : (type ?? this.type),
    categoryId: categoryId ?? this.categoryId,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    searchQuery: searchQuery ?? this.searchQuery,
    sortBy: sortBy ?? this.sortBy,
  );
}

class TransactionRepository {
  final AppDatabase _appDb = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<List<TransactionModel>> getFilteredTransactions(String userId, TransactionFilterOptions options) async {
    final db = await _appDb.database;
    String sql = '''
      SELECT t.*, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
      FROM ${DatabaseTables.tableTransactions} t
      JOIN ${DatabaseTables.tableCategories} c ON t.category_id = c.id
      WHERE t.user_id = ?
    ''';
    final List<dynamic> args = [userId];

    if (options.type != null) { sql += ' AND t.type = ?'; args.add(options.type); }
    if (options.categoryId != null) { sql += ' AND t.category_id = ?'; args.add(options.categoryId); }
    if (options.paymentMethod != null) { sql += ' AND t.payment_method = ?'; args.add(options.paymentMethod); }
    if (options.searchQuery != null && options.searchQuery!.trim().isNotEmpty) {
      sql += ' AND (t.description LIKE ? OR t.note LIKE ?)';
      final q = '%${options.searchQuery!.trim()}%';
      args.addAll([q, q]);
    }
    sql += (options.sortBy == 'date_asc') ? ' ORDER BY t.date ASC, t.time ASC' : ' ORDER BY t.date DESC, t.time DESC';

    final rows = await db.rawQuery(sql, args);
    return rows.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<void> addTransaction({
    required String userId, required String categoryId, required String type,
    required int amountMillimes, required String description, required String date,
    required String time, required String paymentMethod, String? note,
  }) async {
    final db = await _appDb.database;
    await db.insert(DatabaseTables.tableTransactions, {
      'id': _uuid.v4(), 'user_id': userId, 'category_id': categoryId,
      'type': type, 'amount': amountMillimes, 'description': description.trim(),
      'date': date, 'time': time, 'payment_method': paymentMethod,
      'note': note?.trim(), 'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateTransaction({
    required String id, required String categoryId, required String type,
    required int amountMillimes, required String description, required String date,
    required String time, required String paymentMethod, String? note,
  }) async {
    final db = await _appDb.database;
    await db.update(
      DatabaseTables.tableTransactions,
      {
        'category_id': categoryId, 'type': type, 'amount': amountMillimes,
        'description': description.trim(), 'date': date, 'time': time,
        'payment_method': paymentMethod, 'note': note?.trim(),
      },
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await _appDb.database;
    await db.delete(DatabaseTables.tableTransactions, where: 'id = ?', whereArgs: [id]);
  }
}
