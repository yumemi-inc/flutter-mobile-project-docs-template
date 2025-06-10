import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import './task_providers.dart';

// Categories provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

// Selected category provider
final selectedCategoryProvider = StateProvider<Category?>((ref) {
  return null;
});
