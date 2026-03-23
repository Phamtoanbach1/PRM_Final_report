import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _service;

  BookingRepository({BookingService? service}) : _service = service ?? BookingService.instance;

  Future<List<Booking>> fetchBookings() async {
    return await _service.getAllBookings();
  }

  Future<Booking?> getBooking(int id) async {
    return await _service.getBookingById(id);
  }

  Future<int> createBooking(Booking booking) async {
    return await _service.insertBooking(booking);
  }

  Future<int> updateBooking(Booking booking) async {
    return await _service.updateBooking(booking);
  }

  Future<int> cancelBooking(int id) async {
    return await _service.cancelBooking(id);
  }
}
