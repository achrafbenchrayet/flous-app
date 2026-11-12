import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/analytics/analytics_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/mandatory_change_password_screen.dart';
import '../../presentation/screens/auth/register_user_screen.dart';
import '../../presentation/screens/budgets/budgets_screen.dart';
import '../../presentation/screens/categories/categories_management_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/main_scaffold.dart';
import '../../presentation/screens/profile/manage_users_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/savings/savings_screen.dart';
import '../../presentation/screens/transactions/add_transaction_screen.dart';
import '../../presentation/screens/transactions/transactions_list_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register-user';

      if (!isLoggedIn) return (isLoggingIn || isRegistering) ? null : '/login';
      if (authState.mustChangePassword && state.matchedLocation != '/change-password-mandatory') return '/change-password-mandatory';
      if (isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/change-password-mandatory', builder: (_, __) => const MandatoryChangePasswordScreen()),
      GoRoute(path: '/register-user', builder: (_, __) => const RegisterUserScreen()),
      GoRoute(path: '/manage-users', builder: (_, __) => const ManageUsersScreen()),
      GoRoute(path: '/manage-categories', builder: (_, __) => const CategoriesManagementScreen()),
      GoRoute(path: '/add-transaction', builder: (_, __) => const AddTransactionScreen()),
      GoRoute(path: '/budgets', builder: (_, __) => const BudgetsScreen()),
      GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
      ShellRoute(
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/transactions', builder: (_, __) => const TransactionsListScreen()),
          GoRoute(path: '/savings', builder: (_, __) => const SavingsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
