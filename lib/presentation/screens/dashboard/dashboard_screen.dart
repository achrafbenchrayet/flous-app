import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/expense_line_chart.dart';
import '../../widgets/monthly_bar_chart.dart';
import '../../widgets/recent_transactions_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLOUS.COM'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart_rounded), onPressed: () => context.push('/analytics')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardDataProvider),
        child: dashboardAsync.when(
          data: (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BalanceCard(totalBalance: data.totalBalance, monthIncome: data.monthIncome, monthExpense: data.monthExpense),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Moyenne/jour', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text(CurrencyFormatter.formatMillimes(data.dailyAverageExpense), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Taux d'épargne', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              Text('${data.savingsRate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.savings)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpenseLineChart(dailyExpenses: data.last7DaysExpenses),
                const SizedBox(height: 12),
                CategoryPieChart(categoryDistribution: data.categoryDistribution),
                const SizedBox(height: 12),
                MonthlyBarChart(monthlyData: data.monthlyComparison),
                const SizedBox(height: 16),
                const Text('Activités récentes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 8),
                RecentTransactionsList(transactions: data.recentTransactions),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erreur: $e')),
        ),
      ),
    );
  }
}
