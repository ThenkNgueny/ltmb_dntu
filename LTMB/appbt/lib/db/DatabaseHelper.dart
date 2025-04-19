import '../model/Note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          priority INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          modifiedAt TEXT NOT NULL,
          tags TEXT,
          color TEXT
        )
      ''');

    // Thêm dữ liệu mẫu
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    final List<Map<String, dynamic>> sampleNotes = [
      {
        'title': 'Mua sắm cuối tuần',
        'content': 'Mua sữa, bánh mì, trứng và rau xanh.',
        'priority': 2,
        'createdAt': DateTime.now().toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'tags': 'mua sắm,thực phẩm',
        'color': '#FF5733',
      },
      {
        'title': 'Báo cáo công việc',
        'content': 'Chuẩn bị báo cáo cho cuộc họp thứ Hai.',
        'priority': 3,
        'createdAt': DateTime.now().toIso8601String(),
        'modifiedAt': DateTime.now().toIso8601String(),
        'tags': 'công việc,báo cáo',
        'color': '#33FF57',
      }
    ];

    for (final note in sampleNotes) {
      await db.insert('notes', note);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Create - Thêm ghi chú mới
  Future<int> createNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Read - Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Read - Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update - Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete - Xóa ghi chú theo ID
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Delete - Xóa tất cả ghi chú
  Future<int> deleteAllNotes() async {
    final db = await instance.database;
    return await db.delete('notes');
  }

  // Lấy ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await instance.database;
    final result =
    await db.query('notes', where: 'priority = ?', whereArgs: [priority]);

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Đếm số lượng ghi chú
  Future<int> countNotes() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
