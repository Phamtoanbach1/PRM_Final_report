import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../repository/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) => BookingRepository());

final bookingListProvider = StateNotifierProvider<BookingListNotifier, AsyncValue<List<Booking>>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return BookingListNotifier(repo);
});

class BookingListNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  final BookingRepository _repository;

  BookingListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      state = const AsyncValue.loading();
      final bookings = await _repository.fetchBookings();
      state = AsyncValue.data(bookings);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<String?> createBooking(Booking booking) async {
    final now = DateTime.now();
    final bookingDate = DateTime.parse(booking.date);

    if (bookingDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Ngày phải trong tương lai';
    }

    final start = _timeToDateTime(booking.date, booking.startTime);
    final end = _timeToDateTime(booking.date, booking.endTime);
    if (!start.isBefore(end)) {
      return 'Thời gian kết thúc phải sau bắt đầu';
    }

    var existingBookings = state.maybeWhen(data: (value) => value, orElse: () => []);
    for (final other in existingBookings) {
      if (other.status == BookingStatus.cancelled) continue;
      if (other.boatId != booking.boatId) continue;
      if (other.date != booking.date) continue;
      final existingStart = _timeToDateTime(other.date, other.startTime);
      final existingEnd = _timeToDateTime(other.date, other.endTime);
      if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
        return 'Time slot is already booked';
      }
    }

    await _repository.createBooking(booking);
    await loadBookings();
    return null;
  }

  Future<void> cancelBooking(Booking booking) async {
    if (booking.status == BookingStatus.cancelled) return;
    final bookingDateTime = _timeToDateTime(booking.date, booking.endTime);
    if (bookingDateTime.isBefore(DateTime.now())) return;

    final updated = booking.copyWith(status: BookingStatus.cancelled);
    await _repository.updateBooking(updated);
    await loadBookings();
  }

  Future<void> approveBooking(Booking booking) async {
    if (booking.status != BookingStatus.pending) return;
    final updated = booking.copyWith(status: BookingStatus.confirmed);
    await _repository.updateBooking(updated);
    await loadBookings();
  }

  Future<void> rejectBooking(Booking booking) async {
    if (booking.status != BookingStatus.pending) return;
    final updated = booking.copyWith(status: BookingStatus.cancelled);
    await _repository.updateBooking(updated);
    await loadBookings();
  }

  double calculateTotalPrice({required double pricePerHour, required String startTime, required String endTime}) {
    final start = _timeToDateTime('2000-01-01', startTime);
    final end = _timeToDateTime('2000-01-01', endTime);
    final duration = end.difference(start);
    return (duration.inMinutes / 60.0) * pricePerHour;
  }

  DateTime _timeToDateTime(String date, String time) {
    final dateParts = date.split('-');
    final timeParts = time.split(':');
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }
}
