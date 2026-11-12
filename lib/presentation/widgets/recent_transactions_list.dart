import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<TransactionModel> transactions;
  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text('Aucune transaction récente.')),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx.type == 'income';
        return Card(
          child: ListTile(
            title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('${tx.categoryName ?? "Autre"} • ${tx.date}'),
            trailing: Text(
              '${isIncome ? "+" : "-"}${CurrencyFormatter.formatMillimes(tx.amount)}',
              style: TextStyle(color: isIncome ? AppColors.income : AppColors.expense, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
