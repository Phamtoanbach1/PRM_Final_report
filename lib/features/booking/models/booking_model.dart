enum BookingStatus { pending, confirmed, cancelled }

extension BookingStatusExtension on BookingStatus {
  String get name {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  static BookingStatus from(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

class Booking {
  final int? id;
  final int boatId;
  final String boatName;
  final String date; // yyyy-MM-dd
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final int numberOfPeople;
  final double totalPrice;
  final BookingStatus status;

  Booking({
    this.id,
    required this.boatId,
    required this.boatName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.status,
  });

  Booking copyWith({
    int? id,
    int? boatId,
    String? boatName,
    String? date,
    String? startTime,
    String? endTime,
    int? numberOfPeople,
    double? totalPrice,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      boatId: boatId ?? this.boatId,
      boatName: boatName ?? this.boatName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'boat_id': boatId,
      'boat_name': boatName,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'number_of_people': numberOfPeople,
      'total_price': totalPrice,
      'status': status.name,
    };
  }

  factory Booking.fromMap(Map<String, Object?> map) {
    return Booking(
      id: map['id'] as int?,
      boatId: map['boat_id'] as int,
      boatName: map['boat_name'] as String,
      date: map['date'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      numberOfPeople: map['number_of_people'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: BookingStatusExtension.from(map['status'] as String),
    );
  }
}
