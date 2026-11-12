import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _calculateIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/transactions')) return 1;
    if (loc.startsWith('/savings')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/transactions'); break;
      case 2: context.push('/add-transaction'); break;
      case 3: context.go('/savings'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _calculateIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(0, Icons.home_rounded, 'Accueil', idx, context),
                _item(1, Icons.receipt_long_rounded, 'Transactions', idx, context),
                GestureDetector(
                  onTap: () => _onTap(2, context),
                  child: Container(
                    height: 48, width: 48,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                  ),
                ),
                _item(3, Icons.savings_rounded, 'Épargne', idx, context),
                _item(4, Icons.person_rounded, 'Profil', idx, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData ic, String label, int currentIdx, BuildContext context) {
    final isSel = i == currentIdx;
    return InkWell(
      onTap: () => _onTap(i, context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ic, color: isSel ? AppColors.primary : AppColors.textSecondary, size: 22),
          Text(label, style: TextStyle(color: isSel ? AppColors.primary : AppColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
