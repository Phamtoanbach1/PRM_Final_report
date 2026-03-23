import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0A2463); // Deep Blue Ocean
  static const Color secondary = Color(0xFF3E92CC); // Light Azure
  static const Color background = Color(0xFFF4F7F6); // Soft Light Gray
  static const Color backgroundDark = Color(0xFF0F172A); // Dark Slate Blue
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color accent = Color(0xFF38BDF8); // Neon Blue highlights
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradientLight = LinearGradient(
    colors: [Color(0x99FFFFFF), Color(0x33FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient glassGradientDark = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF0A2463), Color(0xFF00B4D8)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
