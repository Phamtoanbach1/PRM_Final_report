import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, cancelled }

class Booking {
  final int? id;
  final int boatId;
  final String userName;
  final String date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int numberOfPeople;
  final double totalPrice;
  final BookingStatus status;

  Booking({
    this.id,
    required this.boatId,
    required this.userName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.numberOfPeople,
    required this.totalPrice,
    this.status = BookingStatus.pending,
  });

  // Convert TimeOfDay to String HH:mm
  String _timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Convert String HH:mm to TimeOfDay
  static TimeOfDay _stringToTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boat_id': boatId,
      'user_name': userName,
      'date': date,
      'start_time': _timeToString(startTime),
      'end_time': _timeToString(endTime),
      'number_of_people': numberOfPeople,
      'total_price': totalPrice,
      'status': status.name,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      boatId: map['boat_id'],
      userName: map['user_name'],
      date: map['date'],
      startTime: _stringToTime(map['start_time']),
      endTime: _stringToTime(map['end_time']),
      numberOfPeople: map['number_of_people'],
      totalPrice: map['total_price'],
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
    );
  }

  Booking copyWith({
    int? id,
    int? boatId,
    String? userName,
    String? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? numberOfPeople,
    double? totalPrice,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      boatId: boatId ?? this.boatId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }
}
