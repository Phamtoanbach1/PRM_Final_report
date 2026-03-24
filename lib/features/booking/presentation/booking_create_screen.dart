import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../boats/domain/boat.dart';
import '../../boats/providers/boat_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/promo_provider.dart';

class BookingCreateScreen extends StatefulWidget {
  const BookingCreateScreen({super.key, this.prefillBoatId});

  /// Gắn với bản đồ / tour trên trang chủ (ID trùng [kBoatOptions]).
  final String? prefillBoatId;

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  static const Map<String, double> _promoRules = {
    'GIAM10': 0.10,
    'GIAM20': 0.20,
    'LINHVIP': 0.15,
  };

  Boat? _boat;
  DateTime _day = DateTime.now();
  TimeOfDay _startT = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endT = const TimeOfDay(hour: 11, minute: 0);
  int _passengers = 2;
  final _note = TextEditingController();
  final _promo = TextEditingController();
  bool _submitting = false;
  String? _appliedPromoCode;
  double _appliedDiscountPercent = 0;

  @override
  void initState() {
    super.initState();
  }

  DateTime _combine(DateTime day, TimeOfDay t) {
    return DateTime(day.year, day.month, day.day, t.hour, t.minute);
  }

  @override
  void dispose() {
    _note.dispose();
    _promo.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final selectedBoat = _boat;
    if (selectedBoat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thuyền trước khi áp dụng mã')),
      );
      return;
    }
    final code = _promo.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập mã giảm giá trước khi áp dụng')),
      );
      return;
    }
    final start = _combine(_day, _startT);
    final end = _combine(_day, _endT);
    final promoProvider = context.read<PromoProvider>();
    final dynamicResult = promoProvider.validatePromo(
      code: code,
      boatId: selectedBoat.id,
      boatOwnerEmail: selectedBoat.ownerEmail,
      start: start,
      end: end,
    );
    final fallbackPercent = _promoRules[code];
    final percent = dynamicResult.ok ? dynamicResult.promo!.discountPercent : fallbackPercent;
    if (percent == null) {
      setState(() {
        _appliedPromoCode = null;
        _appliedDiscountPercent = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dynamicResult.reason ?? 'Mã giảm giá không hợp lệ')),
      );
      return;
    }
    setState(() {
      _appliedPromoCode = code;
      _appliedDiscountPercent = percent;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã áp dụng mã $code (-${(percent * 100).toInt()}%)')),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _day.isBefore(first) ? first : _day,
      firstDate: first,
      lastDate: first.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startT : _endT;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startT = picked;
        } else {
          _endT = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    final provider = context.read<BookingProvider>();
    final promoProvider = context.read<PromoProvider>();
    final auth = context.read<AuthProvider>();
    final selectedBoat = _boat;
    if (selectedBoat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thuyền')),
      );
      return;
    }
    if (auth.isShopOwner &&
        selectedBoat.ownerEmail.toLowerCase() == (auth.displayEmail ?? '').toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop owner không thể đặt thuyền của chính mình')),
      );
      return;
    }
    final start = _combine(_day, _startT);
    final end = _combine(_day, _endT);

    final err = provider.validateSlot(boatId: selectedBoat.id, start: start, end: end);
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    setState(() => _submitting = true);
    final rawNote = _note.text.trim();
    final mergedNote = _appliedPromoCode == null
        ? (rawNote.isEmpty ? null : rawNote)
        : '${rawNote.isEmpty ? '' : '$rawNote\n'}Mã giảm giá: $_appliedPromoCode';
    final ok = await provider.createBooking(
      boatId: selectedBoat.id,
      boatName: selectedBoat.name,
      boatHourlyPrice: selectedBoat.hourlyPrice,
      start: start,
      end: end,
      passengerCount: _passengers,
      note: mergedNote,
      promoCode: _appliedPromoCode,
      discountPercent: _appliedDiscountPercent > 0 ? _appliedDiscountPercent : null,
    );
    setState(() => _submitting = false);

    if (!mounted) return;
    if (ok) {
      final applied = _appliedPromoCode;
      if (applied != null) {
        final validation = promoProvider.validatePromo(
          code: applied,
          boatId: selectedBoat.id,
          boatOwnerEmail: selectedBoat.ownerEmail,
          start: start,
          end: end,
        );
        final promo = validation.promo;
        if (promo != null) {
          await promoProvider.markPromoUsed(promo.id);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo booking — chờ xác nhận')),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo booking. Kiểm tra lại lịch trùng.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final boatProvider = context.watch<BoatProvider>();
    final boats = boatProvider.allBoats;
    if (_boat == null && boats.isNotEmpty) {
      _boat = boats.firstWhere(
        (b) => b.id == widget.prefillBoatId,
        orElse: () => boats.first,
      );
    }
    final start = _combine(_day, _startT);
    final end = _combine(_day, _endT);
    final selectedBoat = _boat;
    final originalPrice = provider.calculatePrice(
      start: start,
      end: end,
      passengerCount: _passengers,
      boatHourlyPrice: selectedBoat?.hourlyPrice,
    );
    final finalPrice = originalPrice * (1 - _appliedDiscountPercent);
    final discountAmount = originalPrice - finalPrice;
    final conflict = selectedBoat == null
        ? null
        : provider.validateSlot(boatId: selectedBoat.id, start: start, end: end);
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tạo booking'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const Text(
            'Chọn thuyền',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Boat>(
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                value: selectedBoat,
                items: boats
                    .map(
                      (b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _boat = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ngày',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          _TileButton(
            icon: Icons.event,
            label: DateFormat('dd/MM/yyyy').format(_day),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giờ bắt đầu', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _TileButton(
                      icon: Icons.schedule,
                      label: timeFmt.format(start),
                      onTap: () => _pickTime(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giờ kết thúc', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _TileButton(
                      icon: Icons.schedule_outlined,
                      label: timeFmt.format(end),
                      onTap: () => _pickTime(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Số khách', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
                onPressed: _passengers > 1 ? () => setState(() => _passengers--) : null,
                icon: const Icon(Icons.remove, color: AppColors.primary),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$_passengers',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
                onPressed: _passengers < 50 ? () => setState(() => _passengers++) : null,
                icon: const Icon(Icons.add, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promo,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Mã giảm giá',
              hintText: 'Ví dụ: GIAM10, GIAM20, LINHVIP',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8),
                child: FilledButton(
                  onPressed: _applyPromo,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(88, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ),
            ),
            onChanged: (_) {
              if (_appliedPromoCode != null) {
                setState(() {
                  _appliedPromoCode = null;
                  _appliedDiscountPercent = 0;
                });
              }
            },
          ),
          if (_appliedPromoCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Đã áp dụng $_appliedPromoCode (-${(_appliedDiscountPercent * 100).toInt()}%)',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Ghi chú (tuỳ chọn)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ước tính giá',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  currency.format(finalPrice),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_appliedDiscountPercent > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Giá gốc: ${currency.format(originalPrice)} • Giảm: ${currency.format(discountAmount)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Gồm phí thuyền theo giờ + phí khách theo giờ (demo)',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                ),
              ],
            ),
          ),
          if (conflict != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conflict,
                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: (_submitting || conflict != null || selectedBoat == null) ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Xác nhận đặt thuyền', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
