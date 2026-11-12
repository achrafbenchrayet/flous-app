import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/security_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());

class AuthNotifier extends StateNotifier<UserModel?> {
  final UserRepository _repo;
  AuthNotifier(this._repo) : super(null);

  Future<String?> login(String username, String password) async {
    try {
      final user = await _repo.getUserByUsername(username);
      if (user == null) return 'Identifiant ou mot de passe incorrect.';
      if (!SecurityService.verifyPassword(password, user.passwordHash, user.passwordSalt)) return 'Identifiant ou mot de passe incorrect.';
      state = user;
      return null;
    } catch (e) {
      return 'Erreur de base de données : $e';
    }
  }

  Future<String?> completeMandatoryUpdate({
    required String newUsername, required String newPassword,
    required String firstName, required String lastName,
  }) async {
    if (state == null) return 'Aucun utilisateur connecté.';
    try {
      final existing = await _repo.getUserByUsername(newUsername);
      if (existing != null && existing.id != state!.id) return 'Cet identifiant est déjà utilisé.';
      await _repo.updateInitialCredentials(userId: state!.id, newUsername: newUsername, newPassword: newPassword, firstName: firstName, lastName: lastName);
      state = await _repo.getUserById(state!.id);
      return null;
    } catch (e) {
      return 'Erreur : $e';
    }
  }

  Future<void> refreshCurrentUser() async {
    if (state == null) return;
    state = await _repo.getUserById(state!.id);
  }

  void logout() => state = null;
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) => AuthNotifier(ref.watch(userRepositoryProvider)));
