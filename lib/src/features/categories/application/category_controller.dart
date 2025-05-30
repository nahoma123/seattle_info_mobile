import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../infrastructure/api_category_repository.dart';

// Provider for CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  // In a real app, http.Client and baseUrl might be provided by other providers
  // For example, from a config provider.
  return ApiCategoryRepository();
});

// Provider to fetch and provide the list of categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return categoryRepository.fetchCategories();
});
