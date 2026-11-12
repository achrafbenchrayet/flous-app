import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../core/security/security_service.dart';
import 'database_tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flous_secure.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(DatabaseTables.createTableUsers);
    await db.execute(DatabaseTables.createTableCategories);
    await db.execute(DatabaseTables.createTableTransactions);
    await db.execute(DatabaseTables.createTableSavingsGoals);
    await db.execute(DatabaseTables.createTableSavingsMovements);
    await db.execute(DatabaseTables.createTableBudgets);
    await db.execute(DatabaseTables.createTableAppSettings);

    for (final idx in DatabaseTables.createIndexes) {
      await db.execute(idx);
    }
    await _seedInitialAdmin(db);
  }

  Future<void> _seedInitialAdmin(Database db) async {
    const adminId = 'admin-system-uuid';
    final salt = SecurityService.generateSalt();
    final hash = SecurityService.hashPassword('admin', salt);
    final now = DateTime.now().toIso8601String();

    await db.insert(DatabaseTables.tableUsers, {
      'id': adminId,
      'first_name': 'Administrateur',
      'last_name': 'Flous',
      'username': 'admin',
      'password_hash': hash,
      'password_salt': salt,
      'role': 'admin',
      'avatar': null,
      'initial_balance': 0,
      'must_change_password': 1,
      'created_at': now,
    });

    await seedDefaultCategories(db, adminId);
  }

  static Future<void> seedDefaultCategories(DatabaseExecutor db, String userId) async {
    final uuid = const Uuid();
    final now = DateTime.now().toIso8601String();

    final defaultExpense = [
      {'name': 'Nourriture', 'icon': 'fastfood', 'color': 0xFFEF4444},
      {'name': 'Restaurants', 'icon': 'restaurant', 'color': 0xFFF97316},
      {'name': 'Transport', 'icon': 'directions_car', 'color': 0xFF3B82F6},
      {'name': 'Factures', 'icon': 'receipt_long', 'color': 0xFF6366F1},
      {'name': 'Loyer', 'icon': 'home', 'color': 0xFF8B5CF6},
      {'name': 'Santé', 'icon': 'medical_services', 'color': 0xFFEC4899},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': 0xFFF43F5E},
      {'name': 'Loisirs', 'icon': 'sports_esports', 'color': 0xFF14B8A6},
      {'name': 'Éducation', 'icon': 'school', 'color': 0xFF06B6D4},
      {'name': 'Famille', 'icon': 'people', 'color': 0xFF84CC16},
      {'name': 'Téléphone / Internet', 'icon': 'wifi', 'color': 0xFF10B981},
      {'name': 'Abonnements', 'icon': 'subscriptions', 'color': 0xFFA855F7},
      {'name': 'Autres dépenses', 'icon': 'more_horiz', 'color': 0xFF64748B},
    ];

    final defaultIncome = [
      {'name': 'Salaire', 'icon': 'account_balance_wallet', 'color': 0xFF10B981},
      {'name': 'Freelance', 'icon': 'laptop_mac', 'color': 0xFF06B6D4},
      {'name': 'Commerce', 'icon': 'store', 'color': 0xFF3B82F6},
      {'name': 'Prime', 'icon': 'card_giftcard', 'color': 0xFFF59E0B},
      {'name': 'Cadeaux', 'icon': 'redeem', 'color': 0xFFEC4899},
      {'name': 'Investissements', 'icon': 'trending_up', 'color': 0xFF8B5CF6},
      {'name': 'Remboursements', 'icon': 'replay', 'color': 0xFF14B8A6},
      {'name': 'Autres recettes', 'icon': 'add_circle_outline', 'color': 0xFF64748B},
    ];

    for (final cat in defaultExpense) {
      await db.insert(DatabaseTables.tableCategories, {
        'id': uuid.v4(), 'user_id': userId, 'name': cat['name'],
        'description': 'Catégorie par défaut', 'icon': cat['icon'],
        'color': cat['color'], 'type': 'expense', 'is_default': 1, 'created_at': now,
      });
    }

    for (final cat in defaultIncome) {
      await db.insert(DatabaseTables.tableCategories, {
        'id': uuid.v4(), 'user_id': userId, 'name': cat['name'],
        'description': 'Catégorie par défaut', 'icon': cat['icon'],
        'color': cat['color'], 'type': 'income', 'is_default': 1, 'created_at': now,
      });
    }
  }
}
