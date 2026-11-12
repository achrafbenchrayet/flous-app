class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String passwordHash;
  final String passwordSalt;
  final String role;
  final String? avatar;
  final int initialBalance;
  final bool mustChangePassword;
  final String createdAt;

  const UserModel({
    required this.id, required this.firstName, required this.lastName,
    required this.username, required this.passwordHash, required this.passwordSalt,
    required this.role, this.avatar, required this.initialBalance,
    required this.mustChangePassword, required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'first_name': firstName, 'last_name': lastName,
    'username': username, 'password_hash': passwordHash, 'password_salt': passwordSalt,
    'role': role, 'avatar': avatar, 'initial_balance': initialBalance,
    'must_change_password': mustChangePassword ? 1 : 0, 'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String, firstName: map['first_name'] as String,
    lastName: map['last_name'] as String, username: map['username'] as String,
    passwordHash: map['password_hash'] as String, passwordSalt: map['password_salt'] as String,
    role: map['role'] as String, avatar: map['avatar'] as String?,
    initialBalance: map['initial_balance'] as int,
    mustChangePassword: (map['must_change_password'] as int) == 1,
    createdAt: map['created_at'] as String,
  );
}
