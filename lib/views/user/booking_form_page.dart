import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prm_final_report/models/boat_model.dart';
import 'package:prm_final_report/models/booking_model.dart';
import 'package:prm_final_report/viewmodels/booking_viewmodel.dart';
import 'package:prm_final_report/utils/app_theme.dart';
import 'package:prm_final_report/widgets/custom_button.dart';

class BookingFormPage extends ConsumerStatefulWidget {
  final Boat boat;
  const BookingFormPage({super.key, required this.boat});

  @override
  ConsumerState<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends ConsumerState<BookingFormPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  int _numberOfPeople = 1;
  final TextEditingController _nameController = TextEditingController();
  String? _errorMessage;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _updatePrice();
  }

  void _updatePrice() {
    final notifier = ref.read(bookingListProvider.notifier);
    setState(() {
      _totalPrice = notifier.calculateTotalPrice(widget.boat, _startTime, _endTime);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _updatePrice();
    }
  }

  void _handleBooking() async {
    setState(() => _errorMessage = null);
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final notifier = ref.read(bookingListProvider.notifier);
    
    // 1. Validate Business Logic (Conflicts, Capacity, Time)
    final validationError = await notifier.validateBooking(
      widget.boat, dateStr, _startTime, _endTime, _numberOfPeople
    );
    
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }
    
    if (_nameController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter your name.");
      return;
    }

    // 2. Create Booking
    final newBooking = Booking(
      boatId: widget.boat.id!,
      userName: _nameController.text,
      date: dateStr,
      startTime: _startTime,
      endTime: _endTime,
      numberOfPeople: _numberOfPeople,
      totalPrice: _totalPrice,
    );

    final success = await notifier.createBooking(newBooking);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Successful!')),
      );
      Navigator.pop(context); // Back to boat detail
      Navigator.pushReplacementNamed(context, '/booking-history'); // Navigate to history
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Your Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boat Info Header
            Text(widget.boat.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('\$${widget.boat.price.toStringAsFixed(0)} / hour', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),

            // Date Picker Card
            _buildSectionTitle('Date'),
            _buildPickerCard(
              icon: Icons.calendar_today,
              label: DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
              onTap: () => _selectDate(context),
            ),

            const SizedBox(height: 24),

            // Time Picker Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Start Time'),
                      _buildPickerCard(
                        icon: Icons.access_time,
                        label: _startTime.format(context),
                        onTap: () => _selectTime(context, true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('End Time'),
                      _buildPickerCard(
                        icon: Icons.access_time,
                        label: _endTime.format(context),
                        onTap: () => _selectTime(context, false),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Guests Counter
            _buildSectionTitle('Number of People'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => _numberOfPeople > 1 ? _numberOfPeople-- : null),
                  ),
                  Text('$_numberOfPeople', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _numberOfPeople < widget.boat.capacity ? _numberOfPeople++ : null),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // User Name
            _buildSectionTitle('Your Name'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter full name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            ],

            const SizedBox(height: 32),

            // Price Breakdown Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Estimated Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('\$${_totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'Confirm Booking',
              onPressed: _handleBooking,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildPickerCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
