import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';
import '../../domain/entities/category.dart';

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

    // インデックス作成
    await db
        .execute('CREATE INDEX idx_tasks_is_completed ON tasks (is_completed)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks (due_date)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks (created_at)');
    await db
        .execute('CREATE INDEX idx_tasks_category_id ON tasks (category_id)');

    // デフォルトカテゴリの挿入
    await _insertDefaultCategories(db);
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // 今後のマイグレーション処理
  }

  static Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = CategoryFactory.getDefaultCategories();

    for (final category in defaultCategories) {
      final categoryModel = CategoryModel.fromDomain(category);
      await db.insert('categories', categoryModel.toMap());
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
