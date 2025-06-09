# TODO アプリケーション データアクセス仕様書

## 1. 概要

### 1.1 目的

TODO アプリケーションのローカルデータアクセスAPIの仕様を定義

### 1.2 アーキテクチャ

- **データアクセス層**: Repository パターンによるSQLiteデータベースアクセス
- **データ形式**: Dart オブジェクト、JSON（エクスポート用）
- **データベース**: SQLite（ローカル）

### 1.3 バージョニング

- **API**: セマンティックバージョニング
- **データベーススキーマ**: マイグレーションベースバージョニング

## 2. データアクセスAPI

### 2.1 Task Repository API

#### 2.1.1 TaskRepository Interface

```dart
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
```

#### 2.1.2 メソッド詳細

##### getAllTasks()

すべてのタスクを取得

**シグネチャ**:

```dart
Future<List<Task>> getAllTasks()
```

**戻り値**:

- `List<Task>`: すべてのタスクのリスト
- 完了状態と作成日時で並び替え済み

**例外**:

- `DatabaseException`: データベースアクセスエラー

##### getTaskById(String id)

指定されたIDのタスクを取得

**シグネチャ**:

```dart
Future<Task?> getTaskById(String id)
```

**パラメータ**:

- `id` (String): タスクID

**戻り値**:

- `Task?`: 該当するタスク、見つからない場合はnull

**例外**:

- `DatabaseException`: データベースアクセスエラー
- `ValidationException`: 無効なID形式

##### createTask(Task task)

新しいタスクを作成

**シグネチャ**:

```dart
Future<Task> createTask(Task task)
```

**パラメータ**:

- `task` (Task): 作成するタスクオブジェクト

**戻り値**:

- `Task`: 作成されたタスク（IDと作成日時が設定済み）

**例外**:

- `ValidationException`: 必須フィールドが未設定
- `DatabaseException`: データベース書き込みエラー

##### updateTask(Task task)

既存のタスクを更新

**シグネチャ**:

```dart
Future<Task> updateTask(Task task)
```

**パラメータ**:

- `task` (Task): 更新するタスクオブジェクト

**戻り値**:

- `Task`: 更新されたタスク（更新日時が設定済み）

**例外**:

- `ValidationException`: 必須フィールドが未設定
- `NotFoundException`: 指定されたIDのタスクが存在しない
- `DatabaseException`: データベース書き込みエラー

##### deleteTask(String id)

指定されたIDのタスクを削除

**シグネチャ**:

```dart
Future<void> deleteTask(String id)
```

**パラメータ**:

- `id` (String): 削除するタスクのID

**例外**:

- `NotFoundException`: 指定されたIDのタスクが存在しない
- `DatabaseException`: データベース削除エラー

##### searchTasks(String query)

テキスト検索でタスクを取得

**シグネチャ**:

```dart
Future<List<Task>> searchTasks(String query)
```

**パラメータ**:

- `query` (String): 検索クエリ（タイトル・説明を対象）

**戻り値**:

- `List<Task>`: 検索条件に合致するタスクのリスト

**例外**:

- `DatabaseException`: データベースアクセスエラー

### 2.2 Category Repository API

#### 2.2.1 CategoryRepository Interface

```dart
abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getDefaultCategories();
}
```

#### 2.2.2 メソッド詳細

##### getAllCategories()

すべてのカテゴリを取得

**シグネチャ**:

```dart
Future<List<Category>> getAllCategories()
```

**戻り値**:

- `List<Category>`: すべてのカテゴリのリスト
- 作成日時で並び替え済み

##### createCategory(Category category)

新しいカテゴリを作成

**シグネチャ**:

```dart
Future<Category> createCategory(Category category)
```

**パラメータ**:

- `category` (Category): 作成するカテゴリオブジェクト

**戻り値**:

- `Category`: 作成されたカテゴリ

**バリデーション**:

- 名前の重複チェック
- 名前の文字数制限（1-20文字）

## 3. データ転送オブジェクト (DTO)

### 3.1 Task DTO

```dart
class TaskDto {
  final String id;
  final String title;
  final String? description;
  final int priority;
  final String? categoryId;
  final String? dueDate; // ISO 8601 format
  final bool isCompleted;
  final String? completedAt; // ISO 8601 format
  final String createdAt; // ISO 8601 format
  final String updatedAt; // ISO 8601 format

  const TaskDto({
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

  Map<String, dynamic> toJson() => {
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

  factory TaskDto.fromJson(Map<String, dynamic> json) => TaskDto(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    priority: json['priority'] as int,
    categoryId: json['category_id'] as String?,
    dueDate: json['due_date'] as String?,
    isCompleted: json['is_completed'] as bool,
    completedAt: json['completed_at'] as String?,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );
}
```

### 3.2 Category DTO

```dart
class CategoryDto {
  final String id;
  final String name;
  final int colorValue;
  final int? iconCodePoint;
  final String createdAt; // ISO 8601 format
  final String updatedAt; // ISO 8601 format

  const CategoryDto({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCodePoint,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color_value': colorValue,
    'icon_code_point': iconCodePoint,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
    id: json['id'] as String,
    name: json['name'] as String,
    colorValue: json['color_value'] as int,
    iconCodePoint: json['icon_code_point'] as int?,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );
}
```

### 3.3 Response DTO

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final int timestamp;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data,
    'message': message,
    'error': error,
    'timestamp': timestamp,
  };

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    success: json['success'] as bool,
    data: json['data'],
    message: json['message'] as String?,
    error: json['error'] as String?,
    timestamp: json['timestamp'] as int,
  );

  factory ApiResponse.success({T? data, String? message}) => ApiResponse(
    success: true,
    data: data,
    message: message,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );

  factory ApiResponse.error({required String error}) => ApiResponse(
    success: false,
    error: error,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );
}
```

## 4. データエクスポート・インポート

### 4.1 エクスポート機能

#### 4.1.1 全データエクスポート

```dart
abstract class DataExportRepository {
  Future<String> exportAllData();
  Future<String> exportTasks();
  Future<String> exportCategories();
}
```

**戻り値**:

- JSON形式の文字列データ

**エクスポートフォーマット**:

```json
{
  "export_info": {
    "version": "1.0",
    "timestamp": "2024-01-01T10:00:00Z",
    "total_tasks": 25,
    "total_categories": 4
  },
  "tasks": [
    {
      "id": "uuid-v4",
      "title": "Sample Task",
      "description": "Task description",
      "priority": 2,
      "category_id": "uuid-v4",
      "due_date": "2024-01-15T09:00:00Z",
      "is_completed": false,
      "completed_at": null,
      "created_at": "2024-01-01T10:00:00Z",
      "updated_at": "2024-01-01T10:00:00Z"
    }
  ],
  "categories": [
    {
      "id": "uuid-v4",
      "name": "Work",
      "color_value": 4280391411,
      "icon_code_point": 57415,
      "created_at": "2024-01-01T10:00:00Z",
      "updated_at": "2024-01-01T10:00:00Z"
    }
  ]
}
```

### 4.2 インポート機能

#### 4.2.1 データインポート

```dart
abstract class DataImportRepository {
  Future<ImportResult> importData(String jsonData);
  Future<ImportResult> importTasks(String jsonData);
  Future<ImportResult> importCategories(String jsonData);
}

class ImportResult {
  final bool success;
  final int tasksImported;
  final int categoriesImported;
  final List<String> errors;
  final List<String> warnings;
  
  const ImportResult({
    required this.success,
    required this.tasksImported,
    required this.categoriesImported,
    required this.errors,
    required this.warnings,
  });
}
```

## 5. エラーハンドリング

### 5.1 例外クラス

| 例外クラス | 説明 |
|-----------|------|
| DatabaseException | データベースアクセスエラー |
| ValidationException | バリデーションエラー |
| NotFoundException | リソースが見つからない |
| DuplicateException | 重複データエラー |

### 5.2 エラーレスポンス

```dart
class RepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const RepositoryException(
    this.message, {
    this.code,
    this.originalException,
  });
}

## 6. バリデーション

### 6.1 タスクバリデーション

```dart
class TaskValidator {
  static ValidationResult validate(TaskDto task) {
    final errors = <String, List<String>>{};

    // タイトル検証
    if (task.title.isEmpty) {
      errors['title'] = ['Title is required'];
    } else if (task.title.length > 100) {
      errors['title'] = ['Title must be 100 characters or less'];
    }

    // 説明検証
    if (task.description != null && task.description!.length > 500) {
      errors['description'] = ['Description must be 500 characters or less'];
    }

    // 優先度検証
    if (task.priority < 1 || task.priority > 3) {
      errors['priority'] = ['Priority must be between 1 and 3'];
    }

    // 期限検証
    if (task.dueDate != null) {
      final dueDate = DateTime.tryParse(task.dueDate!);
      if (dueDate == null) {
        errors['due_date'] = ['Due date must be a valid ISO 8601 date'];
      } else if (dueDate.isBefore(DateTime.now())) {
        errors['due_date'] = ['Due date must be in the future'];
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final Map<String, List<String>> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
}
```

### 6.2 カテゴリバリデーション

```dart
class CategoryValidator {
  static ValidationResult validate(CategoryDto category) {
    final errors = <String, List<String>>{};

    // 名前検証
    if (category.name.isEmpty) {
      errors['name'] = ['Name is required'];
    } else if (category.name.length > 20) {
      errors['name'] = ['Name must be 20 characters or less'];
    }

    // 色値検証
    if (category.colorValue < 0 || category.colorValue > 4294967295) {
      errors['color_value'] = ['Invalid color value'];
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

## 7. パフォーマンス最適化

### 7.1 キャッシュ戦略

#### 7.1.1 メモリキャッシュ

```dart
class MemoryCache<T> {
  final Map<String, CacheEntry<T>> _cache = {};
  final Duration _ttl;

  MemoryCache({Duration ttl = const Duration(minutes: 5)}) : _ttl = ttl;

  void put(String key, T value) {
    _cache[key] = CacheEntry(
      value: value,
      expiry: DateTime.now().add(_ttl),
    );
  }

  T? get(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  void clear() {
    _cache.clear();
  }
}

class CacheEntry<T> {
  final T value;
  final DateTime expiry;

  CacheEntry({required this.value, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
```

#### 7.1.2 キャッシュ適用API

```dart
class CachedTaskRepository implements TaskRepository {
  final TaskRepository _repository;
  final MemoryCache<List<Task>> _listCache;
  final MemoryCache<Task> _itemCache;

  CachedTaskRepository(this._repository)
      : _listCache = MemoryCache(ttl: const Duration(minutes: 2)),
        _itemCache = MemoryCache(ttl: const Duration(minutes: 5));

  @override
  Future<List<Task>> getAllTasks() async {
    const cacheKey = 'all_tasks';
    final cached = _listCache.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    final tasks = await _repository.getAllTasks();
    _listCache.put(cacheKey, tasks);
    return tasks;
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final cached = _itemCache.get(id);
    if (cached != null) {
      return cached;
    }

    final task = await _repository.getTaskById(id);
    if (task != null) {
      _itemCache.put(id, task);
    }
    return task;
  }

  @override
  Future<Task> createTask(Task task) async {
    final result = await _repository.createTask(task);
    _listCache.clear(); // リストキャッシュをクリア
    _itemCache.put(result.id, result);
    return result;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final result = await _repository.updateTask(task);
    _listCache.clear(); // リストキャッシュをクリア
    _itemCache.put(result.id, result);
    return result;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
    _listCache.clear(); // リストキャッシュをクリア
    _itemCache.get(id); // アイテムキャッシュから削除
  }
}
```

### 7.2 バッチ処理

#### 7.2.1 バッチ更新API

```dart
abstract class BatchRepository {
  Future<List<Task>> batchCreateTasks(List<Task> tasks);
  Future<List<Task>> batchUpdateTasks(List<Task> tasks);
  Future<void> batchDeleteTasks(List<String> taskIds);
}

class BatchRepositoryImpl implements BatchRepository {
  final Database _database;

  BatchRepositoryImpl(this._database);

  @override
  Future<List<Task>> batchCreateTasks(List<Task> tasks) async {
    final batch = _database.batch();
    final createdTasks = <Task>[];

    for (final task in tasks) {
      final taskModel = TaskModel.fromDomain(task);
      batch.insert('tasks', taskModel.toMap());
      createdTasks.add(task);
    }

    await batch.commit(noResult: true);
    return createdTasks;
  }

  @override
  Future<List<Task>> batchUpdateTasks(List<Task> tasks) async {
    final batch = _database.batch();
    final updatedTasks = <Task>[];

    for (final task in tasks) {
      final taskModel = TaskModel.fromDomain(task);
      batch.update(
        'tasks',
        taskModel.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      updatedTasks.add(task);
    }

    await batch.commit(noResult: true);
    return updatedTasks;
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    final batch = _database.batch();

    for (final id in taskIds) {
      batch.delete('tasks', where: 'id = ?', whereArgs: [id]);
    }

    await batch.commit(noResult: true);
  }
}
```

## 8. モニタリング・ログ

### 8.1 APIメトリクス

```dart
class ApiMetrics {
  static final Map<String, int> _requestCounts = {};
  static final Map<String, List<int>> _responseTimes = {};

  static void recordRequest(String endpoint) {
    _requestCounts[endpoint] = (_requestCounts[endpoint] ?? 0) + 1;
  }

  static void recordResponseTime(String endpoint, int milliseconds) {
    _responseTimes[endpoint] ??= [];
    _responseTimes[endpoint]!.add(milliseconds);
  }

  static Map<String, dynamic> getMetrics() {
    return {
      'request_counts': _requestCounts,
      'average_response_times': _responseTimes.map(
        (endpoint, times) => MapEntry(
          endpoint,
          times.isEmpty ? 0 : times.reduce((a, b) => a + b) / times.length,
        ),
      ),
    };
  }
}
```

### 8.2 エラーログ

```dart
class ApiLogger {
  static void logError(String endpoint, Object error, StackTrace stackTrace) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': 'ERROR',
      'endpoint': endpoint,
      'error': error.toString(),
      'stack_trace': stackTrace.toString(),
    };

    // 開発環境ではコンソール出力
    if (kDebugMode) {
      print('API Error: ${jsonEncode(logEntry)}');
    }

    // 本番環境では外部ログサービスに送信
    // _sendToLogService(logEntry);
  }

  static void logInfo(String endpoint, String message) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': 'INFO',
      'endpoint': endpoint,
      'message': message,
    };

    if (kDebugMode) {
      print('API Info: ${jsonEncode(logEntry)}');
    }
  }
}
```

## 9. まとめ

本データアクセス仕様書では、TODO アプリケーションのローカルデータアクセス層の包括的な設計を定義しました。Repository パターンに基づいた設計により、データアクセスの抽象化と保守性を確保し、SQLiteデータベースを使用した効率的なローカルストレージ、パフォーマンス最適化とエラーハンドリングを適切に実装することで、信頼性の高いオフラインアプリケーションを構築します。

完全ローカル動作により、ネットワーク接続に依存せず、ユーザーのプライバシーを保護しながら、高速で安定したタスク管理体験を提供します。
