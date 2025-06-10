import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../providers/category_providers.dart';

class TaskFilterSheet extends ConsumerWidget {
  const TaskFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'フィルタ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  ref.read(taskFilterProvider.notifier).state = TaskFilter();
                },
                child: const Text('リセット'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 完了状態フィルタ
          Text(
            '完了状態',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('すべて'),
                selected: filter.isCompleted == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(taskFilterProvider.notifier).state =
                        filter.copyWith(isCompleted: null);
                  }
                },
              ),
              FilterChip(
                label: const Text('未完了'),
                selected: filter.isCompleted == false,
                onSelected: (selected) {
                  ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(isCompleted: selected ? false : null);
                },
              ),
              FilterChip(
                label: const Text('完了済み'),
                selected: filter.isCompleted == true,
                onSelected: (selected) {
                  ref.read(taskFilterProvider.notifier).state =
                      filter.copyWith(isCompleted: selected ? true : null);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 優先度フィルタ
          Text(
            '優先度',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('すべて'),
                selected: filter.priority == null,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(taskFilterProvider.notifier).state =
                        filter.copyWith(priority: null);
                  }
                },
              ),
              ...TaskPriority.values.map((priority) => FilterChip(
                    label: Text(priority.label),
                    selected: filter.priority == priority,
                    onSelected: (selected) {
                      ref.read(taskFilterProvider.notifier).state =
                          filter.copyWith(priority: selected ? priority : null);
                    },
                  )),
            ],
          ),

          const SizedBox(height: 16),

          // カテゴリフィルタ
          Text(
            'カテゴリ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) => Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('すべて'),
                  selected: filter.category == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(taskFilterProvider.notifier).state =
                          filter.copyWith(category: null);
                    }
                  },
                ),
                ...categories.map((category) => FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (category.icon != null)
                            Icon(category.icon,
                                size: 16, color: category.color),
                          const SizedBox(width: 4),
                          Text(category.name),
                        ],
                      ),
                      selected: filter.category == category.name,
                      onSelected: (selected) {
                        ref.read(taskFilterProvider.notifier).state =
                            filter.copyWith(
                                category: selected ? category.name : null);
                      },
                    )),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('エラー: $error'),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('適用'),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
