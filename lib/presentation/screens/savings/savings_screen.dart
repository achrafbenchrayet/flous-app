import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/savings_provider.dart';
import 'savings_goal_detail_screen.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs d'Épargne'),
        actions: [
          IconButton(icon: const Icon(Icons.pie_chart), onPressed: () => context.push('/budgets')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.savings,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvel Objectif', style: TextStyle(color: Colors.white)),
        onPressed: () {
          final nCtrl = TextEditingController();
          final aCtrl = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Nouvel Objectif'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'Nom du projet')),
                  TextField(controller: aCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant Cible (DT)')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () async {
                    if (nCtrl.text.isNotEmpty) {
                      final u = ref.read(authProvider)!;
                      await ref.read(savingsRepositoryProvider).createGoal(
                        userId: u.id, name: nCtrl.text,
                        targetAmountMillimes: CurrencyFormatter.parseToMillimes(aCtrl.text),
                        icon: 'savings', color: 0xFF8B5CF6,
                      );
                      ref.invalidate(savingsGoalsListProvider);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            ),
          );
        },
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) return const Center(child: Text('Aucun objectif d'épargne.'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final g = goals[idx];
              return Card(
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavingsGoalDetailScreen(goalId: g.id))),
                  title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${CurrencyFormatter.formatMillimes(g.currentAmount)} / ${CurrencyFormatter.formatMillimes(g.targetAmount)}'),
                  trailing: Text('${(g.progressPercentage * 100).toStringAsFixed(0)}%'),
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
