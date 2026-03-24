import 'package:flutter/material.dart';

import '../../domain/booking_model.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status, this.compact = false});

  final BookingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: compact ? 14 : 16, color: style.foreground),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.labelVi,
            style: TextStyle(
              color: style.foreground,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeStyle _styleFor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return _BadgeStyle(
          background: const Color(0xFFFFF8E6),
          border: const Color(0xFFFFC107).withValues(alpha: 0.5),
          foreground: const Color(0xFFB45309),
          icon: Icons.hourglass_top_rounded,
        );
      case BookingStatus.confirmed:
        return _BadgeStyle(
          background: const Color(0xFFE8F5E9),
          border: const Color(0xFF4CAF50).withValues(alpha: 0.4),
          foreground: const Color(0xFF1B5E20),
          icon: Icons.check_circle_outline,
        );
      case BookingStatus.cancelled:
        return _BadgeStyle(
          background: const Color(0xFFFFEBEE),
          border: const Color(0xFFE57373).withValues(alpha: 0.5),
          foreground: const Color(0xFFC62828),
          icon: Icons.cancel_outlined,
        );
    }
  }
}

class _BadgeStyle {
  const _BadgeStyle({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;
}
