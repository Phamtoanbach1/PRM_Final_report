import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService._privateConstructor();
  static final BookingService instance = BookingService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookings.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bookings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            boat_id INTEGER NOT NULL,
            boat_name TEXT NOT NULL,
            date TEXT NOT NULL,
            start_time TEXT NOT NULL,
            end_time TEXT NOT NULL,
            number_of_people INTEGER NOT NULL,
            total_price REAL NOT NULL,
            status TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_boat_id ON bookings(boat_id)');
        await db.execute('CREATE INDEX idx_date ON bookings(date)');
      },
    );
  }

  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await database;
    final maps = await db.query('bookings', orderBy: 'date DESC, start_time DESC');
    return maps.map((m) => Booking.fromMap(m)).toList();
  }

  Future<Booking?> getBookingById(int id) async {
    final db = await database;
    final maps = await db.query('bookings', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Booking.fromMap(maps.first);
  }

  Future<int> updateBooking(Booking booking) async {
    final db = await database;
    return await db.update('bookings', booking.toMap(), where: 'id = ?', whereArgs: [booking.id]);
  }

  Future<int> cancelBooking(int id) async {
    final db = await database;
    return await db.update('bookings', {'status': BookingStatus.cancelled.name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('bookings');
  }
}
