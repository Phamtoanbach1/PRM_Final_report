import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prm_final_report/models/booking_model.dart';
import 'package:prm_final_report/models/boat_model.dart';
import 'package:prm_final_report/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider((ref) => BookingRepository());

final bookingListProvider = StateNotifierProvider<BookingNotifier, AsyncValue<List<Booking>>>((ref) {
  return BookingNotifier(ref.watch(bookingRepositoryProvider));
});

class BookingNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  final BookingRepository _repository;

  BookingNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchBookingHistory();
  }

  Future<void> fetchBookingHistory() async {
    state = const AsyncValue.loading();
    try {
      final bookings = await _repository.getAllBookings();
      state = AsyncValue.data(bookings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Business Logic: Price Calculation
  double calculateTotalPrice(Boat boat, TimeOfDay start, TimeOfDay end) {
    final startTime = DateTime(2000, 1, 1, start.hour, start.minute);
    final endTime = DateTime(2000, 1, 1, end.hour, end.minute);
    
    final duration = endTime.difference(startTime);
    double hours = duration.inMinutes / 60.0;
    
    if (hours <= 0) return 0;
    
    double total = hours * boat.price;
    
    // Optional: Weekend surcharge (10%)
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      total *= 1.1;
    }
    
    return total;
  }

  // Business Logic: Conflict Checking
  Future<String?> validateBooking(Boat boat, String date, TimeOfDay start, TimeOfDay end, int pax) async {
    // 1. Basic Validations
    final selectedDate = DateFormat('yyyy-MM-dd').parse(date);
    if (selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return "Date must be in the future.";
    }

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    if (startMinutes >= endMinutes) {
      return "Start time must be before end time.";
    }

    if (pax > boat.capacity) {
      return "Number of people exceeds boat capacity (${boat.capacity}).";
    }

    // 2. Conflict Logic: Overlap Check
    // (new_start < existing_end) AND (new_end > existing_start)
    final existingBookings = await _repository.getBookingsByBoatAndDate(boat.id!, date);
    
    for (var existing in existingBookings) {
      final existingStart = existing.startTime.hour * 60 + existing.startTime.minute;
      final existingEnd = existing.endTime.hour * 60 + existing.endTime.minute;
      
      if (startMinutes < existingEnd && endMinutes > existingStart) {
        return "This time slot overlaps with an existing booking.";
      }
    }

    return null; // No conflict
  }

  Future<bool> createBooking(Booking booking) async {
    try {
      await _repository.insertBooking(booking);
      await fetchBookingHistory();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> cancelBooking(int id) async {
    final booking = await _repository.getBookingById(id);
    if (booking != null) {
      // Check if allowed: pending or confirmed and not past
      final date = DateFormat('yyyy-MM-dd').parse(booking.date);
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        // Logically cannot cancel past booking
        return;
      }
      
      await _repository.updateBookingStatus(id, BookingStatus.cancelled);
      await fetchBookingHistory();
    }
  }
}
