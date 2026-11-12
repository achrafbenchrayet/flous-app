import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionsListScreen extends ConsumerWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(transactionsListProvider);
    final filter = ref.watch(transactionFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Rechercher...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => ref.read(transactionFilterProvider.notifier).state = filter.copyWith(searchQuery: v),
            ),
          ),
          Expanded(
            child: listAsync.when(
              data: (items) {
                if (items.isEmpty) return const Center(child: Text('Aucune transaction trouvée.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final tx = items[idx];
                    final isInc = tx.type == 'income';
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: AppColors.expense, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) async {
                        await ref.read(transactionRepositoryProvider).deleteTransaction(tx.id);
                        ref.invalidate(transactionsListProvider);
                        ref.invalidate(dashboardDataProvider);
                      },
                      child: Card(
                        child: ListTile(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(initialTransaction: tx))),
                          title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${tx.categoryName ?? "Catégorie"} • ${tx.date}'),
                          trailing: Text(
                            '${isInc ? "+" : "-"}${CurrencyFormatter.formatMillimes(tx.amount)}',
                            style: TextStyle(color: isInc ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
