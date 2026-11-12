import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/analytics_repository.dart';
import 'auth_provider.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) => AnalyticsRepository());
final analyticsFilterProvider = StateProvider<AnalyticsFilter>((ref) => const AnalyticsFilter());

final analyticsReportProvider = FutureProvider.autoDispose<AnalyticsReport>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) throw Exception('Utilisateur non connecté.');
  return ref.watch(analyticsRepositoryProvider).generateReport(user.id, ref.watch(analyticsFilterProvider));
});
