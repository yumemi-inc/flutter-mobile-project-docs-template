import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/category.dart';
import '../providers/task_providers.dart';
import '../providers/category_providers.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormPage({super.key, this.task});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  Category? _selectedCategory;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _initializeFormWithTask(widget.task!);
    }
  }

  void _initializeFormWithTask(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _selectedPriority = task.priority;
    _selectedDueDate = task.dueDate;
    // カテゴリは後でasyncで設定
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'タスクを追加' : 'タスクを編集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTask,
            child: Text(
              '保存',
              style: TextStyle(
                color: _isLoading
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // タイトル入力
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'タイトルを入力してください';
                }
                if (value.trim().length > 100) {
                  return 'タイトルは100文字以内で入力してください';
                }
                return null;
              },
              maxLength: 100,
            ),

            const SizedBox(height: 16),

            // 説明入力
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return '説明は500文字以内で入力してください';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 優先度選択
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '優先度',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: TaskPriority.values.map((priority) {
                        return ChoiceChip(
                          label: Text(priority.label),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // カテゴリ選択
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'カテゴリ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) {
                        // 初回読み込み時にカテゴリを設定
                        if (widget.task != null &&
                            widget.task!.category.isNotEmpty &&
                            _selectedCategory == null) {
                          _selectedCategory = categories
                              .where((c) => c.name == widget.task!.category)
                              .firstOrNull;
                        }

                        return Wrap(
                          spacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('なし'),
                              selected: _selectedCategory == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                }
                              },
                            ),
                            ...categories.map((category) => ChoiceChip(
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
                                  selected:
                                      _selectedCategory?.id == category.id,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory =
                                          selected ? category : null;
                                    });
                                  },
                                )),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('エラー: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 期限設定
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '期限',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDueDate == null
                                ? '期限なし'
                                : '${_selectedDueDate!.year}/${_selectedDueDate!.month}/${_selectedDueDate!.day}',
                          ),
                        ),
                        if (_selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDueDate = null;
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDueDate,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final task = Task(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _selectedCategory?.name ?? 'その他',
        dueDate: _selectedDueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        completedAt: widget.task?.completedAt,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.task == null) {
        // 新規作成
        final useCase = ref.read(createTaskUseCaseProvider);
        await useCase(task);
      } else {
        // 更新
        final useCase = ref.read(updateTaskUseCaseProvider);
        await useCase(task);
      }

      // プロバイダーを更新
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(tasksProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task == null ? 'タスクを追加しました' : 'タスクを更新しました'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
