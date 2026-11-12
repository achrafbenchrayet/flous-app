import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/savings_goal_model.dart';

class SavingsRepository {
  final AppDatabase _appDb = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<List<SavingsGoalModel>> getGoals(String userId) async {
    final db = await _appDb.database;
    final results = await db.query(DatabaseTables.tableSavingsGoals, where: 'user_id = ?', whereArgs: [userId]);
    return results.map((m) => SavingsGoalModel.fromMap(m)).toList();
  }

  Future<void> createGoal({
    required String userId, required String name, required int targetAmountMillimes,
    required String icon, required int color, String? description, String? deadline,
  }) async {
    final db = await _appDb.database;
    await db.insert(DatabaseTables.tableSavingsGoals, {
      'id': _uuid.v4(), 'user_id': userId, 'name': name.trim(),
      'description': description?.trim(), 'target_amount': targetAmountMillimes,
      'current_amount': 0, 'start_date': DateTime.now().toIso8601String().substring(0, 10),
      'deadline': deadline, 'icon': icon, 'color': color, 'status': 'in_progress',
    });
  }

  Future<void> addMovement({
    required String userId, required String goalId, required int amountMillimes,
    required String movementType, String? description,
  }) async {
    final db = await _appDb.database;
    await db.transaction((txn) async {
      final goalRes = await txn.query(DatabaseTables.tableSavingsGoals, where: 'id = ? AND user_id = ?', whereArgs: [goalId, userId]);
      if (goalRes.isEmpty) throw Exception('Objectif introuvable.');

      final int cur = goalRes.first['current_amount'] as int;
      final int tgt = goalRes.first['target_amount'] as int;
      int updated = (movementType == 'deposit') ? (cur + amountMillimes) : (cur - amountMillimes);
      if (updated < 0) throw Exception('Solde epargne insuffisant.');

      await txn.update(DatabaseTables.tableSavingsGoals, {'current_amount': updated, 'status': updated >= tgt ? 'completed' : 'in_progress'}, where: 'id = ?', whereArgs: [goalId]);
      await txn.insert(DatabaseTables.tableSavingsMovements, {
        'id': _uuid.v4(), 'user_id': userId, 'goal_id': goalId,
        'amount': amountMillimes, 'movement_type': movementType,
        'date': DateTime.now().toIso8601String().substring(0, 10), 'description': description?.trim(),
      });
    });
  }

  Future<List<SavingsMovementModel>> getGoalMovements(String goalId) async {
    final db = await _appDb.database;
    final results = await db.query(DatabaseTables.tableSavingsMovements, where: 'goal_id = ?', whereArgs: [goalId], orderBy: 'date DESC');
    return results.map((m) => SavingsMovementModel.fromMap(m)).toList();
  }

  Future<void> deleteGoal(String goalId) async {
    final db = await _appDb.database;
    await db.delete(DatabaseTables.tableSavingsGoals, where: 'id = ?', whereArgs: [goalId]);
  }
}
