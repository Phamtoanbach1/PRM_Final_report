import 'booking_model.dart';

class BookingConflictChecker {
  BookingConflictChecker._();

  /// Trùng lịch cùng thuyền (bỏ qua booking đã hủy).
  static bool hasOverlap({
    required List<Booking> bookings,
    required String boatId,
    required DateTime start,
    required DateTime end,
    String? excludeBookingId,
  }) {
    for (final b in bookings) {
      if (b.status == BookingStatus.cancelled) continue;
      if (b.boatId != boatId) continue;
      if (excludeBookingId != null && b.id == excludeBookingId) continue;
      if (_intervalsOverlap(b.startAt, b.endAt, start, end)) {
        return true;
      }
    }
    return false;
  }

  static bool _intervalsOverlap(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }
}
