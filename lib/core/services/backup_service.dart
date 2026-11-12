import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_tables.dart';

class BackupService {
  final AppDatabase _appDb = AppDatabase.instance;

  Future<String> exportTransactionsToCSV(String userId) async {
    final db = await _appDb.database;
    final rows = await db.rawQuery('''
      SELECT t.date, t.time, t.type, t.description, c.name AS category_name, t.amount, t.payment_method, t.note
      FROM ${DatabaseTables.tableTransactions} t
      LEFT JOIN ${DatabaseTables.tableCategories} c ON t.category_id = c.id
      WHERE t.user_id = ?
      ORDER BY t.date DESC, t.time DESC
    ''', [userId]);

    final List<List<dynamic>> csvData = [
      ['Date', 'Heure', 'Type', 'Description', 'Categorie', 'Montant_Millimes', 'Montant_DT', 'Mode_Paiement', 'Note']
    ];

    for (final r in rows) {
      final int amountMillimes = r['amount'] as int;
      csvData.add([
        r['date'], r['time'], r['type'] == 'income' ? 'Recette' : 'Depense',
        r['description'], r['category_name'] ?? 'Non categorise', amountMillimes,
        (amountMillimes / 1000.0).toStringAsFixed(3), r['payment_method'], r['note'] ?? '',
      ]);
    }

    final String csvContent = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/flous_transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(filePath);
    await file.writeAsString(csvContent);
    return filePath;
  }

  Future<String> exportCompleteUserDataToJson(String userId) async {
    final db = await _appDb.database;
    final userRows = await db.query(DatabaseTables.tableUsers, where: 'id = ?', whereArgs: [userId]);
    final catRows = await db.query(DatabaseTables.tableCategories, where: 'user_id = ?', whereArgs: [userId]);
    final txRows = await db.query(DatabaseTables.tableTransactions, where: 'user_id = ?', whereArgs: [userId]);
    final goalRows = await db.query(DatabaseTables.tableSavingsGoals, where: 'user_id = ?', whereArgs: [userId]);
    final movRows = await db.query(DatabaseTables.tableSavingsMovements, where: 'user_id = ?', whereArgs: [userId]);
    final budRows = await db.query(DatabaseTables.tableBudgets, where: 'user_id = ?', whereArgs: [userId]);

    final Map<String, dynamic> exportMap = {
      'app': 'Flous.com',
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'user': userRows.isNotEmpty ? userRows.first : null,
      'categories': catRows,
      'transactions': txRows,
      'savings_goals': goalRows,
      'savings_movements': movRows,
      'budgets': budRows,
    };

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/flous_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(filePath);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(exportMap));
    return filePath;
  }

  Future<void> resetUserData(String userId) async {
    final db = await _appDb.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseTables.tableTransactions, where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete(DatabaseTables.tableSavingsMovements, where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete(DatabaseTables.tableSavingsGoals, where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete(DatabaseTables.tableBudgets, where: 'user_id = ?', whereArgs: [userId]);
      await txn.delete(DatabaseTables.tableCategories, where: 'user_id = ?', whereArgs: [userId]);
      await txn.update(DatabaseTables.tableUsers, {'initial_balance': 0}, where: 'id = ?', whereArgs: [userId]);
      await AppDatabase.seedDefaultCategories(txn, userId);
    });
  }
}
