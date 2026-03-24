import 'dart:convert';

enum BookingStatus {
  pending,
  confirmed,
  cancelled;

  String get labelVi {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }

  static BookingStatus fromJson(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

class Booking {
  Booking({
    required this.id,
    required this.boatId,
    required this.boatName,
    required this.startAt,
    required this.endAt,
    required this.passengerCount,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String boatId;
  final String boatName;
  final DateTime startAt;
  final DateTime endAt;
  final int passengerCount;
  final BookingStatus status;
  final double totalPrice;
  final DateTime createdAt;
  final String? note;

  Booking copyWith({
    String? id,
    String? boatId,
    String? boatName,
    DateTime? startAt,
    DateTime? endAt,
    int? passengerCount,
    BookingStatus? status,
    double? totalPrice,
    DateTime? createdAt,
    String? note,
  }) {
    return Booking(
      id: id ?? this.id,
      boatId: boatId ?? this.boatId,
      boatName: boatName ?? this.boatName,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      passengerCount: passengerCount ?? this.passengerCount,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'boatId': boatId,
        'boatName': boatName,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'passengerCount': passengerCount,
        'status': status.name,
        'totalPrice': totalPrice,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      boatId: json['boatId'] as String,
      boatName: json['boatName'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      passengerCount: json['passengerCount'] as int,
      status: BookingStatus.fromJson(json['status'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  static String encodeList(List<Booking> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Booking> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Booking.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
