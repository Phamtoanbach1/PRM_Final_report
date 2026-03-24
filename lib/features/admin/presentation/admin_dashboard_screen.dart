import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/domain/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../../boats/domain/boat.dart';
import '../../boats/providers/boat_provider.dart';
import '../../booking/domain/booking_model.dart';
import '../../booking/domain/owner_promo_code.dart';
import '../../booking/presentation/widgets/booking_status_badge.dart';
import '../../booking/providers/booking_provider.dart';
import '../../booking/providers/promo_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late final TabController _tabController;
  String? _calendarBoatId;
  DateTime _calendarDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final _idFilter = TextEditingController();
  DateTime? _bookingFilterDate;
  BookingStatus? _bookingFilterStatus;
  String? _bookingFilterBoatId;
  final _minPriceFilter = TextEditingController();
  final _maxPriceFilter = TextEditingController();
  DateTimeRange? _reportRange;
  final Set<String> _selectedBookingIds = <String>{};
  final Set<DateTime> _calendarSelectedDays = <DateTime>{};
  static const List<String> _rejectReasonPresets = <String>[
    'Quá giờ nhận booking cho khung này',
    'Thuyền đang bảo trì',
    'Không đủ điều kiện vận hành theo thời tiết',
    'Không đáp ứng số lượng khách yêu cầu',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<BookingProvider>().reloadSystem();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _idFilter.dispose();
    _minPriceFilter.dispose();
    _maxPriceFilter.dispose();
    super.dispose();
  }

  Future<void> _pickBookingFilterDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _bookingFilterDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _bookingFilterDate = picked);
  }

  bool _isVisibleByRole(AuthProvider auth, Boat boat) {
    if (auth.role == UserRole.admin) return true;
    return boat.ownerEmail.toLowerCase() == (auth.displayEmail ?? '').toLowerCase();
  }

  DateTime _toDateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Booking> _applyReportRange(List<Booking> source) {
    final range = _reportRange;
    if (range == null) return source;
    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
    return source.where((b) => !b.startAt.isBefore(start) && !b.startAt.isAfter(end)).toList();
  }

  Future<void> _pickReportRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _reportRange,
    );
    if (picked != null) setState(() => _reportRange = picked);
  }

  Future<void> _exportCsv(List<Booking> list) async {
    final buffer = StringBuffer();
    buffer.writeln('id,boatId,boatName,status,startAt,endAt,totalPrice,reviewedBy,reviewReason');
    for (final b in list) {
      buffer.writeln(
          '${b.id},${b.boatId},${_escapeCsv(b.boatName)},${b.status.name},${b.startAt.toIso8601String()},${b.endAt.toIso8601String()},${b.totalPrice},${b.reviewedBy ?? ''},${_escapeCsv(b.reviewReason ?? '')}');
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/booking_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xuất CSV: ${file.path}')),
    );
  }

  Future<void> _exportPdf(List<Booking> list) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => <pw.Widget>[
          pw.Text('HanCruise Booking Report', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 12),
          ...list.take(200).map(
                (b) => pw.Text(
                  '${b.id} | ${b.boatName} | ${b.status.name} | ${b.totalPrice.toStringAsFixed(0)}',
                ),
              ),
        ],
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/booking_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await doc.save());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xuất PDF: ${file.path}')),
    );
  }

  String _escapeCsv(String v) => '"${v.replaceAll('"', '""')}"';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    return Consumer4<AuthProvider, BoatProvider, BookingProvider, PromoProvider>(
      builder: (context, auth, boatProvider, bookingProvider, promoProvider, _) {
        final scopedBoats = boatProvider.boatsForAdminScope(auth.role, auth.displayEmail);
        final ownerBoatIds = scopedBoats.map((b) => b.id).toSet();
        _calendarBoatId ??= scopedBoats.isNotEmpty ? scopedBoats.first.id : null;

        final allVisibleBookings = bookingProvider.systemBookings.where((b) {
          if (auth.role == UserRole.admin) return true;
          final boat = boatProvider.byId(b.boatId);
          return boat != null && _isVisibleByRole(auth, boat);
        }).toList();
        final reportBookings = _applyReportRange(allVisibleBookings);

        final filteredBookings = bookingProvider.filterSystemBookings(
          bookingIdQuery: _idFilter.text,
          status: _bookingFilterStatus,
          boatId: _bookingFilterBoatId,
          date: _bookingFilterDate,
          minPrice: double.tryParse(_minPriceFilter.text.trim()),
          maxPrice: double.tryParse(_maxPriceFilter.text.trim()),
        ).where((b) {
          if (auth.role == UserRole.admin) return true;
          final boat = boatProvider.byId(b.boatId);
          return boat != null && _isVisibleByRole(auth, boat);
        }).toList();

        final selectedBoat = _calendarBoatId == null ? null : boatProvider.byId(_calendarBoatId!);
        final daySchedule = selectedBoat == null
            ? <Booking>[]
            : bookingProvider.systemByBoatAndDate(boatId: selectedBoat.id, date: _calendarDate);
        final ymd = DateFormat('yyyy-MM-dd').format(_calendarDate);
        final isBlocked = selectedBoat?.blockedDateYmd.contains(ymd) ?? false;
        final pendingCount = allVisibleBookings.where((e) => e.status == BookingStatus.pending).length;

        final now = DateTime.now();
        final startDay = DateTime(now.year, now.month, now.day);
        final startWeek = startDay.subtract(Duration(days: now.weekday - 1));
        final startMonth = DateTime(now.year, now.month, 1);
        final confirmedVisible =
            reportBookings.where((e) => e.status == BookingStatus.confirmed).toList();
        final revenueMap = <String, double>{
          'day': confirmedVisible
              .where((b) => !b.startAt.isBefore(startDay))
              .fold(0.0, (s, b) => s + b.totalPrice),
          'week': confirmedVisible
              .where((b) => !b.startAt.isBefore(startWeek))
              .fold(0.0, (s, b) => s + b.totalPrice),
          'month': confirmedVisible
              .where((b) => !b.startAt.isBefore(startMonth))
              .fold(0.0, (s, b) => s + b.totalPrice),
        };
        final topBoats = <String, int>{};
        for (final b in reportBookings) {
          topBoats[b.boatName] = (topBoats[b.boatName] ?? 0) + 1;
        }
        final topBoatEntries = topBoats.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final kpiByBoat = bookingProvider.boatKpi(
          source: reportBookings,
          boatIds: scopedBoats.map((b) => b.id),
        );
        final topHourSlots = bookingProvider.topHourSlots(source: reportBookings);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(auth.role == UserRole.admin ? 'Admin Dashboard' : 'Owner Dashboard'),
            backgroundColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.notifications_active_outlined),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Thuyền'),
                Tab(text: 'Booking'),
                Tab(text: 'Calendar'),
                Tab(text: 'Promotions'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _statCard('Tổng booking', '${allVisibleBookings.length}', Icons.receipt_long),
                  _statCard(
                    'Chờ duyệt',
                    '${allVisibleBookings.where((e) => e.status == BookingStatus.pending).length}',
                    Icons.hourglass_bottom,
                  ),
                  _statCard(
                    'Đã xác nhận',
                    '${allVisibleBookings.where((e) => e.status == BookingStatus.confirmed).length}',
                    Icons.verified_outlined,
                  ),
                  _statCard(
                    'Từ chối',
                    '${allVisibleBookings.where((e) => e.status == BookingStatus.rejected).length}',
                    Icons.block_outlined,
                  ),
                  _statCard(
                    'Doanh thu',
                    currency.format(
                      reportBookings
                          .where((e) => e.status == BookingStatus.confirmed)
                          .fold(0.0, (s, b) => s + b.totalPrice),
                    ),
                    Icons.payments_outlined,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickReportRange,
                          icon: const Icon(Icons.date_range_outlined),
                          label: Text(
                            _reportRange == null
                                ? 'Chọn khoảng thời gian report'
                                : '${DateFormat('dd/MM').format(_reportRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_reportRange!.end)}',
                          ),
                        ),
                      ),
                      if (_reportRange != null)
                        TextButton(
                          onPressed: () => setState(() => _reportRange = null),
                          child: const Text('Xóa'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Doanh thu theo kỳ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _periodBar('Ngày', revenueMap['day'] ?? 0, Colors.blue),
                  _periodBar('Tuần', revenueMap['week'] ?? 0, Colors.green),
                  _periodBar('Tháng', revenueMap['month'] ?? 0, Colors.deepPurple),
                  const SizedBox(height: 12),
                  const Text('Top thuyền theo số booking', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...topBoatEntries.take(5).map(
                    (e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.key),
                      trailing: Text('${e.value} booking'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('KPI theo thuyền', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...scopedBoats.map((boat) {
                    final kpi = kpiByBoat[boat.id] ??
                        const <String, double>{'occupancy': 0, 'revenue': 0, 'cancelRate': 0};
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(boat.name),
                      subtitle: Text(
                        'Lấp đầy: ${((kpi['occupancy'] ?? 0) * 100).toStringAsFixed(0)}% • Hủy: ${((kpi['cancelRate'] ?? 0) * 100).toStringAsFixed(0)}%',
                      ),
                      trailing: Text(currency.format(kpi['revenue'] ?? 0)),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Text('Top khung giờ đắt khách', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...topHourSlots.map(
                    (e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${e.key.toString().padLeft(2, '0')}:00'),
                      trailing: Text(currency.format(e.value)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _exportCsv(_applyReportRange(filteredBookings)),
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Export CSV (lọc)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _exportPdf(_applyReportRange(filteredBookings)),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Export PDF (lọc)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FilledButton.icon(
                    onPressed: () => _showBoatDialog(context, boatProvider, auth),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm thuyền'),
                  ),
                  const SizedBox(height: 10),
                  ...scopedBoats.map((b) => Card(
                        child: ListTile(
                          title: Text(b.name),
                          subtitle: Text(
                            '${b.capacity} khách • ${currency.format(b.hourlyPrice)}/giờ\nOwner: ${b.ownerEmail}',
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                onPressed: () => _showBoatDialog(context, boatProvider, auth, boat: b),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final hasConfirmedBooking = allVisibleBookings.any(
                                    (bk) => bk.boatId == b.id && bk.status == BookingStatus.confirmed,
                                  );
                                  if (hasConfirmedBooking) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Không thể xóa thuyền đang có booking confirmed'),
                                      ),
                                    );
                                    return;
                                  }
                                  final ok = await boatProvider.deleteBoatScoped(
                                    b.id,
                                    role: auth.role,
                                    actorEmail: auth.displayEmail,
                                  );
                                  if (!ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Không có quyền xóa thuyền này')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _idFilter,
                    decoration: const InputDecoration(
                      labelText: 'Tìm theo mã booking',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<BookingStatus?>(
                          value: _bookingFilterStatus,
                          decoration: const InputDecoration(labelText: 'Trạng thái'),
                          items: <DropdownMenuItem<BookingStatus?>>[
                            const DropdownMenuItem(value: null, child: Text('Tất cả')),
                            ...BookingStatus.values
                                .map((s) => DropdownMenuItem(value: s, child: Text(s.labelVi))),
                          ],
                          onChanged: (v) => setState(() => _bookingFilterStatus = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: _bookingFilterBoatId,
                          decoration: const InputDecoration(labelText: 'Thuyền'),
                          items: <DropdownMenuItem<String?>>[
                            const DropdownMenuItem(value: null, child: Text('Tất cả')),
                            ...scopedBoats.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))),
                          ],
                          onChanged: (v) => setState(() => _bookingFilterBoatId = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceFilter,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Giá từ'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceFilter,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Đến giá'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickBookingFilterDate,
                          icon: const Icon(Icons.event_outlined),
                          label: Text(
                            _bookingFilterDate == null
                                ? 'Lọc theo ngày'
                                : DateFormat('dd/MM/yyyy').format(_bookingFilterDate!),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _idFilter.clear();
                          _minPriceFilter.clear();
                          _maxPriceFilter.clear();
                          setState(() {
                            _bookingFilterDate = null;
                            _bookingFilterStatus = null;
                            _bookingFilterBoatId = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Kết quả: ${filteredBookings.length} booking'),
                  if (_selectedBookingIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final changed = await bookingProvider.confirmMany(
                                _selectedBookingIds.toList(),
                                by: auth.displayEmail ?? auth.role.labelVi,
                                role: auth.role,
                                ownerBoatIds: ownerBoatIds,
                              );
                              if (!mounted) return;
                              setState(() => _selectedBookingIds.clear());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã duyệt $changed booking')),
                              );
                            },
                            icon: const Icon(Icons.done_all_outlined),
                            label: Text('Duyệt (${_selectedBookingIds.length})'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final reason = await _askRejectReason();
                              if (reason == null || reason.trim().isEmpty) return;
                              final changed = await bookingProvider.rejectMany(
                                _selectedBookingIds.toList(),
                                by: auth.displayEmail ?? auth.role.labelVi,
                                reason: reason.trim(),
                                role: auth.role,
                                ownerBoatIds: ownerBoatIds,
                              );
                              if (!mounted) return;
                              setState(() => _selectedBookingIds.clear());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã từ chối $changed booking')),
                              );
                            },
                            style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
                            icon: const Icon(Icons.block_outlined),
                            label: const Text('Từ chối nhanh'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  ...filteredBookings.map((b) {
                    final canReview = b.status == BookingStatus.pending;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _selectedBookingIds.contains(b.id),
                                  onChanged: canReview
                                      ? (v) => setState(() {
                                            if (v == true) {
                                              _selectedBookingIds.add(b.id);
                                            } else {
                                              _selectedBookingIds.remove(b.id);
                                            }
                                          })
                                      : null,
                                ),
                                Expanded(child: Text(b.boatName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                BookingStatusBadge(status: b.status, compact: true),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('ID: ${b.id}'),
                            Text('Lịch: ${DateFormat('dd/MM HH:mm').format(b.startAt)} - ${DateFormat('HH:mm').format(b.endAt)}'),
                            if (b.reviewReason != null) Text('Lý do: ${b.reviewReason}'),
                            if (b.reviewedBy != null) Text('Audit: ${b.reviewAction} bởi ${b.reviewedBy}'),
                            const SizedBox(height: 8),
                            if (canReview)
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => bookingProvider.confirmBooking(b.id,
                                          by: auth.displayEmail ?? auth.role.labelVi,
                                          role: auth.role,
                                          ownerBoatIds: ownerBoatIds),
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text('Duyệt'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () async {
                                        final reason = await _askRejectReason();
                                        if (reason == null || reason.trim().isEmpty) return;
                                        await bookingProvider.rejectBooking(
                                          b.id,
                                          by: auth.displayEmail ?? auth.role.labelVi,
                                          reason: reason.trim(),
                                          role: auth.role,
                                          ownerBoatIds: ownerBoatIds,
                                        );
                                      },
                                      style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
                                      icon: const Icon(Icons.block),
                                      label: const Text('Từ chối'),
                                    ),
                                  ),
                                ],
                              ),
                            if (!canReview)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push('/bookings/detail/${b.id}'),
                                  child: const Text('Xem chi tiết'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (scopedBoats.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _calendarBoatId,
                      items: scopedBoats
                          .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _calendarBoatId = v),
                      decoration: const InputDecoration(labelText: 'Chọn thuyền'),
                    ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          final base = _toDateOnly(_calendarDate);
                          final copied = <DateTime>{};
                          for (var i = 0; i < 7; i++) {
                            copied.add(base.subtract(Duration(days: 7 - i)));
                          }
                          setState(() {
                            _calendarSelectedDays
                              ..clear()
                              ..addAll(copied);
                          });
                        },
                        icon: const Icon(Icons.copy_all_outlined),
                        label: const Text('Copy tuần trước'),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _calendarSelectedDays.clear()),
                        child: const Text('Bỏ chọn nhiều ngày'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TableCalendar<Booking>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _calendarDate,
                    selectedDayPredicate: (day) =>
                        isSameDay(day, _calendarDate) || _calendarSelectedDays.contains(_toDateOnly(day)),
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (f) => setState(() => _calendarFormat = f),
                    onDaySelected: (selectedDay, focusedDay) {
                      final dateOnly = _toDateOnly(selectedDay);
                      setState(() {
                        _calendarDate = selectedDay;
                        if (_calendarSelectedDays.contains(dateOnly)) {
                          _calendarSelectedDays.remove(dateOnly);
                        } else {
                          _calendarSelectedDays.add(dateOnly);
                        }
                      });
                    },
                    eventLoader: (day) {
                      if (_calendarBoatId == null) return const <Booking>[];
                      return bookingProvider.systemByBoatAndDate(boatId: _calendarBoatId!, date: day);
                    },
                    calendarStyle: const CalendarStyle(
                      markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (_calendarBoatId == null) return null;
                        final count = bookingProvider
                            .systemByBoatAndDate(boatId: _calendarBoatId!, date: day)
                            .where((e) => e.status == BookingStatus.pending || e.status == BookingStatus.confirmed)
                            .length;
                        if (count < 3) return null;
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.deepOrange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedBoat != null)
                    FilledButton.icon(
                      onPressed: () async {
                        final selectedDates = _calendarSelectedDays.isEmpty
                            ? <DateTime>{_toDateOnly(_calendarDate)}
                            : _calendarSelectedDays;
                        final blocked = Set<String>.from(selectedBoat.blockedDateYmd);
                        var blockedDays = 0;
                        var openedDays = 0;
                        var rejectedTotal = 0;
                        final blockedDateStrings = selectedDates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toSet();
                        final shouldOpen = blockedDateStrings.every(blocked.contains);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(shouldOpen ? 'Mở lịch nhiều ngày?' : 'Khóa lịch nhiều ngày?'),
                            content: Text(
                              shouldOpen
                                  ? 'Sẽ mở ${selectedDates.length} ngày đã chọn.'
                                  : 'Sẽ khóa ${selectedDates.length} ngày đã chọn và tự từ chối booking pending trong các ngày đó.',
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Xác nhận'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        for (final d in selectedDates) {
                          final dYmd = DateFormat('yyyy-MM-dd').format(d);
                          if (shouldOpen) {
                            if (blocked.remove(dYmd)) openedDays++;
                            continue;
                          }
                          final dayBookings = bookingProvider.systemByBoatAndDate(boatId: selectedBoat.id, date: d);
                          final dayHasConfirmed = dayBookings.any((b) => b.status == BookingStatus.confirmed);
                          if (dayHasConfirmed) continue;
                          final rejected = await bookingProvider.rejectPendingByBoatAndDate(
                            boatId: selectedBoat.id,
                            date: d,
                            role: auth.role,
                            ownerBoatIds: ownerBoatIds,
                          );
                          rejectedTotal += rejected;
                          if (blocked.add(dYmd)) blockedDays++;
                        }
                        final scopedOk = await boatProvider.setBlockedDatesScoped(
                          selectedBoat.id,
                          blocked,
                          role: auth.role,
                          actorEmail: auth.displayEmail,
                        );
                        if (!scopedOk) return;
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              shouldOpen
                                  ? 'Đã mở $openedDays ngày'
                                  : 'Đã khóa $blockedDays ngày, tự từ chối $rejectedTotal pending',
                            ),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: isBlocked ? Colors.green : Colors.orange,
                      ),
                      icon: Icon(isBlocked ? Icons.lock_open : Icons.lock_outline),
                      label: Text(isBlocked ? 'Mở lịch ngày đã chọn' : 'Khóa lịch ngày đã chọn'),
                    ),
                  const SizedBox(height: 12),
                  Text('Lịch thuyền trong ngày', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (daySchedule.isEmpty) const Text('Không có booking trong ngày này'),
                  ...daySchedule.map(
                    (b) => Card(
                      child: ListTile(
                        title: Text('${DateFormat('HH:mm').format(b.startAt)} - ${DateFormat('HH:mm').format(b.endAt)}'),
                        subtitle: Text('Khách: ${b.passengerCount} • ${b.id}'),
                        trailing: BookingStatusBadge(status: b.status, compact: true),
                        onTap: () => context.push('/bookings/detail/${b.id}'),
                      ),
                    ),
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Quản lý mã khuyến mãi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showPromoDialog(context, promoProvider, auth, scopedBoats),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm mã'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...promoProvider
                      .promosForOwner(auth.role == UserRole.admin ? null : auth.displayEmail)
                      .map(
                        (p) => Card(
                          child: ListTile(
                            title: Text('${p.code} (-${(p.discountPercent * 100).toStringAsFixed(0)}%)'),
                            subtitle: Text(
                              'Owner: ${p.ownerEmail}\nĐã dùng ${p.usedCount}${p.usageLimitTotal == null ? '' : '/${p.usageLimitTotal}'}'
                              '${p.minHours == null ? '' : ' • Tối thiểu ${p.minHours}h'}'
                              '${p.expiresAt == null ? '' : '\nHết hạn: ${DateFormat('dd/MM/yyyy').format(p.expiresAt!)}'}',
                            ),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  onPressed: () => _showPromoDialog(
                                    context,
                                    promoProvider,
                                    auth,
                                    scopedBoats,
                                    editing: p,
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await promoProvider.deletePromo(
                                      p.id,
                                      actorEmail: auth.displayEmail ?? '',
                                      isAdmin: auth.role == UserRole.admin,
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _periodBar(String label, double value, Color color) {
    final maxWidth = (value / 1000000).clamp(0, 240).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label)),
          Expanded(
            child: Container(
              height: 18,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: maxWidth,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(NumberFormat.compact(locale: 'vi_VN').format(value)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Future<String?> _askRejectReason() async {
    final c = TextEditingController();
    String? selectedPreset;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Lý do từ chối'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPreset,
                decoration: const InputDecoration(labelText: 'Mẫu lý do'),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Chọn mẫu (tuỳ chọn)')),
                  ..._rejectReasonPresets.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))),
                ],
                onChanged: (v) => setDialog(() {
                  selectedPreset = v;
                  if (v != null) c.text = v;
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: c,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Nhập lý do'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Từ chối booking')),
          ],
        ),
      ),
    );
    if (ok != true) return null;
    return c.text;
  }

  Future<void> _showBoatDialog(
    BuildContext context,
    BoatProvider boatProvider,
    AuthProvider auth, {
    Boat? boat,
  }) async {
    final name = TextEditingController(text: boat?.name ?? '');
    final desc = TextEditingController(text: boat?.description ?? '');
    final cap = TextEditingController(text: '${boat?.capacity ?? 10}');
    final price = TextEditingController(text: '${boat?.hourlyPrice ?? 900000}');
    final gallery = TextEditingController(text: boat?.gallery.join(', ') ?? '');
    final owner = TextEditingController(text: boat?.ownerEmail ?? (auth.displayEmail ?? 'owner@hancruise.local'));
    final picker = ImagePicker();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(boat == null ? 'Thêm thuyền' : 'Sửa thuyền'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên thuyền')),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Mô tả')),
              TextField(
                controller: cap,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sức chứa'),
              ),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá/giờ'),
              ),
              if (auth.role == UserRole.admin)
                TextField(
                  controller: owner,
                  decoration: const InputDecoration(labelText: 'Owner email'),
                ),
              TextField(
                controller: gallery,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Ảnh URL (ngăn cách dấu phẩy)'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked == null) return;
                    final current = gallery.text.trim();
                    gallery.text = current.isEmpty ? picked.path : '$current, ${picked.path}';
                  },
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Tải ảnh từ máy'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lưu')),
        ],
      ),
    );

    if (ok != true) return;
    final parsedCap = int.tryParse(cap.text.trim()) ?? -1;
    final parsedPrice = double.tryParse(price.text.trim()) ?? -1;
    final parsedGallery = gallery.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      if (boat == null) {
        await boatProvider.addBoat(
          name: name.text.trim(),
          description: desc.text.trim(),
          capacity: parsedCap,
          hourlyPrice: parsedPrice,
          gallery: parsedGallery,
          ownerEmail: auth.role == UserRole.admin ? owner.text.trim() : (auth.displayEmail ?? owner.text.trim()),
        );
        return;
      }
      final okScoped = await boatProvider.updateBoatScoped(
        boat.copyWith(
          name: name.text.trim(),
          description: desc.text.trim(),
          capacity: parsedCap,
          hourlyPrice: parsedPrice,
          gallery: parsedGallery,
          ownerEmail: auth.role == UserRole.admin ? owner.text.trim() : boat.ownerEmail,
        ),
        role: auth.role,
        actorEmail: auth.displayEmail,
      );
      if (!okScoped && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có quyền sửa thuyền này')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showPromoDialog(
    BuildContext context,
    PromoProvider promoProvider,
    AuthProvider auth,
    List<Boat> scopedBoats, {
    OwnerPromoCode? editing,
  }) async {
    final code = TextEditingController(text: editing?.code ?? '');
    final discount = TextEditingController(
      text: editing == null ? '10' : (editing.discountPercent * 100).toStringAsFixed(0),
    );
    final limit = TextEditingController(text: editing?.usageLimitTotal?.toString() ?? '');
    final minHours = TextEditingController(text: editing?.minHours?.toString() ?? '');
    DateTime? expiresAt = editing?.expiresAt;
    final selectedBoatIds = <String>{...?(editing?.boatScopeIds)};
    var isActive = editing?.isActive ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(editing == null ? 'Tạo mã khuyến mãi' : 'Sửa mã khuyến mãi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: code, decoration: const InputDecoration(labelText: 'Mã code')),
                TextField(
                  controller: discount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giảm (%)'),
                ),
                TextField(
                  controller: limit,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giới hạn lượt (tuỳ chọn)'),
                ),
                TextField(
                  controller: minHours,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tối thiểu số giờ (tuỳ chọn)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                    );
                    if (picked != null) setDialog(() => expiresAt = picked);
                  },
                  icon: const Icon(Icons.event_outlined),
                  label: Text(expiresAt == null
                      ? 'Chọn hạn dùng (tuỳ chọn)'
                      : 'Hạn dùng: ${DateFormat('dd/MM/yyyy').format(expiresAt!)}'),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Phạm vi thuyền (trống = tất cả thuyền của owner)'),
                ),
                const SizedBox(height: 4),
                ...scopedBoats.map(
                  (b) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: selectedBoatIds.contains(b.id),
                    onChanged: (v) => setDialog(() {
                      if (v == true) {
                        selectedBoatIds.add(b.id);
                      } else {
                        selectedBoatIds.remove(b.id);
                      }
                    }),
                    title: Text(b.name),
                  ),
                ),
                if (editing != null)
                  SwitchListTile(
                    value: isActive,
                    onChanged: (v) => setDialog(() => isActive = v),
                    title: const Text('Kích hoạt'),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final actorEmail = auth.displayEmail?.trim() ?? '';
    if (actorEmail.isEmpty) return;
    if (editing == null) {
      await promoProvider.addPromo(
        ownerEmail: actorEmail,
        code: code.text.trim(),
        discountPercent: (double.tryParse(discount.text.trim()) ?? 0) / 100,
        usageLimitTotal: int.tryParse(limit.text.trim()),
        expiresAt: expiresAt,
        minHours: int.tryParse(minHours.text.trim()),
        boatScopeIds: selectedBoatIds.toList(),
      );
      return;
    }
    await promoProvider.updatePromo(
      id: editing.id,
      actorEmail: actorEmail,
      isAdmin: auth.role == UserRole.admin,
      code: code.text.trim(),
      discountPercent: (double.tryParse(discount.text.trim()) ?? 0) / 100,
      usageLimitTotal: int.tryParse(limit.text.trim()),
      expiresAt: expiresAt,
      minHours: int.tryParse(minHours.text.trim()),
      boatScopeIds: selectedBoatIds.toList(),
      isActive: isActive,
    );
  }
}
