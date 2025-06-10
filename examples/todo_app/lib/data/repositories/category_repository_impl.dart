import 'package:sqflite/sqflite.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<List<Category>> getAllCategories() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return CategoryModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first).toDomain();
  }

  @override
  Future<Category> createCategory(Category category) async {
    final db = await DatabaseHelper.database;
    final categoryModel = CategoryModel.fromDomain(category);

    await db.insert(
      'categories',
      categoryModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final db = await DatabaseHelper.database;
    final categoryModel = CategoryModel.fromDomain(category);

    await db.update(
      'categories',
      categoryModel.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );

    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await DatabaseHelper.database;

    // 関連するタスクのカテゴリをデフォルトに設定
    await db.update(
      'tasks',
      {'category': 'その他'},
      where: 'category = ?',
      whereArgs: [id],
    );

    // カテゴリを削除
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Category>> getDefaultCategories() async {
    return CategoryFactory.getDefaultCategories();
  }
}
