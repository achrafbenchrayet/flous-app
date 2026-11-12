import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets Prévisionnels')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final amtCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Plafond Mensuel Global'),
              content: TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant (DT)')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () async {
                    final u = ref.read(authProvider)!;
                    await ref.read(budgetRepositoryProvider).setBudget(userId: u.id, amountMillimes: CurrencyFormatter.parseToMillimes(amtCtrl.text));
                    ref.invalidate(budgetsListProvider);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Définir'),
                ),
              ],
            ),
          );
        },
      ),
      body: budgetsAsync.when(
        data: (budgets) {
          if (budgets.isEmpty) return const Center(child: Text('Aucun budget défini.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, idx) {
              final b = budgets[idx];
              final isOver = b.isExceeded;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.categoryName ?? 'Budget Global', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text('${CurrencyFormatter.formatMillimes(b.spentAmount)} / ${CurrencyFormatter.formatMillimes(b.amount)}'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: b.consumptionRatio.clamp(0.0, 1.0), color: isOver ? AppColors.expense : AppColors.income),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
