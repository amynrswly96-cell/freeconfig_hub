import 'package:flutter/material.dart';

/// رنگ‌های ثابت برنامه بر اساس طراحی Premium / Glassmorphism
class AppColors {
  AppColors._();

  // ---------- Dark Theme ----------
  static const Color darkBackground = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color primary = Color(0xFF4F8CFF);
  static const Color secondary = Color(0xFF7A5CFF);
  static const Color accent = Color(0xFF00D4FF);

  // ---------- Light Theme ----------
  static const Color lightBackground = Color(0xFFF8FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // ---------- Status Colors ----------
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFFF5C5C);

  // Ping quality colors
  static Color pingColor(int ms) {
    if (ms <= 0) return const Color(0xFF9AA5B1); // نامشخص
    if (ms < 150) return success;
    if (ms < 350) return warning;
    return error;
  }

  static const LinearGradient connectButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, secondary],
  );

  static const LinearGradient glowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
}
