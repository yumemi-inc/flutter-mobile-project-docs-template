import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';
import '../providers/category_providers.dart';

class TaskListItem extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggleComplete(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildPriorityChip(),
                  const SizedBox(width: 8),
                  if (task.category.isNotEmpty && task.category != 'その他')
                    categoriesAsync.when(
                      data: (categories) {
                        final category = categories
                            .where((c) => c.name == task.category)
                            .firstOrNull;
                        return category != null
                            ? _buildCategoryChip(category.name, category.color)
                            : _buildCategoryChip(task.category, Colors.grey);
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) =>
                          _buildCategoryChip(task.category, Colors.grey),
                    ),
                  const Spacer(),
                  if (task.dueDate != null) _buildDueDateText(),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: task.isCompleted ? Colors.grey : null,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    switch (task.priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        task.priority.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDueDateText() {
    final formatter = DateFormat('MM/dd');
    final dueDate = task.dueDate!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    Color color = Colors.grey;
    if (taskDate.isBefore(today)) {
      color = Colors.red; // 過去の日付
    } else if (taskDate.isAtSameMomentAs(today)) {
      color = Colors.orange; // 今日
    }

    return Text(
      formatter.format(dueDate),
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
