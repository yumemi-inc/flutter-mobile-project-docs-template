import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetAllTasksUseCase {
  final TaskRepository repository;

  GetAllTasksUseCase(this.repository);

  Future<List<Task>> call() async {
    return await repository.getAllTasks();
  }
}

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Task> call(Task task) async {
    return await repository.createTask(task);
  }
}

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Task> call(Task task) async {
    return await repository.updateTask(task);
  }
}

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteTask(id);
  }
}

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;

  ToggleTaskCompletionUseCase(this.repository);

  Future<Task> call(String taskId) async {
    final task = await repository.getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    return await repository.updateTask(updatedTask);
  }
}

class SearchTasksUseCase {
  final TaskRepository repository;

  SearchTasksUseCase(this.repository);

  Future<List<Task>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getAllTasks();
    }
    return await repository.searchTasks(query);
  }
}

class GetTasksByFilterUseCase {
  final TaskRepository repository;

  GetTasksByFilterUseCase(this.repository);

  Future<List<Task>> call({
    String? category,
    TaskPriority? priority,
    bool? isCompleted,
  }) async {
    List<Task> tasks = await repository.getAllTasks();

    if (category != null) {
      tasks = tasks.where((task) => task.category == category).toList();
    }

    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    if (isCompleted != null) {
      tasks = tasks.where((task) => task.isCompleted == isCompleted).toList();
    }

    return tasks;
  }
}
