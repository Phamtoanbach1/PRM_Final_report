import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/boats.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('boats.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE boats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        capacity INTEGER,
        pricePerDay REAL,
        availableFrom TEXT,
        availableTo TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');

    // Insert dữ liệu mẫu
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    final now = DateTime.now();
    final boats = [
      Boat(
        name: "Thuyền du lịch Sài Gòn",
        description: "Thuyền gỗ đẹp, view sông Sài Gòn",
        imageUrl: "https://example.com/boat1.jpg",
        capacity: 12,
        pricePerDay: 3500000,
        availableFrom: now,
        availableTo: now.add(Duration(days: 60)),
      ),
      Boat(
        name: "Du thuyền 5 sao",
        description: "Sang trọng, có điều hòa, karaoke",
        imageUrl: "https://example.com/boat2.jpg",
        capacity: 30,
        pricePerDay: 12000000,
        availableFrom: now.add(Duration(days: 5)),
        availableTo: now.add(Duration(days: 90)),
      ),
      // thêm 3-4 thuyền nữa...
    ];

    for (var boat in boats) {
      await db.insert('boats', boat.toMap());
    }
  }

  // CRUD
  Future<List<Boat>> getAllBoats() async {
    final db = await database;
    final maps = await db.query('boats');
    return List.generate(maps.length, (i) => Boat.fromMap(maps[i]));
  }

  Future<List<Boat>> searchBoats({
    DateTime? date,
    int? minCapacity,
  }) async {
    final db = await database;
    List<String> where = [];
    List<dynamic> args = [];

    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      where.add('availableFrom <= ? AND availableTo >= ?');
      args.addAll([dateStr, dateStr]);
    }

    if (minCapacity != null && minCapacity > 0) {
      where.add('capacity >= ?');
      args.add(minCapacity);
    }

    final whereClause = where.isEmpty ? null : where.join(' AND ');

    final maps = await db.query(
      'boats',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
    );

    return List.generate(maps.length, (i) => Boat.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(int id, bool value) async {
    final db = await database;
    await db.update(
      'boats',
      {'isFavorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<List<Boat>> searchBoatsByName(String query) async {
    final db = await database;
    final maps = await db.query(
      'boats',
      where: 'LOWER(name) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
    );
    return List.generate(maps.length, (i) => Boat.fromMap(maps[i]));
  }
// Thêm các hàm insert, update, delete nếu cần admin
}