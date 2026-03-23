import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../viewmodels/booking_viewmodel.dart';

class OperatorBookingPage extends ConsumerWidget {
  const OperatorBookingPage({super.key});

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Operator: Manage Bookings')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (bookings) {
          if (bookings.isEmpty) return const Center(child: Text('No bookings yet'));
          return RefreshIndicator(
            onRefresh: () => ref.read(bookingListProvider.notifier).loadBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final canAction = booking.status == BookingStatus.pending;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text('${booking.boatName} • ${booking.date}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(booking.status).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(booking.status.name, style: TextStyle(color: _statusColor(booking.status), fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 8),
                      Text('Time: ${booking.startTime} - ${booking.endTime} | ${booking.numberOfPeople} people'),
                      Text('Price: ${booking.totalPrice.toStringAsFixed(0)} đ'),
                      if (booking.status == BookingStatus.pending) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: ElevatedButton(onPressed: () async {await ref.read(bookingListProvider.notifier).approveBooking(booking);}, child: const Text('Approve')),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () async {await ref.read(bookingListProvider.notifier).rejectBooking(booking);}, child: const Text('Reject')),
                          ),
                        ]),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text('No actions available', style: TextStyle(color: Colors.grey[700])),
                      ],
                    ]),
                  ),
                );
              },
            ),
          );
        },
      ),

    );
  }
}
