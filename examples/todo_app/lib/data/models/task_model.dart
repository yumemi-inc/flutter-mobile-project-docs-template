import '../../domain/entities/task.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final int priority;
  final String? categoryId;
  final int? dueDate;
  final int isCompleted;
  final int? completedAt;
  final int createdAt;
  final int updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    this.categoryId,
    this.dueDate,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: map['priority'] as int,
      categoryId: map['category_id'] as String?,
      dueDate: map['due_date'] as int?,
      isCompleted: map['is_completed'] as int,
      completedAt: map['completed_at'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'category_id': categoryId,
      'due_date': dueDate,
      'is_completed': isCompleted,
      'completed_at': completedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: TaskPriority.values.firstWhere((p) => p.value == priority),
      categoryId: categoryId,
      dueDate: dueDate != null
          ? DateTime.fromMillisecondsSinceEpoch(dueDate!)
          : null,
      isCompleted: isCompleted == 1,
      completedAt: completedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(completedAt!)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  static TaskModel fromDomain(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority.value,
      categoryId: task.categoryId,
      dueDate: task.dueDate?.millisecondsSinceEpoch,
      isCompleted: task.isCompleted ? 1 : 0,
      completedAt: task.completedAt?.millisecondsSinceEpoch,
      createdAt: task.createdAt.millisecondsSinceEpoch,
      updatedAt: task.updatedAt.millisecondsSinceEpoch,
    );
  }
}
