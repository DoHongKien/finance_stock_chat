import 'package:flutter/material.dart';

/// Extension bộ màu Ngũ sắc đặc thù của Thị trường Chứng khoán Việt Nam
@immutable
class VietnamStockColors extends ThemeExtension<VietnamStockColors> {
  final Color ceiling;    // Tím trần (+7% HOSE / +10% HNX / +15% UPCOM)
  final Color up;         // Xanh lá tăng giá
  final Color reference;  // Vàng tham chiếu
  final Color down;       // Đỏ giảm giá
  final Color floor;      // Xanh lơ sàn (-7% HOSE / -10% HNX / -15% UPCOM)
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

  static Color getPriceColor({
    required double current,
    required double ref,
    required double ceiling,
    required double floor,
    VietnamStockColors colors = dark,
  }) {
    if (current >= ceiling && ceiling > 0) return colors.ceiling;
    if (current <= floor && floor > 0) return colors.floor;
    if (current > ref) return colors.up;
    if (current < ref) return colors.down;
    return colors.reference;
  }

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

