import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import 'auth_provider.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => BudgetRepository());

final budgetsListProvider = FutureProvider.autoDispose<List<BudgetModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  return ref.watch(budgetRepositoryProvider).getActiveBudgets(user.id);
});
