# Kiến Trúc Flutter Mobile App Chuẩn Enterprise (iOS & Android)

Tài liệu này định hình kiến trúc phần mềm, quản lý trạng thái, tích hợp tính năng Native (Micro, Rung Haptic, Local Storage) và quy trình build tự động cho ứng dụng di động **StockAI / FinChat VN**.

---

## 1. CẤU TRÚC DỰ ÁN FEATURE-FIRST CHO MOBILE

```
mobile/lib/
├── app.dart                        # MaterialApp cấu hình Dark Theme & Navigation
├── main.dart                       # ProviderScope, khởi tạo Hive local database
│
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart      # Đường dẫn kết nối Cloudflare Worker
│   │   └── stock_colors.dart       # Mã màu ngũ sắc HOSE/HNX/UPCOM
│   ├── network/
│   │   ├── api_client.dart         # Dio HTTP Client kèm Retry & Timeout
│   │   └── sse_stream_client.dart  # Nhận stream token chữ từ Worker
│   ├── theme/
│   │   ├── mobile_theme.dart       # Dark Mode tối ưu tiết kiệm pin màn hình OLED
│   │   └── stock_typography.dart   # Font Be Vietnam Pro + Monospace số Tabular
│   └── utils/
│       ├── haptic_helper.dart      # Rung phản hồi (HapticFeedback) chuẩn iOS & Android
│       ├── speech_service.dart     # Service On-Device STT (speech_to_text)
│       └── formatters.dart         # Format số tiền VNĐ, K, M, Tỷ
│
├── features/
│   ├── chat/                       # Tính năng Trợ lý AI Hỏi đáp
│   │   ├── data/
│   │   │   ├── chat_repository.dart
│   │   │   └── local/chat_local_dao.dart (Lưu lịch sử offline qua Hive)
│   │   ├── presentation/
│   │   │   ├── controllers/chat_controller.dart (Riverpod AsyncNotifier)
│   │   │   ├── screens/chat_screen.dart
│   │   │   └── widgets/
│   │   │       ├── voice_record_button.dart   # Nút bấm giữ mic kèm sóng âm
│   │   │       ├── assistant_bubble.dart      # Bong bóng phản hồi Markdown
│   │   │       └── followup_chips_row.dart    # Gợi ý câu hỏi tiếp theo
│   │
│   ├── stocks/                     # Tính năng Thẻ cổ phiếu & Bảng giá
│   │   ├── data/stock_repository.dart
│   │   ├── presentation/
│   │   │   ├── widgets/
│   │   │   │   ├── stock_summary_card.dart
│   │   │   │   ├── sparkline_chart.dart
│   │   │   │   ├── financial_health_gauge.dart
│   │   │   │   └── cash_flow_wave_card.dart
│   │   │   └── modals/stock_detail_bottom_sheet.dart # Chi tiết mã dạng vuốt
│   │
│   └── watchlist/                  # Danh mục theo dõi cá nhân
│       ├── data/watchlist_repository.dart
│       └── presentation/
│           ├── controllers/watchlist_controller.dart
│           └── screens/watchlist_screen.dart
│
└── layout/
    └── app_main_scaffold.dart      # Bottom Navigation Bar + Center Mic Button
```

---

## 2. QUẢN LÝ TƯƠNG TÁC GIỌNG NÓI & QUYỀN NATIVE (VOICE RECORDING & STT)

### 2.1. Cài Đặt Quyền Trong Hệ Thống
* **iOS (`ios/Runner/Info.plist`):**
  ```xml
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>StockAI cần quyền nhận diện giọng nói để bạn hỏi đáp chứng khoán bằng tiếng Việt.</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>StockAI cần quyền sử dụng micro để thu âm câu hỏi của bạn.</string>
  ```
* **Android (`android/app/src/main/AndroidManifest.xml`):**
  ```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.VIBRATE" />
  <uses-permission android:name="android.permission.INTERNET" />
  ```

### 2.2. Service Nhận Diện Giọng Nói Tiếng Việt (`speech_to_text`)
```dart
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  Future<bool> init() async {
    _isAvailable = await _speech.initialize(
      onError: (val) => print('Lỗi STT: $val'),
      onStatus: (val) => print('Trạng thái STT: $val'),
    );
    return _isAvailable;
  }

  Future<void> startListening({
    required Function(String recognizedWords) onResult,
  }) async {
    if (!_isAvailable) return;

    // Rung xúc giác khi bắt đầu nghe
    await HapticFeedback.mediumImpact();

    await _speech.listen(
      localeId: 'vi_VN', // Nhận diện tiếng Việt chuẩn xác
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await HapticFeedback.lightImpact();
    await _speech.stop();
  }
}
```

---

## 3. QUẢN LÝ TRẠNG THÁI STREAMING VỚI RIVERPOD (ASYNC NOTIFIER)

```dart
// lib/features/chat/presentation/controllers/chat_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class ChatState {
  final List<dynamic> messages;
  final bool isRecording;
  final bool isStreaming;

  const ChatState({
    this.messages = const [],
    this.isRecording = false,
    this.isStreaming = false,
  });

  ChatState copyWith({
    List<dynamic>? messages,
    bool? isRecording,
    bool? isStreaming,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isRecording: isRecording ?? this.isRecording,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

class ChatNotifier extends AutoDisposeAsyncNotifier<ChatState> {
  @override
  Future<ChatState> build() async {
    // Đọc lịch sử chat lưu offline trong Hive để mở app là có ngay
    return const ChatState();
  }

  void onStartVoice() {
    HapticFeedback.mediumImpact();
    state = AsyncData(state.value!.copyWith(isRecording: true));
  }

  void onStopVoice(String recognizedText) {
    HapticFeedback.lightImpact();
    state = AsyncData(state.value!.copyWith(isRecording: false));
    if (recognizedText.trim().isNotEmpty) {
      sendPrompt(recognizedText);
    }
  }

  Future<void> sendPrompt(String text) async {
    // Gửi đến Cloudflare Worker & nhận stream dữ liệu
  }
}
```

---

## 4. QUY TRÌNH BUILD APP MOBILE MIỄN PHÍ (0 VNĐ)

### 4.1. Build Android APK
Chạy trên terminal máy tính:
```bash
flutter build apk --release --split-per-abi
```
File `.apk` sinh ra tại `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Chuyển trực tiếp qua điện thoại Android cài đặt vĩnh viễn.

### 4.2. Build iOS IPA Qua GitHub Actions (Không Cần Máy Mac)
Tạo file `.github/workflows/build_ios.yml`:
```yaml
name: Build iOS IPA
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.x'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      - name: Create Payload and Zip to IPA
        run: |
          mkdir -p Payload
          cp -r build/ios/iphoneos/Runner.app Payload/
          zip -r StockAI_VN.ipa Payload
      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: StockAI-iOS-IPA
          path: StockAI_VN.ipa
```
Nhà phát triển tải file `.ipa` từ tab **Actions** về máy tính và dùng công cụ **Sideloadly** để nạp trực tiếp vào iPhone.

