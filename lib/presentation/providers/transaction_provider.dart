import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'auth_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) => TransactionRepository());
final transactionFilterProvider = StateProvider<TransactionFilterOptions>((ref) => const TransactionFilterOptions());

final transactionsListProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  return ref.watch(transactionRepositoryProvider).getFilteredTransactions(user.id, ref.watch(transactionFilterProvider));
});
