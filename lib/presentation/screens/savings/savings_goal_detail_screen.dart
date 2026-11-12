import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/savings_provider.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  final String goalId;
  const SavingsGoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movsAsync = ref.watch(savingsMovementsProvider(goalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail Épargne')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          final amtCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Versement Épargne'),
              content: TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant (DT)')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () async {
                    final u = ref.read(authProvider)!;
                    await ref.read(savingsRepositoryProvider).addMovement(
                      userId: u.id, goalId: goalId,
                      amountMillimes: CurrencyFormatter.parseToMillimes(amtCtrl.text), movementType: 'deposit',
                    );
                    ref.invalidate(savingsGoalsListProvider);
                    ref.invalidate(savingsMovementsProvider(goalId));
                    ref.invalidate(dashboardDataProvider);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Verser'),
                ),
              ],
            ),
          );
        },
      ),
      body: movsAsync.when(
        data: (movs) => ListView.builder(
          itemCount: movs.length,
          itemBuilder: (context, idx) => ListTile(
            title: Text(movs[idx].movementType == 'deposit' ? 'Versement' : 'Retrait'),
            subtitle: Text(movs[idx].date),
            trailing: Text(CurrencyFormatter.formatMillimes(movs[idx].amount)),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
