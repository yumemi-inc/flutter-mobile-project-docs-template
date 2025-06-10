import 'package:sqflite/sqflite.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<List<Task>> getAllTasks() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'is_completed ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first).toDomain();
  }

  @override
  Future<Task> createTask(Task task) async {
    final db = await DatabaseHelper.database;
    final taskModel = TaskModel.fromDomain(task);

    await db.insert(
      'tasks',
      taskModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final db = await DatabaseHelper.database;
    final taskModel = TaskModel.fromDomain(task);

    await db.update(
      'tasks',
      taskModel.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );

    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'is_completed ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'priority = ?',
      whereArgs: [priority.label],
      orderBy: 'is_completed ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'is_completed = ?',
      whereArgs: [isCompleted ? 1 : 0],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'is_completed ASC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<List<Task>> getTasksByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'due_date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'due_date ASC',
    );

    return List.generate(maps.length, (i) {
      return TaskModel.fromMap(maps[i]).toDomain();
    });
  }

  @override
  Future<List<Task>> getUpcomingTasks(int days) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return getTasksByDateRange(now, future);
  }

  @override
  Future<Map<String, int>> getTaskStatistics() async {
    final db = await DatabaseHelper.database;

    final totalResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    final completedResult = await db
        .rawQuery('SELECT COUNT(*) as count FROM tasks WHERE is_completed = 1');
    final pendingResult = await db
        .rawQuery('SELECT COUNT(*) as count FROM tasks WHERE is_completed = 0');

    return {
      'total': totalResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'pending': pendingResult.first['count'] as int,
    };
  }
}
