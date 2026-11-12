class DatabaseTables {
  DatabaseTables._();
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tableTransactions = 'transactions';
  static const String tableSavingsGoals = 'savings_goals';
  static const String tableSavingsMovements = 'savings_movements';
  static const String tableBudgets = 'budgets';
  static const String tableAppSettings = 'app_settings';

  static const String createTableUsers = '''
    CREATE TABLE $tableUsers (
      id TEXT PRIMARY KEY,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      password_salt TEXT NOT NULL,
      role TEXT NOT NULL DEFAULT 'user',
      avatar TEXT,
      initial_balance INTEGER NOT NULL DEFAULT 0,
      must_change_password INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    );
  ''';

  static const String createTableCategories = '''
    CREATE TABLE $tableCategories (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      icon TEXT NOT NULL,
      color INTEGER NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
      is_default INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE
    );
  ''';

  static const String createTableTransactions = '''
    CREATE TABLE $tableTransactions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      category_id TEXT NOT NULL,
      type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
      amount INTEGER NOT NULL CHECK(amount > 0),
      description TEXT NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      payment_method TEXT NOT NULL,
      note TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE RESTRICT
    );
  ''';

  static const String createTableSavingsGoals = '''
    CREATE TABLE $tableSavingsGoals (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      target_amount INTEGER NOT NULL CHECK(target_amount > 0),
      current_amount INTEGER NOT NULL DEFAULT 0,
      start_date TEXT NOT NULL,
      deadline TEXT,
      icon TEXT NOT NULL,
      color INTEGER NOT NULL,
      status TEXT NOT NULL DEFAULT 'in_progress',
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE
    );
  ''';

  static const String createTableSavingsMovements = '''
    CREATE TABLE $tableSavingsMovements (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      goal_id TEXT NOT NULL,
      amount INTEGER NOT NULL CHECK(amount > 0),
      movement_type TEXT NOT NULL CHECK(movement_type IN ('deposit', 'withdraw')),
      date TEXT NOT NULL,
      description TEXT,
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE,
      FOREIGN KEY (goal_id) REFERENCES $tableSavingsGoals (id) ON DELETE CASCADE
    );
  ''';

  static const String createTableBudgets = '''
    CREATE TABLE $tableBudgets (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      category_id TEXT,
      amount INTEGER NOT NULL CHECK(amount > 0),
      period TEXT NOT NULL DEFAULT 'monthly',
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE CASCADE
    );
  ''';

  static const String createTableAppSettings = '''
    CREATE TABLE $tableAppSettings (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      setting_key TEXT NOT NULL,
      setting_value TEXT NOT NULL,
      UNIQUE(user_id, setting_key),
      FOREIGN KEY (user_id) REFERENCES $tableUsers (id) ON DELETE CASCADE
    );
  ''';

  static const List<String> createIndexes = [
    'CREATE INDEX idx_trans_user_date ON transactions (user_id, date);',
    'CREATE INDEX idx_trans_category ON transactions (category_id);',
    'CREATE INDEX idx_categories_user ON categories (user_id);',
    'CREATE INDEX idx_savings_user ON savings_goals (user_id);',
    'CREATE INDEX idx_budgets_user ON budgets (user_id);',
  ];
}
