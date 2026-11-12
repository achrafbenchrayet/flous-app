import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';
import 'auth_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

final categoriesListProvider = FutureProvider.family<List<CategoryModel>, String?>((ref, type) async {
  final user = ref.watch(authProvider);
  if (user == null) return [];
  return ref.watch(categoryRepositoryProvider).getCategories(user.id, type: type);
});
