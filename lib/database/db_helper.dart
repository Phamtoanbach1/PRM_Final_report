import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'boat_booking_v2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE boats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        capacity INTEGER,
        price REAL,
        location TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE boat_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        boat_id INTEGER,
        image_url TEXT,
        FOREIGN KEY (boat_id) REFERENCES boats (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        boat_id INTEGER,
        user_name TEXT,
        date TEXT,
        start_time TEXT,
        end_time TEXT,
        number_of_people INTEGER,
        total_price REAL,
        status TEXT,
        FOREIGN KEY (boat_id) REFERENCES boats (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        boat_id INTEGER,
        available_date TEXT,
        FOREIGN KEY (boat_id) REFERENCES boats (id) ON DELETE CASCADE
      )
    ''');

    // Create Indexes for performance as requested
    await db.execute('CREATE INDEX idx_bookings_boat_date ON bookings (boat_id, date)');
  }
}
