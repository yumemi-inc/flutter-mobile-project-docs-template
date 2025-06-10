import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';
import '../../domain/entities/category.dart';

class DatabaseHelper {
  static const String _dbName = 'todo_app.db';
  static const int _dbVersion = 3;
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
        priority TEXT NOT NULL DEFAULT 'Medium',
        category TEXT NOT NULL DEFAULT 'その他',
        due_date DATETIME,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at DATETIME,
        reminder_date_time DATETIME,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        icon TEXT,
        is_preset INTEGER NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL
      )
    ''');

    // インデックス作成
    await db
        .execute('CREATE INDEX idx_tasks_is_completed ON tasks (is_completed)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks (due_date)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks (created_at)');
    await db.execute('CREATE INDEX idx_tasks_category ON tasks (category)');
    await db.execute(
        'CREATE INDEX idx_tasks_reminder_date_time ON tasks (reminder_date_time)');

    // デフォルトカテゴリの挿入
    await _insertDefaultCategories(db);

    // サンプルタスクの挿入
    await _insertSampleTasks(db);
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 古いテーブルをドロップして新しいスキーマで再作成
      await db.execute('DROP TABLE IF EXISTS tasks');
      await db.execute('DROP TABLE IF EXISTS categories');
      await _onCreate(db, newVersion);
    } else if (oldVersion < 3) {
      // バージョン2から3へのマイグレーション：reminder_date_timeカラムを追加
      await db
          .execute('ALTER TABLE tasks ADD COLUMN reminder_date_time DATETIME');
      await db.execute(
          'CREATE INDEX idx_tasks_reminder_date_time ON tasks (reminder_date_time)');
    }
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = CategoryFactory.getDefaultCategories();

    for (final category in defaultCategories) {
      final categoryModel = CategoryModel.fromDomain(category);
      await db.insert('categories', categoryModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static Future<void> _insertSampleTasks(Database db) async {
    final sampleTasks = [
      {
        'id': 'b2f30408-24a2-4883-a1e1-a0fa976bc80c',
        'title': 'プロジェクト企画書作成',
        'description': 'Q1の新プロジェクトの企画書を作成する',
        'priority': 'High',
        'category': '仕事',
        'due_date': '2024-01-15T17:00:00.000',
        'is_completed': 0,
        'completed_at': null,
        'reminder_date_time': '2024-01-14T09:00:00.000',
        'created_at': '2025-06-10T09:41:20.023',
        'updated_at': '2025-06-10T09:41:20.023',
      },
      {
        'id': 'c29f5167-3716-497a-9663-086a122aca16',
        'title': '歯医者予約',
        'description': '定期検診の予約を取る',
        'priority': 'Medium',
        'category': '健康',
        'due_date': '2024-01-10T12:00:00.000',
        'is_completed': 0,
        'completed_at': null,
        'reminder_date_time': null,
        'created_at': '2025-06-10T09:41:20.023',
        'updated_at': '2025-06-10T09:41:20.023',
      },
      {
        'id': '195a0361-d4d3-4126-b2ae-c4a6f31d5069',
        'title': '食材買い出し',
        'description': '今週の食材をスーパーで購入',
        'priority': 'Low',
        'category': '買い物',
        'due_date': '2024-01-08T19:00:00.000',
        'is_completed': 1,
        'completed_at': null,
        'reminder_date_time': null,
        'created_at': '2025-06-10T09:41:20.023',
        'updated_at': '2025-06-10T09:41:20.023',
      },
      {
        'id': 'f2413879-0c87-4d8e-b503-f75726ee3c1c',
        'title': '読書',
        'description': '技術書「Flutter実践入門」を読む',
        'priority': 'Medium',
        'category': '個人',
        'due_date': null,
        'is_completed': 0,
        'completed_at': null,
        'reminder_date_time': '2024-01-12T20:00:00.000',
        'created_at': '2025-06-10T09:41:20.023',
        'updated_at': '2025-06-10T09:41:20.023',
      },
      {
        'id': 'd97a018b-15f6-4339-9285-726c10c66c2e',
        'title': '運動',
        'description': '週3回のジョギングを継続する',
        'priority': 'High',
        'category': '健康',
        'due_date': null,
        'is_completed': 0,
        'completed_at': null,
        'reminder_date_time': null,
        'created_at': '2025-06-10T09:41:20.023',
        'updated_at': '2025-06-10T09:41:20.023',
      },
    ];

    for (final task in sampleTasks) {
      await db.insert('tasks', task,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
