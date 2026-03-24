/// Giá demo: phí thuyền theo giờ + phí mỗi khách theo giờ.
class BookingPricing {
  BookingPricing._();

  /// VND / giờ (tối thiểu tính 1 giờ)
  static const double hourlyBoatRate = 800000;

  /// VND / khách / giờ
  static const double perPassengerHourly = 30000;

  /// Làm tròn lên số giờ (ví dụ 90 phút = 2 giờ).
  static int billableHours(DateTime start, DateTime end) {
    final d = end.difference(start);
    if (d.inMinutes <= 0) return 0;
    return (d.inMinutes / 60).ceil().clamp(1, 999);
  }

  static double totalVnd({
    required DateTime start,
    required DateTime end,
    required int passengerCount,
  }) {
    final hours = billableHours(start, end);
    final boat = hourlyBoatRate * hours;
    final passengers = perPassengerHourly * passengerCount * hours;
    return boat + passengers;
  }
}
