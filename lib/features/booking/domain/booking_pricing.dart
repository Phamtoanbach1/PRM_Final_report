/// Giá demo: phí thuyền theo giờ + phí mỗi khách theo giờ.
class BookingPricing {
  BookingPricing._();

  /// VND / giờ (tối thiểu tính 1 giờ)
  static const double hourlyBoatRate = 800000;

  /// VND / khách / giờ
  static const double perPassengerHourly = 30000;
  static const double weekendMultiplier = 1.15;
  static const double holidayMultiplier = 1.25;
  static const double offPeakMultiplier = 0.9;
  static const Set<String> holidayYmd = <String>{
    '2026-01-01',
    '2026-04-30',
    '2026-05-01',
    '2026-09-02',
  };

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
    double? boatHourlyPrice,
  }) {
    final hours = billableHours(start, end);
    final baseBoatRate = boatHourlyPrice ?? hourlyBoatRate;
    final ymd = '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    var dayMultiplier = 1.0;
    if (holidayYmd.contains(ymd)) {
      dayMultiplier = holidayMultiplier;
    } else if (start.weekday == DateTime.saturday || start.weekday == DateTime.sunday) {
      dayMultiplier = weekendMultiplier;
    }
    final offPeak = (start.hour >= 0 && start.hour < 6) || (start.hour >= 22);
    final timeMultiplier = offPeak ? offPeakMultiplier : 1.0;
    final boat = baseBoatRate * hours * dayMultiplier * timeMultiplier;
    final passengers = perPassengerHourly * passengerCount * hours;
    return boat + passengers;
  }
}
