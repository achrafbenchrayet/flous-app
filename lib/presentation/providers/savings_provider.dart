import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/repositories/savings_repository.dart';
import 'auth_provider.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) => SavingsRepository());

final savingsGoalsListProvider = FutureProvider.autoDispose<List<SavingsGoalModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  return ref.watch(savingsRepositoryProvider).getGoals(user.id);
});

final savingsMovementsProvider = FutureProvider.family<List<SavingsMovementModel>, String>((ref, goalId) async {
  return ref.watch(savingsRepositoryProvider).getGoalMovements(goalId);
});
