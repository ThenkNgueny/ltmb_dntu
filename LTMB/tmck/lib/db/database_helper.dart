import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/task.dart';

// Lớp quản lý cơ sở dữ liệu SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static List<Task>? _taskCache; // Cache danh sách công việc

  DatabaseHelper._init();

  // Mở hoặc tạo cơ sở dữ liệu
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_manager.db');
    return _database!;
  }

  // Khởi tạo cơ sở dữ liệu và tạo bảng
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Bật hỗ trợ foreign key
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  // Tạo bảng users và tasks
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        avatar TEXT,
        createdAt TEXT NOT NULL,
        lastActive TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        priority INTEGER NOT NULL,
        dueDate TEXT,
        assignedTo TEXT,
        createdBy TEXT NOT NULL,
        completed INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        category TEXT,
        attachments TEXT,
        FOREIGN KEY (createdBy) REFERENCES users(id) ON DELETE NO ACTION,
        FOREIGN KEY (assignedTo) REFERENCES users(id) ON DELETE NO ACTION
      )
    ''');

    // Tạo index cho các trường thường xuyên truy vấn
    await db.execute('CREATE INDEX idx_tasks_assignedTo ON tasks(assignedTo)');
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');

    // Tạo tài khoản admin mặc định
    await db.insert('users', {
      'id': 'admin1',
      'username': 'admin',
      'password': 'admin123',
      'email': 'admin@example.com',
      'role': 'admin',
      'avatar': null,
      'createdAt': DateTime.now().toIso8601String(),
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  // Cập nhật lastActive khi người dùng đăng nhập
  Future<void> updateLastActive(String userId) async {
    final db = await database;
    await db.update(
      'users',
      {'lastActive': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Thêm người dùng
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Cập nhật người dùng
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Xóa người dùng
  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy thông tin người dùng theo username
  Future<User?> getUser(String username) async {
    final db = await database;
    final maps = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Lấy thông tin người dùng theo id
  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // Lấy danh sách tất cả người dùng (cho admin)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Thêm công việc
  Future<void> insertTask(Task task) async {
    final db = await database;
    // Kiểm tra createdBy tồn tại
    final creator = await getUserById(task.createdBy);
    if (creator == null) {
      throw Exception('Người tạo công việc không tồn tại: ${task.createdBy}');
    }
    // Kiểm tra assignedTo nếu không null
    if (task.assignedTo != null) {
      final assignee = await getUserById(task.assignedTo!);
      if (assignee == null) {
        throw Exception('Người được gán công việc không tồn tại: ${task.assignedTo}');
      }
    }
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _taskCache = null; // Xóa cache khi thêm công việc
  }

  // Cập nhật công việc
  Future<void> updateTask(Task task) async {
    final db = await database;
    // Kiểm tra createdBy tồn tại
    final creator = await getUserById(task.createdBy);
    if (creator == null) {
      throw Exception('Người tạo công việc không tồn tại: ${task.createdBy}');
    }
    // Kiểm tra assignedTo nếu không null
    if (task.assignedTo != null) {
      final assignee = await getUserById(task.assignedTo!);
      if (assignee == null) {
        throw Exception('Người được gán công việc không tồn tại: ${task.assignedTo}');
      }
    }
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    _taskCache = null; // Xóa cache khi cập nhật
  }

  // Xóa công việc
  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    _taskCache = null; // Xóa cache khi xóa
  }

  // Lấy danh sách công việc theo vai trò
  Future<List<Task>> getTasks(String userId, String role) async {
    if (_taskCache != null) return _taskCache!;
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (role == 'admin') {
      maps = await db.query('tasks');
    } else {
      maps = await db.query('tasks', where: 'assignedTo = ?', whereArgs: [userId]);
    }
    _taskCache = maps.map((map) => Task.fromMap(map)).toList();
    return _taskCache!;
  }

  // Tìm kiếm và lọc công việc
  Future<List<Task>> searchTasks(
      String userId,
      String role, {
        String? query,
        String? status,
        int? priority,
        DateTime? dueDateStart,
        DateTime? dueDateEnd,
      }) async {
    final db = await database;
    String whereClause = role == 'admin' ? '' : 'assignedTo = ?';
    List<dynamic> whereArgs = role == 'admin' ? [] : [userId];

    if (query != null && query.isNotEmpty) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + '(title LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }
    if (status != null) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + 'status = ?';
      whereArgs.add(status);
    }
    if (priority != null) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + 'priority = ?';
      whereArgs.add(priority);
    }
    if (dueDateStart != null && dueDateEnd != null) {
      whereClause += (whereClause.isEmpty ? '' : ' AND ') + 'dueDate BETWEEN ? AND ?';
      whereArgs.addAll([dueDateStart.toIso8601String(), dueDateEnd.toIso8601String()]);
    }

    final maps = await db.query('tasks', where: whereClause.isEmpty ? null : whereClause, whereArgs: whereArgs);
    _taskCache = maps.map((map) => Task.fromMap(map)).toList();
    return _taskCache!;
  }
}