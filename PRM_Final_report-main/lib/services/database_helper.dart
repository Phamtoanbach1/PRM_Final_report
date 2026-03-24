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
        imageUrl: "https://images.unsplash.com/photo-1567899378494-47b22a2ae96a",
        capacity: 12,
        pricePerDay: 3500000,
        availableFrom: now,
        availableTo: now.add(Duration(days: 60)),
      ),
      Boat(
        name: "Du thuyền 5 sao",
        description: "Sang trọng, có điều hòa, karaoke",
        imageUrl: "https://images.unsplash.com/photo-1541417904950-b855846fe074",
        capacity: 30,
        pricePerDay: 12000000,
        availableFrom: now.add(Duration(days: 5)),
        availableTo: now.add(Duration(days: 90)),
      ),
      Boat(
        name: "Cano cao tốc Phú Quốc",
        description: "Di chuyển nhanh, phù hợp tour nhóm nhỏ",
        imageUrl: "https://images.unsplash.com/photo-1562281302-809108fd533c",
        capacity: 8,
        pricePerDay: 2800000,
        availableFrom: now.add(Duration(days: 1)),
        availableTo: now.add(Duration(days: 45)),
      ),
      Boat(
        name: "Thuyền câu cá Vũng Tàu",
        description: "Trang bị cần câu, áo phao và bếp mini",
        imageUrl: "https://images.unsplash.com/photo-1575356962984-cf03f5a0f4b2",
        capacity: 15,
        pricePerDay: 4200000,
        availableFrom: now.add(Duration(days: 3)),
        availableTo: now.add(Duration(days: 75)),
      ),
      Boat(
        name: "Du thuyền Sunset Hạ Long",
        description: "Không gian tiệc tối và ngắm hoàng hôn tuyệt đẹp",
        imageUrl: "https://images.unsplash.com/photo-1605281317010-fe5ffe798166",
        capacity: 22,
        pricePerDay: 9500000,
        availableFrom: now.add(Duration(days: 2)),
        availableTo: now.add(Duration(days: 100)),
      ),
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
    bool onlyFavorites = false,
  }) async {
    final db = await database;
    List<String> where = [];
    List<dynamic> args = [];

    if (date != null) {
      final dateStr = date.toIso8601String();
      where.add('availableFrom <= ? AND availableTo >= ?');
      args.addAll([dateStr, dateStr]);
    }

    if (minCapacity != null && minCapacity > 0) {
      where.add('capacity >= ?');
      args.add(minCapacity);
    }

    if (onlyFavorites) {
      where.add('isFavorite = 1');
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