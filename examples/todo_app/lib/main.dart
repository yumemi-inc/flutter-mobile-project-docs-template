import 'package:flutter/material.dart';
import 'models/todo.dart';
import 'services/todo_service.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoHomePage(title: 'TODO App'),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key, required this.title});

  final String title;

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await _todoService.getAllTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    }
  }

  Future<void> _addTodo() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新しいTODOを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  hintText: 'TODOのタイトルを入力',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  hintText: 'TODOの説明を入力（任意）',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        await _todoService.addTodo(
          titleController.text.trim(),
          descriptionController.text.trim(),
        );
        _loadTodos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TODOを追加しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('追加に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleTodoCompletion(Todo todo) async {
    try {
      await _todoService.toggleTodoCompletion(todo);
      _loadTodos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('TODOを削除'),
          content: Text('「${todo.title}」を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && todo.id != null) {
      try {
        await _todoService.deleteTodo(todo.id!);
        _loadTodos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TODOを削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingTodos = _todos.where((todo) => !todo.isCompleted).toList();
    final completedTodos = _todos.where((todo) => todo.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTodos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 統計情報
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${_todos.length}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('合計'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${pendingTodos.length}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('未完了'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${completedTodos.length}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const Text('完了'),
                        ],
                      ),
                    ],
                  ),
                ),
                // TODOリスト
                Expanded(
                  child: _todos.isEmpty
                      ? const Center(
                          child: Text(
                            'TODOがありません\n「+」ボタンで追加してください',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView(
                          children: [
                            if (pendingTodos.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '未完了のTODO',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...pendingTodos
                                  .map((todo) => _buildTodoItem(todo)),
                            ],
                            if (completedTodos.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '完了済みのTODO',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...completedTodos
                                  .map((todo) => _buildTodoItem(todo)),
                            ],
                          ],
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        tooltip: 'TODOを追加',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => _toggleTodoCompletion(todo),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: todo.description.isNotEmpty
            ? Text(
                todo.description,
                style: TextStyle(
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${todo.createdAt.month}/${todo.createdAt.day}',
              style: TextStyle(
                fontSize: 12,
                color: todo.isCompleted ? Colors.grey : Colors.grey[600],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteTodo(todo),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
