import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final int? initialCapacity;
  final Function(DateTime?, int?) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialDate,
    this.initialCapacity,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  DateTime? _date;
  int _capacity = 0;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _capacity = widget.initialCapacity ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lọc thuyền', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              title: Text(_date == null
                  ? 'Chọn ngày sử dụng'
                  : DateFormat('dd/MM/yyyy').format(_date!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 12),
            Text('Số người tối thiểu: $_capacity'),
            Slider(
              value: _capacity.toDouble(),
              min: 0,
              max: 50,
              divisions: 50,
              label: _capacity.toString(),
              onChanged: (val) => setState(() => _capacity = val.round()),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(_date, _capacity > 0 ? _capacity : null);
                    Navigator.pop(context);
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}