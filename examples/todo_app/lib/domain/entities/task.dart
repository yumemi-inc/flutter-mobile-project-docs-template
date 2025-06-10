import 'package:equatable/equatable.dart';

enum TaskPriority {
  low(1, 'Low'),
  medium(2, 'Medium'),
  high(3, 'High');

  const TaskPriority(this.value, this.label);
  final int value;
  final String label;
}

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final String? categoryId;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
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

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    String? categoryId,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        categoryId,
        dueDate,
        isCompleted,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
