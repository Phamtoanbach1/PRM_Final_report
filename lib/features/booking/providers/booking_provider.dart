import 'package:flutter/foundation.dart';

import '../data/booking_repository.dart';
import '../domain/booking_conflict_checker.dart';
import '../domain/booking_model.dart';
import '../domain/booking_pricing.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({BookingRepository? repository}) : _repository = repository ?? BookingRepository();

  final BookingRepository _repository;

  List<Booking> _bookings = [];
  bool _loading = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _bookings = await _repository.loadAll();
    _bookings.sort((a, b) => b.startAt.compareTo(a.startAt));
    _loading = false;
    notifyListeners();
  }

  /// Sau khi đăng xuất — xóa danh sách trong RAM (dữ liệu trên disk theo user vẫn an toàn).
  void clearLocal() {
    _bookings = [];
    notifyListeners();
  }

  Booking? byId(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Booking> filteredByStatus(BookingStatus? status) {
    if (status == null) return bookings;
    return _bookings.where((b) => b.status == status).toList();
  }

  /// Trả về null nếu hợp lệ, hoặc thông báo lỗi.
  String? validateSlot({
    required String boatId,
    required DateTime start,
    required DateTime end,
    String? excludeId,
  }) {
    if (!end.isAfter(start)) {
      return 'Giờ kết thúc phải sau giờ bắt đầu';
    }
    if (BookingConflictChecker.hasOverlap(
      bookings: _bookings,
      boatId: boatId,
      start: start,
      end: end,
      excludeBookingId: excludeId,
    )) {
      return 'Thuyền đã có lịch trùng trong khoảng thời gian này';
    }
    return null;
  }

  double calculatePrice({
    required DateTime start,
    required DateTime end,
    required int passengerCount,
  }) {
    return BookingPricing.totalVnd(
      start: start,
      end: end,
      passengerCount: passengerCount,
    );
  }

  Future<bool> createBooking({
    required String boatId,
    required String boatName,
    required DateTime start,
    required DateTime end,
    required int passengerCount,
    String? note,
  }) async {
    final err = validateSlot(boatId: boatId, start: start, end: end);
    if (err != null) return false;

    final price = calculatePrice(
      start: start,
      end: end,
      passengerCount: passengerCount,
    );

    final booking = Booking(
      id: 'bk_${DateTime.now().microsecondsSinceEpoch}',
      boatId: boatId,
      boatName: boatName,
      startAt: start,
      endAt: end,
      passengerCount: passengerCount,
      status: BookingStatus.pending,
      totalPrice: price,
      createdAt: DateTime.now(),
      note: note,
    );

    _bookings = [booking, ..._bookings];
    await _repository.saveAll(_bookings);
    notifyListeners();
    return true;
  }

  Future<void> cancelBooking(String id) async {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i < 0) return;
    final b = _bookings[i];
    if (b.status == BookingStatus.cancelled) return;
    _bookings[i] = b.copyWith(status: BookingStatus.cancelled);
    await _repository.saveAll(_bookings);
    notifyListeners();
  }

  /// Demo: chuyển pending → confirmed (mô phỏng xác nhận từ phía đơn vị).
  Future<void> confirmBooking(String id) async {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i < 0) return;
    final b = _bookings[i];
    if (b.status != BookingStatus.pending) return;
    _bookings[i] = b.copyWith(status: BookingStatus.confirmed);
    await _repository.saveAll(_bookings);
    notifyListeners();
  }
}
