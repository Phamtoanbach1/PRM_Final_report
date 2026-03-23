import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prm_final_report/models/booking_model.dart';
import 'package:prm_final_report/viewmodels/booking_viewmodel.dart';
import 'package:prm_final_report/utils/app_theme.dart';
import 'package:prm_final_report/widgets/custom_button.dart';

class BookingDetailPage extends ConsumerWidget {
  final Booking booking;
  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool canCancel = booking.status != BookingStatus.cancelled && 
                           DateFormat('yyyy-MM-dd').parse(booking.date).isAfter(DateTime.now().subtract(const Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Boat Booking #${booking.id}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSection(booking.status),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.person_outline, 'User Name', booking.userName),
                  _buildInfoRow(Icons.calendar_today, 'Date', booking.date),
                  _buildInfoRow(Icons.access_time, 'Time Slot', '${booking.startTime.format(context)} - ${booking.endTime.format(context)}'),
                  _buildInfoRow(Icons.people_outline, 'Guests', '${booking.numberOfPeople} People'),
                  const Divider(height: 48),
                  _buildPriceSection(booking.totalPrice),
                  const SizedBox(height: 48),
                  if (canCancel)
                    CustomButton(
                      text: 'Cancel Booking',
                      isPrimary: false,
                      onPressed: () => _confirmCancellation(context, ref),
                    ),
                  if (booking.status == BookingStatus.cancelled)
                    const Center(
                      child: Text('This booking has been cancelled.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BookingStatus status) {
    Color color = Colors.orange;
    if (status == BookingStatus.confirmed) color = Colors.green;
    if (status == BookingStatus.cancelled) color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text('\$${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
          ],
        ),
      ],
    );
  }

  void _confirmCancellation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep it')),
          TextButton(
            onPressed: () {
              ref.read(bookingListProvider.notifier).cancelBooking(booking.id!);
              Navigator.pop(context);
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
