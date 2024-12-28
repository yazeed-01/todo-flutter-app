import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incremented version for migrations
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT,
        dueDate TEXT,
        tags TEXT,
        status TEXT NOT NULL DEFAULT 'inProgress',
        createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE tasks ADD COLUMN status TEXT NOT NULL DEFAULT "inProgress"');
      await db.execute(
          'ALTER TABLE tasks ADD COLUMN createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE reminders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          dateTime TEXT NOT NULL
        )
      ''');
    }
  }

  // Task-related methods

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', {
      ...task,
      'status': task['status'] ?? 'inProgress',
    });
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<Map<String, dynamic>> getTaskById(int id) async {
    final db = await database;
    final task = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (task.isNotEmpty) {
      return task.first;
    }
    return {};
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task,
      where: 'id = ?',
      whereArgs: [task['id']],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getTaskSummary() async {
    final db = await database;

    final totalTasks = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM tasks')) ??
        0;
    final completedTasks = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM tasks WHERE status = "completed"')) ??
        0;
    final inProgressTasks = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM tasks WHERE status = "inProgress"')) ??
        0;
    final overdueTasks = Sqflite.firstIntValue(await db
            .rawQuery('SELECT COUNT(*) FROM tasks WHERE status = "overdue"')) ??
        0;

    return {
      'total': totalTasks,
      'completed': completedTasks,
      'inProgress': inProgressTasks,
      'overdue': overdueTasks,
    };
  }

  // Settings-related methods

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  // Reminder-related methods

  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    final db = await database;
    return await db.insert('reminders', reminder);
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await database;
    return await db.query('reminders', orderBy: 'dateTime');
  }

  Future<int> updateReminder(Map<String, dynamic> reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder,
      where: 'id = ?',
      whereArgs: [reminder['id']],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
