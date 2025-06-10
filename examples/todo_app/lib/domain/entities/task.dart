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
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? reminderDateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.category,
    this.dueDate,
    required this.isCompleted,
    this.completedAt,
    this.reminderDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? reminderDateTime,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
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
        category,
        dueDate,
        isCompleted,
        completedAt,
        reminderDateTime,
        createdAt,
        updatedAt,
      ];
}
