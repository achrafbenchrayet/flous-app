import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/dashboard_repository.dart';
import 'auth_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => DashboardRepository());
final balanceVisibilityProvider = StateProvider<bool>((ref) => true);

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) throw Exception('Utilisateur non connecté.');
  return ref.watch(dashboardRepositoryProvider).getDashboardData(user.id);
});
