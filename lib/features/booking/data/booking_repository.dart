import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/local/shared_prefs_helper.dart';
import '../../boats/data/boat_catalog.dart';
import '../domain/booking_model.dart';

class BookingRepository {
  static const _systemKey = 'bookings_system_v1';
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

  Future<List<Booking>> loadAllSystem() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_systemKey) ?? '';
    final system = Booking.decodeList(raw);
    if (system.isNotEmpty) return system;

    // Migrate from legacy per-user keys (bookings_json_v1*).
    final merged = <Booking>[];
    final seenIds = <String>{};
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('bookings_json_v1')) continue;
      final legacyRaw = prefs.getString(key) ?? '';
      final list = Booking.decodeList(legacyRaw);
      for (final b in list) {
        if (seenIds.add(b.id)) merged.add(b);
      }
    }
    if (merged.isNotEmpty) {
      await prefs.setString(_systemKey, Booking.encodeList(merged));
      return merged;
    }
    final seeded = _seedSystemBookings();
    if (seeded.isNotEmpty) {
      await prefs.setString(_systemKey, Booking.encodeList(seeded));
    }
    return seeded;
  }

  Future<void> saveAllSystem(List<Booking> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_systemKey, Booking.encodeList(list));
  }

  List<Booking> _seedSystemBookings() {
    final boats = BoatCatalog.defaultBoats;
    if (boats.isEmpty) return <Booking>[];
    final now = DateTime.now();
    final statuses = <BookingStatus>[
      BookingStatus.pending,
      BookingStatus.confirmed,
      BookingStatus.cancelled,
      BookingStatus.rejected,
    ];
    final data = <Booking>[];
    for (var i = 0; i < 30; i++) {
      final boat = boats[i % boats.length];
      final dayOffset = (i % 14) - 6; // spread around today
      final startHour = 7 + (i % 12);
      final durationHours = 2 + (i % 3);
      final start = DateTime(now.year, now.month, now.day + dayOffset, startHour, 0);
      final end = start.add(Duration(hours: durationHours));
      final status = statuses[i % statuses.length];
      final basePrice = (boat.hourlyPrice * durationHours) + ((2 + (i % 8)) * 30000.0 * durationHours);
      data.add(
        Booking(
          id: 'seed_bk_${i + 1}',
          boatId: boat.id,
          boatName: boat.name,
          startAt: start,
          endAt: end,
          passengerCount: 2 + (i % 8),
          status: status,
          totalPrice: basePrice,
          createdAt: start.subtract(Duration(days: 1 + (i % 3))),
          note: 'Dữ liệu demo #${i + 1}',
          reviewReason: status == BookingStatus.rejected ? 'Không phù hợp lịch vận hành' : null,
          reviewedBy: status == BookingStatus.pending ? null : 'system_seed',
          reviewedAt: status == BookingStatus.pending ? null : start.subtract(const Duration(hours: 1)),
          reviewAction: status == BookingStatus.confirmed
              ? 'approved'
              : status == BookingStatus.cancelled
                  ? 'cancelled_by_user'
                  : status == BookingStatus.rejected
                      ? 'rejected'
                      : null,
        ),
      );
    }
    return data;
  }
}
