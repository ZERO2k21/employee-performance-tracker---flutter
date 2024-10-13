import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('employee_performance.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT,
        email TEXT,
        password TEXT,
        isAdmin INTEGER,
        address TEXT,
        phoneNumber TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        date TEXT,
        isPresent INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        task TEXT,
        status TEXT,
        rating REAL
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@example.com',
      'password': 'admin123', // Default password
      'isAdmin': 1,
      'address': '',
      'phoneNumber': '',
      'role': 'Administrator',
    });

    print('Default admin user inserted');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN address TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN phoneNumber TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT');
    }
  }

  Future<void> insertUser(String username, String email, String password, bool isAdmin, String address, String phoneNumber, String role) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'isAdmin': isAdmin ? 1 : 0,
      'address': address,
      'phoneNumber': phoneNumber,
      'role': role,
    });
  }

  Future<bool> validateUser(String username, String password, bool isAdmin) async {
    final db = await database;
    List<Map> result = await db.query('users',
        where: 'username = ? AND password = ? AND isAdmin = ?',
        whereArgs: [username, password, isAdmin ? 1 : 0]);

    return result.isNotEmpty;
  }

  Future<bool> isAdmin(String username) async {
    final db = await database;
    List<Map> result = await db.query('users',
        where: 'username = ? AND isAdmin = ?',
        whereArgs: [username, 1]);

    return result.isNotEmpty;
  }

  Future<void> insertAttendance(int userId, String date, bool isPresent) async {
    final db = await database;
    await db.insert('attendance', {
      'userId': userId,
      'date': date,
      'isPresent': isPresent ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAttendance(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT attendance.date, attendance.isPresent
      FROM attendance
      INNER JOIN users ON attendance.userId = users.id
      WHERE users.username = ?
    ''', [username]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAttendanceData() async {
    final db = await database;
    return await db.query('attendance');
  }

  Future<void> insertTask(int userId, String task, String status, double rating) async {
    final db = await database;
    await db.insert('tasks', {
      'userId': userId,
      'task': task,
      'status': status,
      'rating': rating,
    });
  }

  Future<List<Map<String, dynamic>>> getTasks(int userId) async {
    final db = await database;
    return await db.query('tasks', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    final db = await database;
    await db.update('tasks', {'status': status}, where: 'id = ?', whereArgs: [taskId]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPerformance(String username) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tasks.task, tasks.status, tasks.rating
      FROM tasks
      INNER JOIN users ON tasks.userId = users.id
      WHERE users.username = ?
    ''', [username]);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getAllUsersPerformance() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<void> updatePassword(String username, String newPassword) async {
    final db = await database;
    await db.update('users', {'password': newPassword}, where: 'username = ?', whereArgs: [username]);
  }

  Future<void> deleteDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'employee_performance.db');
    await databaseFactory.deleteDatabase(path);
    print('Database deleted');
  }

  Future<List<Map<String, dynamic>>> getTasksForUser(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT tasks.*
      FROM tasks
      INNER JOIN users ON tasks.userId = users.id
      WHERE users.username = ?
    ''', [username]);
    return result;
  }

  Future<bool> checkAttendanceForToday(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT attendance.*
      FROM attendance
      INNER JOIN users ON attendance.userId = users.id
      WHERE users.username = ? AND date = ?
    ''', [username, DateTime.now().toIso8601String().split('T')[0]]);
    return result.isNotEmpty;
  }

  Future<void> markAttendanceForToday(String username, bool isPresent) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO attendance (userId, date, isPresent)
      SELECT id, ?, ?
      FROM users
      WHERE username = ?
    ''', [DateTime.now().toIso8601String().split('T')[0], isPresent ? 1 : 0, username]);
  }

  Future<double> calculateTaskCompletionRate(String username) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT COUNT(*) as total, SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed
      FROM tasks
      INNER JOIN users ON tasks.userId = users.id
      WHERE users.username = ?
    ''', [username]);

    if (result.isNotEmpty) {
      int total = result[0]['total'];
      int completed = result[0]['completed'];
      return total > 0 ? completed / total : 0.0;
    } else {
      return 0.0;
    }
  }
}
