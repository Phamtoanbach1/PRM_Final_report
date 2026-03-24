import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../domain/booking_model.dart';
import '../providers/booking_provider.dart';
import 'widgets/booking_status_badge.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _filterIndex = 0; // 0: all, 1: pending, 2: confirmed, 3: cancelled

  static const _filters = <String>[
    'Tất cả',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Đã hủy',
  ];

  BookingStatus? _statusForIndex(int i) {
    switch (i) {
      case 1:
        return BookingStatus.pending;
      case 2:
        return BookingStatus.confirmed;
      case 3:
        return BookingStatus.cancelled;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bookings/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Đặt thuyền', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Đặt thuyền',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: _filters[i],
                        selected: _filterIndex == i,
                        onTap: () => setState(() => _filterIndex = i),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<BookingProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.bookings.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final status = _statusForIndex(_filterIndex);
                  final list = provider.filteredByStatus(status);
                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sailing_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có booking nào',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.push('/bookings/create'),
                              child: const Text('Tạo booking đầu tiên'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: provider.load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final b = list[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Material(
                            color: AppColors.cardLight,
                            elevation: 0,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => context.push('/bookings/detail/${b.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            b.boatName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                        BookingStatusBadge(status: b.status, compact: true),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _rowIcon(Icons.calendar_month_outlined,
                                        '${dateFmt.format(b.startAt)} → ${dateFmt.format(b.endAt)}'),
                                    const SizedBox(height: 6),
                                    _rowIcon(Icons.people_outline, '${b.passengerCount} khách'),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        currency.format(b.totalPrice),
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowIcon(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
