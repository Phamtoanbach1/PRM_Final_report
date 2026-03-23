import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../viewmodels/booking_viewmodel.dart';

class BookingListPage extends ConsumerWidget {
  const BookingListPage({super.key});

  Color _colorForStatus(BookingStatus status) {
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
      appBar: AppBar(title: const Text('My Bookings')),
      body: state.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.schedule, size: 64, color: Colors.grey), SizedBox(height: 12), Text('Không có booking nào', style: TextStyle(color: Colors.grey))]));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(bookingListProvider.notifier).loadBookings(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).pushNamed('/bookings/${booking.id}'),
                    title: Text(booking.boatName),
                    subtitle: Text('${booking.date} | ${booking.startTime} - ${booking.endTime} | ${booking.numberOfPeople}ppl'),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('${booking.totalPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _colorForStatus(booking.status).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(booking.status.name, style: TextStyle(color: _colorForStatus(booking.status), fontWeight: FontWeight.bold, fontSize: 12))),
                    ]),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/boats'),
        child: const Icon(Icons.add),
        tooltip: 'Book new boat',
      ),
    );
  }
}
