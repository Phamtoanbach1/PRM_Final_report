import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/shared_prefs_helper.dart';
import '../domain/booking_model.dart';

class BookingRepository {
  /// Dữ liệu booking tách theo email user (mỗi tài khoản một danh sách).
  static Future<String> _storageKey() async {
    final email = await SharedPrefsHelper.getUserEmail();
    if (email == null || email.isEmpty) {
      return 'bookings_json_v1';
    }
    return 'bookings_json_v1_${email.hashCode}';
  }

  Future<List<Booking>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _storageKey();
    final raw = prefs.getString(key) ?? '';
    return Booking.decodeList(raw);
  }

  Future<void> saveAll(List<Booking> list) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _storageKey();
    await prefs.setString(key, Booking.encodeList(list));
  }
}
