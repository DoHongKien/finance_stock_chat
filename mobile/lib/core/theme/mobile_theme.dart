import 'package:flutter/material.dart';
import '../constants/stock_colors.dart';

/// Theme Dark Mode Tiết Kiệm Pin Màn Hình OLED Cho Điện Thoại Di Động
class MobileFinanceTheme {
  MobileFinanceTheme._();

  static const Color backgroundOled = Color(0xFF0A0D14);
  static const Color surfaceCard = Color(0xFF151D2A);
  static const Color surfaceCardElevated = Color(0xFF1A2332);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color borderSubtle = Color(0xFF222E42);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundOled,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentCyan,
        surface: surfaceCard,
        error: Color(0xFFFF3B30),
        onSurface: Color(0xFFF8FAFC),
      ),
      extensions: const [
        VietnamStockColors.dark,
      ],
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundOled,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1),
          height: 1.45,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8),
        ),
      ),
      // Cấu hình Modal Bottom Sheet bo góc mềm mại
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF151D2A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121824),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

