import 'package:uuid/uuid.dart';
import '../../core/security/security_service.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/user_model.dart';

class UserRepository {
  final AppDatabase _appDb = AppDatabase.instance;
  final Uuid _uuid = const Uuid();

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await _appDb.database;
    final results = await db.query(DatabaseTables.tableUsers, where: 'LOWER(username) = ?', whereArgs: [username.trim().toLowerCase()], limit: 1);
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await _appDb.database;
    final results = await db.query(DatabaseTables.tableUsers, where: 'id = ?', whereArgs: [id], limit: 1);
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await _appDb.database;
    final results = await db.query(DatabaseTables.tableUsers, orderBy: 'first_name ASC');
    return results.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<UserModel> createUser({
    required String firstName, required String lastName,
    required String username, required String password,
    String role = 'user', int initialBalanceMillimes = 0,
  }) async {
    final db = await _appDb.database;
    final salt = SecurityService.generateSalt();
    final hash = SecurityService.hashPassword(password, salt);
    final String newId = _uuid.v4();

    final newUser = UserModel(
      id: newId, firstName: firstName.trim(), lastName: lastName.trim(),
      username: username.trim().toLowerCase(), passwordHash: hash, passwordSalt: salt,
      role: role, avatar: null, initialBalance: initialBalanceMillimes,
      mustChangePassword: false, createdAt: DateTime.now().toIso8601String(),
    );

    await db.transaction((txn) async {
      await txn.insert(DatabaseTables.tableUsers, newUser.toMap());
      await AppDatabase.seedDefaultCategories(txn, newId);
    });
    return newUser;
  }

  Future<void> updateInitialCredentials({
    required String userId, required String newUsername,
    required String newPassword, required String firstName, required String lastName,
  }) async {
    final db = await _appDb.database;
    final salt = SecurityService.generateSalt();
    final hash = SecurityService.hashPassword(newPassword, salt);

    await db.update(
      DatabaseTables.tableUsers,
      {
        'username': newUsername.trim().toLowerCase(), 'first_name': firstName.trim(),
        'last_name': lastName.trim(), 'password_hash': hash, 'password_salt': salt,
        'must_change_password': 0,
      },
      where: 'id = ?', whereArgs: [userId],
    );
  }

  Future<void> updateUserProfile({
    required String userId, required String firstName,
    required String lastName, required int initialBalanceMillimes,
  }) async {
    final db = await _appDb.database;
    await db.update(
      DatabaseTables.tableUsers,
      {'first_name': firstName.trim(), 'last_name': lastName.trim(), 'initial_balance': initialBalanceMillimes},
      where: 'id = ?', whereArgs: [userId],
    );
  }

  Future<bool> changePassword({required String userId, required String oldPassword, required String newPassword}) async {
    final user = await getUserById(userId);
    if (user == null) return false;
    if (!SecurityService.verifyPassword(oldPassword, user.passwordHash, user.passwordSalt)) return false;

    final db = await _appDb.database;
    final newSalt = SecurityService.generateSalt();
    final newHash = SecurityService.hashPassword(newPassword, newSalt);

    await db.update(DatabaseTables.tableUsers, {'password_hash': newHash, 'password_salt': newSalt}, where: 'id = ?', whereArgs: [userId]);
    return true;
  }

  Future<void> deleteUser(String userId) async {
    final db = await _appDb.database;
    await db.delete(DatabaseTables.tableUsers, where: 'id = ?', whereArgs: [userId]);
  }
}
