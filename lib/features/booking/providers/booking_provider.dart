import 'package:flutter/foundation.dart';

import '../../../core/services/local_notification_service.dart';
import '../data/booking_repository.dart';
import '../../auth/domain/user_role.dart';
import '../domain/booking_conflict_checker.dart';
import '../domain/booking_model.dart';
import '../domain/booking_pricing.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({BookingRepository? repository}) : _repository = repository ?? BookingRepository();

  final BookingRepository _repository;

  List<Booking> _bookings = [];
  List<Booking> _systemBookings = [];
  bool _loading = false;
  int _lastPendingCount = 0;
  final Set<String> _notifiedUpcomingBookingIds = <String>{};

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Booking> get systemBookings => List.unmodifiable(_systemBookings);
  bool get isLoading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _bookings = await _repository.loadAll();
    _systemBookings = await _repository.loadAllSystem();
    _bookings.sort((a, b) => b.startAt.compareTo(a.startAt));
    _systemBookings.sort((a, b) => b.startAt.compareTo(a.startAt));
    _loading = false;
    _lastPendingCount = _systemBookings.where((b) => b.status == BookingStatus.pending).length;
    _notifyUpcomingBookings();
    notifyListeners();
  }

  /// Sau khi đăng xuất — xóa danh sách trong RAM (dữ liệu trên disk theo user vẫn an toàn).
  void clearLocal() {
    _bookings = [];
    _systemBookings = [];
    notifyListeners();
  }

  Booking? byId(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      try {
        return _systemBookings.firstWhere((b) => b.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  List<Booking> filteredByStatus(BookingStatus? status) {
    if (status == null) return bookings;
    return _bookings.where((b) => b.status == status).toList();
  }

  List<Booking> filteredByStatusIn(List<Booking> source, BookingStatus? status) {
    if (status == null) return List<Booking>.from(source);
    return source.where((b) => b.status == status).toList();
  }

  List<Booking> visibleBookingsForRole({
    required UserRole role,
    required String? email,
    Set<String> ownerBoatIds = const <String>{},
  }) {
    if (role == UserRole.shopOwner) {
      if (email == null || email.trim().isEmpty || ownerBoatIds.isEmpty) return const <Booking>[];
      return _systemBookings.where((b) => ownerBoatIds.contains(b.boatId)).toList();
    }
    if (role == UserRole.admin) return const <Booking>[];
    return bookings;
  }

  bool canMutateBooking({
    required String bookingId,
    required UserRole role,
    required Set<String> ownerBoatIds,
  }) {
    if (role == UserRole.admin) return true;
    final booking = byId(bookingId);
    if (booking == null) return false;
    if (role == UserRole.shopOwner) return ownerBoatIds.contains(booking.boatId);
    return _bookings.any((b) => b.id == bookingId);
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
      bookings: _systemBookings.isEmpty ? _bookings : _systemBookings,
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
    double? boatHourlyPrice,
  }) {
    return BookingPricing.totalVnd(
      start: start,
      end: end,
      passengerCount: passengerCount,
      boatHourlyPrice: boatHourlyPrice,
    );
  }

  Future<bool> createBooking({
    required String boatId,
    required String boatName,
    required double boatHourlyPrice,
    required DateTime start,
    required DateTime end,
    required int passengerCount,
    String? note,
    String? promoCode,
    double? discountPercent,
  }) async {
    final err = validateSlot(boatId: boatId, start: start, end: end);
    if (err != null) return false;

    final originalPrice = calculatePrice(
      start: start,
      end: end,
      passengerCount: passengerCount,
      boatHourlyPrice: boatHourlyPrice,
    );
    final discount = ((discountPercent ?? 0).toDouble()).clamp(0, 0.95).toDouble();
    final price = originalPrice * (1 - discount);

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
      promoCode: promoCode,
      discountPercent: discount > 0 ? discount : null,
      originalPrice: discount > 0 ? originalPrice : null,
    );

    _bookings = [booking, ..._bookings];
    _systemBookings = [booking, ..._systemBookings];
    await _repository.saveAll(_bookings);
    await _repository.saveAllSystem(_systemBookings);
    await LocalNotificationService.instance.show(
      id: booking.id.hashCode,
      title: 'Booking mới',
      body: '${booking.boatName} chờ xác nhận',
    );
    notifyListeners();
    return true;
  }

  Future<void> cancelBooking(String id) async {
    await _updateStatus(id, BookingStatus.cancelled, action: 'cancelled_by_user');
  }

  /// Demo: chuyển pending → confirmed (mô phỏng xác nhận từ phía đơn vị).
  Future<bool> confirmBooking(
    String id, {
    String? by,
    UserRole role = UserRole.admin,
    Set<String> ownerBoatIds = const <String>{},
  }) async {
    if (!canMutateBooking(bookingId: id, role: role, ownerBoatIds: ownerBoatIds)) return false;
    await _updateStatus(id, BookingStatus.confirmed, by: by, action: 'approved');
    return true;
  }

  Future<bool> rejectBooking(
    String id, {
    String? by,
    String? reason,
    UserRole role = UserRole.admin,
    Set<String> ownerBoatIds = const <String>{},
  }) async {
    if (!canMutateBooking(bookingId: id, role: role, ownerBoatIds: ownerBoatIds)) return false;
    await _updateStatus(id, BookingStatus.rejected, by: by, reason: reason, action: 'rejected');
    return true;
  }

  Future<int> confirmMany(
    List<String> ids, {
    String? by,
    UserRole role = UserRole.admin,
    Set<String> ownerBoatIds = const <String>{},
  }) async {
    var changed = 0;
    for (final id in ids) {
      final ok = await confirmBooking(id, by: by, role: role, ownerBoatIds: ownerBoatIds);
      if (ok) changed++;
    }
    return changed;
  }

  Future<int> rejectMany(
    List<String> ids, {
    String? by,
    required String reason,
    UserRole role = UserRole.admin,
    Set<String> ownerBoatIds = const <String>{},
  }) async {
    var changed = 0;
    for (final id in ids) {
      final ok = await rejectBooking(id, by: by, reason: reason, role: role, ownerBoatIds: ownerBoatIds);
      if (ok) changed++;
    }
    return changed;
  }

  Future<void> _updateStatus(
    String id,
    BookingStatus status, {
    String? by,
    String? reason,
    String? action,
  }) async {
    final localIdx = _bookings.indexWhere((b) => b.id == id);
    final sysIdx = _systemBookings.indexWhere((b) => b.id == id);
    if (localIdx >= 0) {
      _bookings[localIdx] = _bookings[localIdx].copyWith(
        status: status,
        reviewedBy: by,
        reviewReason: reason,
        reviewedAt: DateTime.now(),
        reviewAction: action,
      );
      await _repository.saveAll(_bookings);
    }
    if (sysIdx >= 0) {
      _systemBookings[sysIdx] = _systemBookings[sysIdx].copyWith(
        status: status,
        reviewedBy: by,
        reviewReason: reason,
        reviewedAt: DateTime.now(),
        reviewAction: action,
      );
      await _repository.saveAllSystem(_systemBookings);
    }
    notifyListeners();
  }

  List<Booking> systemByBoatAndDate({
    required String boatId,
    required DateTime date,
  }) {
    return _systemBookings.where((b) {
      final sameBoat = b.boatId == boatId;
      final sameDate =
          b.startAt.year == date.year && b.startAt.month == date.month && b.startAt.day == date.day;
      return sameBoat && sameDate;
    }).toList();
  }

  Future<int> rejectPendingByBoatAndDate({
    required String boatId,
    required DateTime date,
    UserRole role = UserRole.admin,
    Set<String> ownerBoatIds = const <String>{},
  }) async {
    if (role == UserRole.shopOwner && !ownerBoatIds.contains(boatId)) return 0;
    final ids = _systemBookings
        .where((b) {
          final sameBoat = b.boatId == boatId;
          final sameDate = b.startAt.year == date.year &&
              b.startAt.month == date.month &&
              b.startAt.day == date.day;
          return sameBoat && sameDate && b.status == BookingStatus.pending;
        })
        .map((b) => b.id)
        .toList();
    for (final id in ids) {
      await _updateStatus(id, BookingStatus.rejected, action: 'rejected_by_calendar_lock');
    }
    return ids.length;
  }

  Map<String, Map<String, double>> boatKpi({
    required List<Booking> source,
    required Iterable<String> boatIds,
  }) {
    final result = <String, Map<String, double>>{};
    for (final boatId in boatIds) {
      final list = source.where((b) => b.boatId == boatId).toList();
      if (list.isEmpty) {
        result[boatId] = <String, double>{
          'occupancy': 0,
          'revenue': 0,
          'cancelRate': 0,
        };
        continue;
      }
      final total = list.length;
      final confirmed = list.where((b) => b.status == BookingStatus.confirmed).length;
      final cancelled = list.where((b) => b.status == BookingStatus.cancelled).length;
      final revenue =
          list.where((b) => b.status == BookingStatus.confirmed).fold(0.0, (s, b) => s + b.totalPrice);
      result[boatId] = <String, double>{
        'occupancy': total == 0 ? 0 : confirmed / total,
        'revenue': revenue,
        'cancelRate': total == 0 ? 0 : cancelled / total,
      };
    }
    return result;
  }

  List<MapEntry<int, double>> topHourSlots({
    required List<Booking> source,
    int limit = 5,
  }) {
    final map = <int, double>{};
    for (final b in source.where((e) => e.status == BookingStatus.confirmed)) {
      final h = b.startAt.hour;
      map[h] = (map[h] ?? 0) + b.totalPrice;
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  List<Booking> filterSystemBookings({
    String? bookingIdQuery,
    BookingStatus? status,
    String? boatId,
    DateTime? date,
    double? minPrice,
    double? maxPrice,
  }) {
    return _systemBookings.where((b) {
      final q = bookingIdQuery?.trim().toLowerCase();
      final matchId = q == null || q.isEmpty || b.id.toLowerCase().contains(q);
      final matchStatus = status == null || b.status == status;
      final matchBoat = boatId == null || boatId.isEmpty || b.boatId == boatId;
      final matchDate = date == null ||
          (b.startAt.year == date.year && b.startAt.month == date.month && b.startAt.day == date.day);
      final matchMin = minPrice == null || b.totalPrice >= minPrice;
      final matchMax = maxPrice == null || b.totalPrice <= maxPrice;
      return matchId && matchStatus && matchBoat && matchDate && matchMin && matchMax;
    }).toList();
  }

  int pendingCount() => _systemBookings.where((b) => b.status == BookingStatus.pending).length;

  Map<String, double> revenueByPeriod() {
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final startWeek = startDay.subtract(Duration(days: now.weekday - 1));
    final startMonth = DateTime(now.year, now.month, 1);
    double day = 0, week = 0, month = 0;
    for (final b in _systemBookings.where((e) => e.status == BookingStatus.confirmed)) {
      if (!b.startAt.isBefore(startMonth)) month += b.totalPrice;
      if (!b.startAt.isBefore(startWeek)) week += b.totalPrice;
      if (!b.startAt.isBefore(startDay)) day += b.totalPrice;
    }
    return <String, double>{'day': day, 'week': week, 'month': month};
  }

  List<MapEntry<String, int>> topBoatsByBookings({int limit = 5}) {
    final map = <String, int>{};
    for (final b in _systemBookings) {
      map[b.boatName] = (map[b.boatName] ?? 0) + 1;
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  double get totalRevenue =>
      _systemBookings.where((b) => b.status == BookingStatus.confirmed).fold(0, (sum, b) => sum + b.totalPrice);

  int countByStatus(BookingStatus status) =>
      _systemBookings.where((b) => b.status == status).length;

  Future<void> reloadSystem() async {
    _systemBookings = await _repository.loadAllSystem();
    _systemBookings.sort((a, b) => b.startAt.compareTo(a.startAt));
    final currentPending = _systemBookings.where((b) => b.status == BookingStatus.pending).length;
    if (currentPending > _lastPendingCount) {
      await LocalNotificationService.instance.show(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        title: 'Có booking mới chờ duyệt',
        body: 'Hiện có $currentPending booking pending',
      );
    }
    _lastPendingCount = currentPending;
    _notifyUpcomingBookings();
    notifyListeners();
  }

  void _notifyUpcomingBookings() {
    final now = DateTime.now();
    for (final b in _systemBookings.where((e) => e.status == BookingStatus.confirmed)) {
      final diff = b.startAt.difference(now);
      if (diff.inMinutes >= 0 && diff.inMinutes <= 60 && !_notifiedUpcomingBookingIds.contains(b.id)) {
        _notifiedUpcomingBookingIds.add(b.id);
        LocalNotificationService.instance.show(
          id: ('upcoming_${b.id}').hashCode,
          title: 'Sắp đến giờ chuyến đi',
          body: '${b.boatName} bắt đầu lúc ${b.startAt.hour.toString().padLeft(2, '0')}:${b.startAt.minute.toString().padLeft(2, '0')}',
        );
      }
    }
  }
}
