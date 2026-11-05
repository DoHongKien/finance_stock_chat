import 'dart:ui';
import 'package:flutter/material.dart';

/// Extension bộ màu Ngũ sắc đặc thù của Thị trường Chứng khoán Việt Nam
@immutable
class VietnamStockColors extends ThemeExtension<VietnamStockColors> {
  final Color ceiling;    // Tím trần (+7% HOSE / +10% HNX)
  final Color up;         // Xanh lá tăng giá
  final Color reference;  // Vàng tham chiếu
  final Color down;       // Đỏ giảm giá
  final Color floor;      // Xanh lơ sàn (-7% HOSE / -10% HNX)
  final Color surfaceSubtle;
  final Color borderSubtle;

  const VietnamStockColors({
    required this.ceiling,
    required this.up,
    required this.reference,
    required this.down,
    required this.floor,
    required this.surfaceSubtle,
    required this.borderSubtle,
  });

  static const dark = VietnamStockColors(
    ceiling: Color(0xFFBD00FF),
    up: Color(0xFF00C087),
    reference: Color(0xFFFFB800),
    down: Color(0xFFFF3B30),
    floor: Color(0xFF00E5FF),
    surfaceSubtle: Color(0xFF151D2A),
    borderSubtle: Color(0xFF222E42),
  );

  @override
  VietnamStockColors copyWith({
    Color? ceiling,
    Color? up,
    Color? reference,
    Color? down,
    Color? floor,
    Color? surfaceSubtle,
    Color? borderSubtle,
  }) {
    return VietnamStockColors(
      ceiling: ceiling ?? this.ceiling,
      up: up ?? this.up,
      reference: reference ?? this.reference,
      down: down ?? this.down,
      floor: floor ?? this.floor,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      borderSubtle: borderSubtle ?? this.borderSubtle,
    );
  }

  @override
  VietnamStockColors lerp(ThemeExtension<VietnamStockColors>? other, double t) {
    if (other is! VietnamStockColors) return this;
    return VietnamStockColors(
      ceiling: Color.lerp(ceiling, other.ceiling, t)!,
      up: Color.lerp(up, other.up, t)!,
      reference: Color.lerp(reference, other.reference, t)!,
      down: Color.lerp(down, other.down, t)!,
      floor: Color.lerp(floor, other.floor, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
    );
  }
}

/// Theme Dark Mode Tiết Kiệm Pin Màn Hình OLED Cho Điện Thoại
class MobileFinanceTheme {
  MobileFinanceTheme._();

  static const Color backgroundOled = Color(0xFF0A0D14);
  static const Color surfaceCard = Color(0xFF151D2A);
  static const Color primaryBlue = Color(0xFF2563EB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundOled,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: Color(0xFF38BDF8),
        surface: surfaceCard,
        background: backgroundOled,
        onSurface: Color(0xFFF8FAFC),
      ),
      extensions: const [
        VietnamStockColors.dark,
      ],
      // Font chữ chính & Font số Tabular
      fontFamily: 'Be Vietnam Pro',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

