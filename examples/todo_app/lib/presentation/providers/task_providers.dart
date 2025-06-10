import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';

// Repository providers
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl();
});

// UseCase providers
final getAllTasksUseCaseProvider = Provider<GetAllTasksUseCase>((ref) {
  return GetAllTasksUseCase(ref.read(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.read(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.read(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.read(taskRepositoryProvider));
});

final toggleTaskCompletionUseCaseProvider =
    Provider<ToggleTaskCompletionUseCase>((ref) {
  return ToggleTaskCompletionUseCase(ref.read(taskRepositoryProvider));
});

final searchTasksUseCaseProvider = Provider<SearchTasksUseCase>((ref) {
  return SearchTasksUseCase(ref.read(taskRepositoryProvider));
});

final getTasksByFilterUseCaseProvider =
    Provider<GetTasksByFilterUseCase>((ref) {
  return GetTasksByFilterUseCase(ref.read(taskRepositoryProvider));
});

// State providers
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final useCase = ref.read(getAllTasksUseCaseProvider);
  return await useCase();
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter();
});

final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Filtered tasks provider
final filteredTasksProvider = FutureProvider<List<Task>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final filter = ref.watch(taskFilterProvider);

  if (searchQuery.isNotEmpty) {
    final useCase = ref.read(searchTasksUseCaseProvider);
    return await useCase(searchQuery);
  }

  final useCase = ref.read(getTasksByFilterUseCaseProvider);
  return await useCase(
    category: filter.category,
    priority: filter.priority,
    isCompleted: filter.isCompleted,
  );
});

// Task statistics provider
final taskStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return await repository.getTaskStatistics();
});

class TaskFilter {
  final String? category;
  final TaskPriority? priority;
  final bool? isCompleted;

  TaskFilter({
    this.category,
    this.priority,
    this.isCompleted,
  });

  TaskFilter copyWith({
    String? category,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return TaskFilter(
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
