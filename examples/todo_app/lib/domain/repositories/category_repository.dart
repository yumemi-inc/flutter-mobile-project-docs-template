import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getDefaultCategories();
}
