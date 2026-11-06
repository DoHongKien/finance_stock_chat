import 'package:flutter/services.dart';

/// Tiện ích điều khiển rung xúc giác Haptic Feedback chuẩn hóa trên iOS & Android
class AppHaptics {
  AppHaptics._();

  /// Chạm nhẹ khi bấm nút thông thường hoặc chọn tab
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Phản hồi khi gửi tin nhắn hoặc kích hoạt hành động thành công
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Bắt đầu bấm giữ Micro thu âm
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Cảnh báo mạnh: Cổ phiếu chạm giá Trần (Tím) hoặc Sàn (Xanh lơ)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Rung cảnh báo lỗi
  static Future<void> error() async {
    await HapticFeedback.vibrate();
  }
}

