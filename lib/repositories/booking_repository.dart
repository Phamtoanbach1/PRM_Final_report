import 'package:prm_final_report/database/db_helper.dart';
import 'package:prm_final_report/models/booking_model.dart';
import 'package:sqflite/sqflite.dart';

class BookingRepository {
  final DBHelper _dbHelper = DBHelper();

  Future<int> insertBooking(Booking booking) async {
    final db = await _dbHelper.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<List<Booking>> getBookingsByBoatAndDate(int boatId, String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'boat_id = ? AND date = ? AND status != ?',
      whereArgs: [boatId, date, BookingStatus.cancelled.name],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('bookings', orderBy: 'id DESC');
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  Future<void> updateBookingStatus(int id, BookingStatus status) async {
    final db = await _dbHelper.database;
    await db.update(
      'bookings',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Booking?> getBookingById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('bookings', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Booking.fromMap(maps.first);
    }
    return null;
  }
}
