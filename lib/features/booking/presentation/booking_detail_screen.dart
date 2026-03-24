import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../domain/booking_model.dart';
import '../providers/booking_provider.dart';
import 'widgets/booking_status_badge.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final b = provider.byId(bookingId);
        if (b == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết')),
            body: const Center(child: Text('Không tìm thấy booking')),
          );
        }

        final canCancel =
            b.status == BookingStatus.pending || b.status == BookingStatus.confirmed;
        final canConfirmDemo = b.status == BookingStatus.pending;
        final canPay = b.status != BookingStatus.cancelled;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Chi tiết booking'),
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textPrimary,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Center(child: BookingStatusBadge(status: b.status)),
              const SizedBox(height: 20),
              _card(
                children: [
                  _line('Thuyền', b.boatName, Icons.sailing),
                  const Divider(height: 24),
                  _line('Bắt đầu', dateFmt.format(b.startAt), Icons.play_circle_outline),
                  const SizedBox(height: 12),
                  _line('Kết thúc', dateFmt.format(b.endAt), Icons.stop_circle_outlined),
                  const Divider(height: 24),
                  _line('Số khách', '${b.passengerCount}', Icons.people_outline),
                  const Divider(height: 24),
                  _line('Tạo lúc', dateFmt.format(b.createdAt), Icons.history),
                  if (b.note != null && b.note!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _line('Ghi chú', b.note!, Icons.note_outlined),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      currency.format(b.totalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (canPay)
                FilledButton.icon(
                  onPressed: () => context.push('/payment', extra: b),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text('Thanh toán'),
                ),
              if (canPay) const SizedBox(height: 12),
              if (canConfirmDemo)
                OutlinedButton.icon(
                  onPressed: () async {
                    await provider.confirmBooking(b.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xác nhận booking (demo)')),
                      );
                    }
                  },
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Xác nhận (demo — phía đơn vị)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              if (canConfirmDemo) const SizedBox(height: 12),
              if (canCancel)
                FilledButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hủy booking?'),
                        content: const Text('Bạn có chắc muốn hủy booking này?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hủy booking'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await provider.cancelBooking(b.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã hủy booking')),
                        );
                        context.pop();
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Hủy booking'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _line(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}
