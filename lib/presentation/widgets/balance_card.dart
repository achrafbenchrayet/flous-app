import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class BalanceCard extends ConsumerWidget {
  final int totalBalance;
  final int monthIncome;
  final int monthExpense;

  const BalanceCard({super.key, required this.totalBalance, required this.monthIncome, required this.monthExpense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isVisible = ref.watch(balanceVisibilityProvider);
    final nowFormatted = DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bonjour, ${user?.firstName ?? "Utilisateur"} 👋', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(nowFormatted[0].toUpperCase() + nowFormatted.substring(1), style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                ],
              ),
              IconButton(
                onPressed: () => ref.read(balanceVisibilityProvider.notifier).state = !isVisible,
                icon: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Solde disponible', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 6),
          Text(isVisible ? CurrencyFormatter.formatMillimes(totalBalance) : '•••••••• DT', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlow('Recettes mois', monthIncome, const Color(0xFF34D399), isVisible),
                Container(height: 28, width: 1, color: Colors.white24),
                _buildFlow('Dépenses mois', monthExpense, const Color(0xFFF87171), isVisible),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlow(String label, int amount, Color color, bool isVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11)),
        const SizedBox(height: 2),
        Text(isVisible ? CurrencyFormatter.formatMillimes(amount) : '•••• DT', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
