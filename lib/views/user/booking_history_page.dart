import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prm_final_report/models/booking_model.dart';
import 'package:prm_final_report/viewmodels/booking_viewmodel.dart';
import 'package:prm_final_report/utils/app_theme.dart';
import 'package:prm_final_report/views/user/booking_detail_page.dart';

class BookingHistoryPage extends ConsumerWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingListAsync = ref.watch(bookingListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGradient1,
      appBar: AppBar(
        title: const Text('My Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookingListAsync.when(
        data: (bookings) => bookings.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _BookingCard(booking: booking);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No bookings found.', style: TextStyle(color: Colors.grey, fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Book a boat now'),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(booking.status);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookingDetailPage(booking: booking)),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Boat #${booking.boatId}', // Ideally fetch boat name
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  _buildStatusBadge(booking.status, statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(booking.date, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${booking.startTime.format(context)} - ${booking.endTime.format(context)}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryBlue),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return Colors.orange;
      case BookingStatus.confirmed: return Colors.green;
      case BookingStatus.cancelled: return Colors.red;
    }
  }
}
