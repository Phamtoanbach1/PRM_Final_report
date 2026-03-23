import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boat_model.dart';
import '../models/booking_model.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../../booking/pages/boat_list_page.dart';

class BookingFormPage extends ConsumerStatefulWidget {
  final int boatId;

  const BookingFormPage({super.key, required this.boatId});

  @override
  ConsumerState<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends ConsumerState<BookingFormPage> {
  late Boat boat;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
  int people = 1;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    boat = boats.firstWhere((element) => element.id == widget.boatId);
  }

  String get dateText => '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

  String formatTime(TimeOfDay t) => t.format(context);

  String get startTimeText => '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  String get endTimeText => '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  double get totalPrice {
    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
    final end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute);
    if (!start.isBefore(end)) return 0;
    final hours = end.difference(start).inMinutes / 60;
    return hours * boat.pricePerHour;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final initial = isStart ? startTime : endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) startTime = picked;
        else endTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    setState(() => errorMessage = null);
    if (!TimeOfDay(hour: startTime.hour, minute: startTime.minute).isBefore(endTime)) {
      setState(() => errorMessage = 'Thời gian phải bắt đầu trước khi kết thúc');
      return;
    }
    if (people < 1 || people > boat.capacity) {
      setState(() => errorMessage = 'Số người phải trong 1..${boat.capacity}');
      return;
    }

    final viewModel = ref.read(bookingListProvider.notifier);
    final booking = Booking(
      boatId: boat.id,
      boatName: boat.name,
      date: dateText,
      startTime: startTimeText,
      endTime: endTimeText,
      numberOfPeople: people,
      totalPrice: totalPrice,
      status: BookingStatus.pending,
    );

    final conflictError = await viewModel.createBooking(booking);
    if (conflictError != null) {
      setState(() => errorMessage = conflictError);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created successfully')));
      Navigator.of(context).pushReplacementNamed('/bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Form')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(boat.image, height: 180, width: double.infinity, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text(boat.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Giá: ${boat.pricePerHour.toStringAsFixed(0)}đ/h | Sức chứa: ${boat.capacity}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 18),
              const Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(dateText),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Giờ bắt đầu', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ElevatedButton(onPressed: () => _selectTime(isStart: true), child: Text(formatTime(startTime))),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Giờ kết thúc', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ElevatedButton(onPressed: () => _selectTime(isStart: false), child: Text(formatTime(endTime))),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              const Text('Số người', style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(value: people.toDouble(), min: 1, max: boat.capacity.toDouble(), divisions: boat.capacity - 1, label: people.toString(), onChanged: (v) => setState(() => people = v.toInt())),
              const SizedBox(height: 8),
              Text('Chọn $people người', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Text('Giá tạm tính: ${totalPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 10),
              if (errorMessage != null) ...[
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  child: const Text('Đặt ngay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
