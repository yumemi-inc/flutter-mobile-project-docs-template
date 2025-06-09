# TODO アプリケーション 技術仕様書

## 1. 技術概要

### 1.1 技術スタック

- **フレームワーク**: Flutter 3.22.2
- **言語**: Dart 3.4.3
- **状態管理**:　Riverpod
- **データベース**: SQLite (sqflite)
- **ローカルストレージ**: shared_preferences
- **通知**: flutter_local_notifications
- **日付処理**: intl
- **UUID生成**: uuid
- **テスト**: flutter_test, mockito

### 1.2 開発環境

- **IDE**: Android Studio / VS Code
- **最小対応バージョン**:
  - iOS: 12.0+
  - Android: API Level 21 (Android 5.0)+
- **Dart SDK**: 3.2.0以上
- **Flutter SDK**: 3.16.0以上

### 1.3 プロジェクト構成

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── theme/
├── core/
│   ├── constants/
│   ├── utils/
│   ├── errors/
│   └── extensions/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   └── database/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── providers/
│   └── controllers/
└── shared/
    ├── widgets/
    └── utils/
```

## 2. アーキテクチャ設計

### 2.1 Clean Architecture

本アプリケーションは Clean Architecture パターンを採用し、以下の層に分離します：

#### 2.1.1 Presentation Layer (プレゼンテーション層)

- **責務**: UI表示、ユーザーインタラクション、状態管理
- **構成要素**:
  - Pages: 画面コンポーネント
  - Widgets: 再利用可能なUIコンポーネント
  - Providers: 状態管理（Riverpod）
  - Controllers: ビジネスロジックとUIの橋渡し

#### 2.1.2 Domain Layer (ドメイン層)

- **責務**: ビジネスルール、エンティティ定義、ユースケース
- **構成要素**:
  - Entities: ビジネスオブジェクト
  - Repositories: データアクセスの抽象化
  - Use Cases: ビジネスロジックの実装

#### 2.1.3 Data Layer (データ層)

- **責務**: データ永続化、外部API連携、キャッシュ管理
- **構成要素**:
  - Data Sources: データの取得・保存
  - Models: データ転送オブジェクト
  - Repositories: Domainで定義したインターフェースの実装

### 2.2 依存性注入

Riverpod を使用した依存性注入を実装し、テスタビリティと保守性を向上させます。

```dart
// providers.dart
final databaseProvider = Provider<Database>((ref) => DatabaseImpl());
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.read(databaseProvider));
});
final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.read(taskRepositoryProvider));
});
```

## 3. データベース設計

### 3.1 SQLite スキーマ

#### 3.1.1 tasks テーブル

```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  priority INTEGER NOT NULL DEFAULT 1,
  category_id TEXT,
  due_date INTEGER,
  is_completed INTEGER NOT NULL DEFAULT 0,
  completed_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id)
);

CREATE INDEX idx_tasks_is_completed ON tasks (is_completed);
CREATE INDEX idx_tasks_due_date ON tasks (due_date);
CREATE INDEX idx_tasks_created_at ON tasks (created_at);
CREATE INDEX idx_tasks_category_id ON tasks (category_id);
```

#### 3.1.2 categories テーブル

```sql
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  color_value INTEGER NOT NULL,
  icon_code_point INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

#### 3.1.3 notifications テーブル

```sql
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL,
  notification_type TEXT NOT NULL,
  scheduled_time INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
);

CREATE INDEX idx_notifications_task_id ON notifications (task_id);
CREATE INDEX idx_notifications_scheduled_time ON notifications (scheduled_time);
```

### 3.2 データアクセス層

#### 3.2.1 Database Helper

```dart
class DatabaseHelper {
  static const String _dbName = 'todo_app.db';
  static const int _dbVersion = 1;
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority INTEGER NOT NULL DEFAULT 1,
        category_id TEXT,
        due_date INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        notification_type TEXT NOT NULL,
        scheduled_time INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
    
    // インデックス作成
    await db.execute('CREATE INDEX idx_tasks_is_completed ON tasks (is_completed)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks (due_date)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks (created_at)');
    await db.execute('CREATE INDEX idx_tasks_category_id ON tasks (category_id)');
    await db.execute('CREATE INDEX idx_notifications_task_id ON notifications (task_id)');
    await db.execute('CREATE INDEX idx_notifications_scheduled_time ON notifications (scheduled_time)');
    
    // デフォルトカテゴリの挿入
    await _insertDefaultCategories(db);
  }
}
```

## 4. エンティティ・モデル設計

### 4.1 Domain Entities

#### 4.1.1 Task Entity

```dart
class Task {
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
}

enum TaskPriority {
  low(1, 'Low'),
  medium(2, 'Medium'),
  high(3, 'High');

  const TaskPriority(this.value, this.label);
  final int value;
  final String label;
}
```

#### 4.1.2 Category Entity

```dart
class Category {
  final String id;
  final String name;
  final Color color;
  final IconData? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? name,
    Color? color,
    IconData? icon,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
```

### 4.2 Data Models

#### 4.2.1 Task Model

```dart
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
      dueDate: dueDate != null ? DateTime.fromMillisecondsSinceEpoch(dueDate!) : null,
      isCompleted: isCompleted == 1,
      completedAt: completedAt != null ? DateTime.fromMillisecondsSinceEpoch(completedAt!) : null,
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
```

## 5. 状態管理

### 5.1 Riverpod Providers

#### 5.1.1 Task State Management

```dart
@riverpod
class TaskNotifier extends _$TaskNotifier {
  @override
  Future<List<Task>> build() async {
    final repository = ref.read(taskRepositoryProvider);
    return await repository.getAllTasks();
  }

  Future<void> addTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.createTask(task);
    ref.invalidateSelf();
  }

  Future<void> updateTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.updateTask(task);
    ref.invalidateSelf();
  }

  Future<void> deleteTask(String taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.deleteTask(taskId);
    ref.invalidateSelf();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    final tasks = await future;
    final task = tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    await repository.updateTask(updatedTask);
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<Task>> filteredTasks(
  FilteredTasksRef ref, {
  String? categoryId,
  TaskPriority? priority,
  bool? isCompleted,
  String? searchQuery,
}) async {
  final tasks = await ref.watch(taskNotifierProvider.future);
  
  return tasks.where((task) {
    if (categoryId != null && task.categoryId != categoryId) return false;
    if (priority != null && task.priority != priority) return false;
    if (isCompleted != null && task.isCompleted != isCompleted) return false;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      if (!task.title.toLowerCase().contains(query) &&
          !(task.description?.toLowerCase().contains(query) ?? false)) {
        return false;
      }
    }
    return true;
  }).toList();
}
```

### 5.2 UI State Management

#### 5.2.1 App State

```dart
@riverpod
class AppSettings extends _$AppSettings {
  @override
  AppSettingsState build() {
    return const AppSettingsState();
  }

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _saveSettings();
  }

  void updateNotificationSettings(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _saveSettings();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', state.isDarkMode);
    await prefs.setBool('notifications_enabled', state.notificationsEnabled);
  }
}

class AppSettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String defaultNotificationTime;

  const AppSettingsState({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.defaultNotificationTime = '09:00',
  });

  AppSettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? defaultNotificationTime,
  }) {
    return AppSettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultNotificationTime: defaultNotificationTime ?? this.defaultNotificationTime,
    );
  }
}
```

## 6. 通知システム

### 6.1 Local Notifications

#### 6.1.1 Notification Service

```dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task due dates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      taskId.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: taskId,
    );
  }

  static Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
```

### 6.2 Notification Scheduling

#### 6.2.1 Task Notification Manager

```dart
class TaskNotificationManager {
  final NotificationRepository _notificationRepository;
  final TaskRepository _taskRepository;

  TaskNotificationManager(
    this._notificationRepository,
    this._taskRepository,
  );

  Future<void> scheduleTaskNotifications(Task task) async {
    if (task.dueDate == null) return;

    // 既存の通知をキャンセル
    await cancelTaskNotifications(task.id);

    final notifications = <TaskNotification>[];

    // 1日前の通知
    final oneDayBefore = task.dueDate!.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      notifications.add(TaskNotification(
        id: '${task.id}_1day',
        taskId: task.id,
        type: NotificationType.oneDayBefore,
        scheduledTime: oneDayBefore,
      ));
    }

    // 1時間前の通知
    final oneHourBefore = task.dueDate!.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(DateTime.now())) {
      notifications.add(TaskNotification(
        id: '${task.id}_1hour',
        taskId: task.id,
        type: NotificationType.oneHourBefore,
        scheduledTime: oneHourBefore,
      ));
    }

    // 当日の通知
    if (task.dueDate!.isAfter(DateTime.now())) {
      notifications.add(TaskNotification(
        id: '${task.id}_due',
        taskId: task.id,
        type: NotificationType.dueDate,
        scheduledTime: task.dueDate!,
      ));
    }

    // 通知をスケジュール
    for (final notification in notifications) {
      await NotificationService.scheduleTaskReminder(
        taskId: notification.id,
        title: 'Task Reminder',
        body: task.title,
        scheduledTime: notification.scheduledTime,
      );
      await _notificationRepository.saveNotification(notification);
    }
  }

  Future<void> cancelTaskNotifications(String taskId) async {
    final notifications = await _notificationRepository.getNotificationsByTaskId(taskId);
    for (final notification in notifications) {
      await NotificationService.cancelNotification(notification.id);
      await _notificationRepository.deleteNotification(notification.id);
    }
  }
}
```

## 7. セキュリティ

### 7.1 データ暗号化

#### 7.1.1 Sensitive Data Protection

```dart
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> storeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### 7.2 アプリロック機能

#### 7.2.1 Biometric Authentication

```dart
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

## 8. エラーハンドリング

### 8.1 カスタム例外クラス

#### 8.1.1 App Exceptions

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException(
    this.message, {
    this.code,
    this.originalException,
  });

  @override
  String toString() => 'AppException: $message';
}

class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.code,
    super.originalException,
  });
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors = const {},
    super.code,
  });
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalException,
  });
}
```

### 8.2 Global Error Handler

#### 8.2.1 Error Boundary

```dart
class ErrorBoundary extends ConsumerWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorWidget.builder = (FlutterErrorDetails details) {
      // ログ出力
      _logError(details.exception, details.stack);
      
      // エラー画面表示
      return errorBuilder?.call(details.exception, details.stack!) ??
          DefaultErrorWidget(
            error: details.exception,
            stackTrace: details.stack!,
          );
    };
    
    return child;
  }

  void _logError(Object error, StackTrace? stackTrace) {
    // Firebase Crashlytics等にエラーを送信
    // 開発時はconsoleに出力
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
```

## 9. テスト戦略

### 9.1 単体テスト

#### 9.1.1 Repository Tests

```dart
void main() {
  group('TaskRepository', () {
    late TaskRepository repository;
    late MockDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockDatabase();
      repository = TaskRepositoryImpl(mockDatabase);
    });

    test('should create task successfully', () async {
      // Arrange
      final task = createTestTask();
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      // Act
      final result = await repository.createTask(task);

      // Assert
      expect(result, equals(task));
      verify(mockDatabase.insert('tasks', any)).called(1);
    });

    test('should throw DatabaseException when create fails', () async {
      // Arrange
      final task = createTestTask();
      when(mockDatabase.insert(any, any)).thenThrow(DatabaseException('Insert failed'));

      // Act & Assert
      expect(
        () => repository.createTask(task),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
```

### 9.2 ウィジェットテスト

#### 9.2.1 Task List Widget Tests

```dart
void main() {
  group('TaskListWidget', () {
    testWidgets('should display list of tasks', (tester) async {
      // Arrange
      final tasks = [
        createTestTask(title: 'Task 1'),
        createTestTask(title: 'Task 2'),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith((ref) => tasks),
          ],
          child: MaterialApp(
            home: TaskListWidget(),
          ),
        ),
      );

      // Assert
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('should handle task completion toggle', (tester) async {
      // Arrange
      final task = createTestTask(isCompleted: false);
      final mockNotifier = MockTaskNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskNotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: MaterialApp(
            home: TaskListWidget(),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      verify(mockNotifier.toggleTaskCompletion(task.id)).called(1);
    });
  });
}
```

### 9.3 統合テスト

#### 9.3.1 End-to-End Tests

```dart
void main() {
  group('Task Management E2E Tests', () {
    testWidgets('should create, edit, and delete task', (tester) async {
      // App起動
      await tester.pumpWidget(TodoApp());
      await tester.pumpAndSettle();

      // タスク作成
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('title_field')), 'Test Task');
      await tester.enterText(find.byKey(const Key('description_field')), 'Test Description');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // タスクが作成されたことを確認
      expect(find.text('Test Task'), findsOneWidget);

      // タスク編集
      await tester.tap(find.text('Test Task'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('title_field')), 'Updated Task');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // タスクが更新されたことを確認
      expect(find.text('Updated Task'), findsOneWidget);
      expect(find.text('Test Task'), findsNothing);

      // タスク削除
      await tester.drag(find.text('Updated Task'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete')); // 確認ダイアログ
      await tester.pumpAndSettle();

      // タスクが削除されたことを確認
      expect(find.text('Updated Task'), findsNothing);
    });
  });
}
```

## 10. パフォーマンス最適化

### 10.1 メモリ管理

#### 10.1.1 Lazy Loading

```dart
class TaskListProvider extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;
  final int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMoreData = true;

  TaskListProvider(this._repository) : super(const AsyncValue.loading()) {
    loadInitialTasks();
  }

  Future<void> loadInitialTasks() async {
    try {
      final tasks = await _repository.getTasks(offset: 0, limit: _pageSize);
      state = AsyncValue.data(tasks);
      _hasMoreData = tasks.length == _pageSize;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMoreTasks() async {
    if (!_hasMoreData || state.isLoading) return;

    final currentTasks = state.value ?? [];
    _currentPage++;

    try {
      final newTasks = await _repository.getTasks(
        offset: _currentPage * _pageSize,
        limit: _pageSize,
      );

      state = AsyncValue.data([...currentTasks, ...newTasks]);
      _hasMoreData = newTasks.length == _pageSize;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      _currentPage--; // ロールバック
    }
  }
}
```

### 10.2 UI最適化

#### 10.2.1 Efficient List Rendering

```dart
class TaskListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return tasksAsync.when(
      data: (tasks) => ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          // 最後のアイテムに近づいたら追加読み込み
          if (index == tasks.length - 2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(taskListProvider.notifier).loadMoreTasks();
            });
          }

          return TaskTile(
            key: ValueKey(tasks[index].id),
            task: tasks[index],
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            context.read<TaskNotifier>().toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.description != null ? Text(task.description!) : null,
        trailing: task.dueDate != null
            ? Text(DateFormat('MM/dd').format(task.dueDate!))
            : null,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskEditScreen(task: task),
            ),
          );
        },
      ),
    );
  }
}
```

## 11. 国際化対応

### 11.1 多言語サポート

#### 11.1.1 Localization Setup

```dart
// l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

#### 11.1.2 Localization Files

```json
// lib/l10n/app_en.arb
{
  "appTitle": "TODO App",
  "addTask": "Add Task",
  "editTask": "Edit Task",
  "taskTitle": "Task Title",
  "taskDescription": "Description",
  "dueDate": "Due Date",
  "priority": "Priority",
  "category": "Category",
  "save": "Save",
  "cancel": "Cancel",
  "delete": "Delete",
  "completed": "Completed",
  "pending": "Pending",
  "high": "High",
  "medium": "Medium",
  "low": "Low"
}
```

```json
// lib/l10n/app_ja.arb
{
  "appTitle": "TODOアプリ",
  "addTask": "タスクを追加",
  "editTask": "タスクを編集",
  "taskTitle": "タスクタイトル",
  "taskDescription": "説明",
  "dueDate": "期限",
  "priority": "優先度",
  "category": "カテゴリ",
  "save": "保存",
  "cancel": "キャンセル",
  "delete": "削除",
  "completed": "完了済み",
  "pending": "未完了",
  "high": "高",
  "medium": "中",
  "low": "低"
}
```

## 12. ビルド・デプロイ

### 12.1 Build Configuration

#### 12.1.1 Flavors設定

```dart
// lib/main.dart
void main() {
  runApp(TodoApp(flavor: AppFlavor.production));
}

enum AppFlavor {
  development,
  staging,
  production,
}

class TodoApp extends StatelessWidget {
  final AppFlavor flavor;

  const TodoApp({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_getConfig(flavor)),
      ],
      child: MaterialApp(
        title: _getAppTitle(flavor),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }

  AppConfig _getConfig(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.development:
        return AppConfig.development();
      case AppFlavor.staging:
        return AppConfig.staging();
      case AppFlavor.production:
        return AppConfig.production();
    }
  }

  String _getAppTitle(AppFlavor flavor) {
    switch (flavor) {
      case AppFlavor.development:
        return 'TODO App (Dev)';
      case AppFlavor.staging:
        return 'TODO App (Staging)';
      case AppFlavor.production:
        return 'TODO App';
    }
  }
}
```

### 12.2 CI/CD Pipeline

#### 12.2.1 GitHub Actions

```yaml
# .github/workflows/build_and_test.yml
name: Build and Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  build_android:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build_ios:
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
```

## 13. まとめ

本技術仕様書では、Flutter を使用したTODOアプリケーションの包括的な技術実装方針を定義しました。Clean Architecture パターンの採用により、保守性とテスタビリティを確保し、Riverpod による効率的な状態管理、SQLite による信頼性の高いデータ永続化、そして包括的なテスト戦略により、高品質なモバイルアプリケーションの構築を実現します。

段階的な開発アプローチと継続的インテグレーション・デプロイメントにより、安定したリリースサイクルを確立し、ユーザーニーズに迅速に対応できるアプリケーションを提供します。
