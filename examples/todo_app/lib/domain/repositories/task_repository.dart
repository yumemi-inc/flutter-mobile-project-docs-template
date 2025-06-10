import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<List<Task>> getTasksByCategory(String categoryId);
  Future<List<Task>> getTasksByPriority(TaskPriority priority);
  Future<List<Task>> getTasksByStatus(bool isCompleted);
  Future<List<Task>> searchTasks(String query);
  Future<Task?> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> getTasksByDateRange(DateTime start, DateTime end);
  Future<List<Task>> getUpcomingTasks(int days);
  Future<Map<String, int>> getTaskStatistics();
}
