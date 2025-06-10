import '../../domain/entities/task.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String priority;
  final String category;
  final DateTime? dueDate;
  final int isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.category,
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
      priority: map['priority'] as String,
      category: map['category'] as String,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      isCompleted: map['is_completed'] as int,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: TaskPriority.values.firstWhere(
        (p) => p.label == priority,
        orElse: () => TaskPriority.medium,
      ),
      category: category,
      dueDate: dueDate,
      isCompleted: isCompleted == 1,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskModel fromDomain(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority.label,
      category: task.category,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted ? 1 : 0,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }
}
