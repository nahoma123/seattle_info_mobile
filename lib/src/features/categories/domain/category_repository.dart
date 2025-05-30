import 'category.dart';

abstract class CategoryRepository {
  Future<List<Category>> fetchCategories();
}
