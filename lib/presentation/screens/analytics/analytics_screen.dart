import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(analyticsReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analyses & Statistiques')),
      body: reportAsync.when(
        data: (rep) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Text('Solde Net Période', style: TextStyle(color: Colors.white70)),
                      Text(CurrencyFormatter.formatMillimes(rep.netBalance), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  title: const Text('Recettes'),
                  trailing: Text(CurrencyFormatter.formatMillimes(rep.totalIncome), style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.w700)),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Dépenses'),
                  trailing: Text(CurrencyFormatter.formatMillimes(rep.totalExpense), style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700)),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Opérations totales'),
                  trailing: Text('${rep.transactionCount}', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
