import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../viewmodels/booking_viewmodel.dart';

class BookingDetailPage extends ConsumerWidget {
  final int bookingId;

  const BookingDetailPage({super.key, required this.bookingId});

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
    final bookingState = ref.watch(bookingListProvider);
    final booking = bookingState.maybeWhen(
      data: (list) {
        final found = list.where((b) => b.id == bookingId);
        return found.isNotEmpty ? found.first : null;
      },
      orElse: () => null,
    );

    if (booking == null) {
      return Scaffold(appBar: AppBar(title: const Text('Booking detail')), body: const Center(child: Text('Không tìm thấy booking')));
    }

    final now = DateTime.now();
    final bookingEnd = DateTime.parse('${booking.date} ${booking.endTime}');
    final canCancel = (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed) && bookingEnd.isAfter(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.boatName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Text('Booking status: ', style: TextStyle(fontWeight: FontWeight.bold)), Text(booking.status.name, style: TextStyle(color: _colorForStatus(booking.status), fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          _infoRow('Date', booking.date),
          _infoRow('Time', '${booking.startTime} - ${booking.endTime}'),
          _infoRow('People', booking.numberOfPeople.toString()),
          _infoRow('Total price', '${booking.totalPrice.toStringAsFixed(0)} đ'),
          const SizedBox(height: 20),
          if (canCancel)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Confirm cancel'), content: const Text('Are you sure you want to cancel this booking?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('No')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Yes'))]));
                  if (confirmed == true) {
                    await ref.read(bookingListProvider.notifier).cancelBooking(booking);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Cancel Booking'),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)]),
      );
}
