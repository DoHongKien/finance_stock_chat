---
name: flutter-mobile-uxui-expert
description: >-
  Chuyên gia hàng đầu về thiết kế UX/UI Fintech di động và kỹ thuật lập trình Flutter Mobile (iOS & Android) chuyên nghiệp.
  Kích hoạt skill này khi người dùng yêu cầu thiết kế giao diện Mobile App, tối ưu trải nghiệm người dùng (UX) trên điện thoại
  (Thumb Zone, Haptic Feedback, Voice Mic ghi âm tiếng Việt), xây dựng kiến trúc Flutter Mobile, tạo biểu đồ/thẻ cổ phiếu
  (Stock Card/Sparkline), hoặc chuẩn hóa design system cho ứng dụng tài chính/chứng khoán Việt Nam.
---

# Chuyên Gia UX/UI & Kỹ Thuật Lập Trình Flutter Mobile App (iOS & Android)

Skill này chuyển hóa Antigravity thành **Senior Mobile Product Designer & Lead Flutter Mobile Engineer**, chuyên sâu cho ứng dụng di động tài chính, trợ lý AI chứng khoán Việt Nam (Fintech / Stock / Conversational AI) trên hai nền tảng **iOS** và **Android**.

---

## 1. TRIẾT LÝ THIẾT KẾ UX/UI FINTECH CHO THIẾT BỊ DI ĐỘNG (MOBILE-FIRST)

Người dùng theo dõi bảng điện và tra cứu chứng khoán trên điện thoại di động thường thao tác trong trạng thái di chuyển, dùng một tay (One-handed operation) và cần tốc độ nắm bắt thông tin cực nhanh.

### 1.1. Vùng Thao Tác Ngón Cái (Thumb Zone Ergonomics)
* Toàn bộ các tương tác thường xuyên nhất phải nằm ở **nửa dưới màn hình** (Bottom 40%):
  * **Thanh điều hướng chính (Bottom Navigation Bar):** Chat AI, Watchlist, Bảng Giá, Tài khoản.
  * **Nút Micro Voice Search trung tâm:** Nổi bật ở chính giữa thanh Bottom Bar, dễ dàng bấm giữ bằng ngón tay cái để hỏi nhanh bằng tiếng Việt.
  * **Thanh nhập liệu Chat (Input Field):** Nằm sát đáy, tự động nâng lên theo bàn phím (`resizeToAvoidBottomInset: true`) kèm `SafeArea`.
  * **Thẻ chi tiết cổ phiếu:** Mở dạng **Modal BottomSheet** có thể vuốt xuống để đóng (Drag-to-dismiss), không bắt người dùng với tay lên góc trên cùng màn hình.

### 1.2. Phản Hồi Rung Xúc Giác Tinh Tế (Haptic Feedback)
Tạo cảm giác chân thực và chắc chắn khi thực hiện các tác vụ tài chính:
* **Khi bấm giữ Micro nói:** Rung nhẹ 1 nhịp (`HapticFeedback.mediumImpact()`) báo hiệu bắt đầu thu âm.
* **Khi thả tay gửi câu hỏi:** Rung nhẹ 1 nhịp (`HapticFeedback.lightImpact()`) xác nhận tin nhắn đã gửi.
* **Khi giá cổ phiếu chạm Trần (Tím) hoặc Sàn (Xanh lơ):** Rung nhịp kép (`HapticFeedback.heavyImpact()`).
* **Khi kéo làm mới (Pull-to-Refresh):** Rung tick nhẹ (`HapticFeedback.selectionClick()`).

### 1.3. Quy Tắc Ngũ Sắc Bảng Điện Việt Nam (The 5-Color Law)
Không dùng màu sắc tùy tiện, phải chuẩn sàn HOSE, HNX và UPCOM:
* 🟣 **Tím trần (Ceiling):** `#BD00FF` (+7% HOSE / +10% HNX / +15% UPCOM).
* 🟢 **Xanh lá tăng (Up):** `#00C087` (Tăng so với tham chiếu).
* 🟡 **Vàng tham chiếu (Reference):** `#FFB800` (Bằng giá đóng phiên trước).
* 🔴 **Đỏ giảm (Down):** `#FF3B30` (Giảm so với tham chiếu).
* 🔵 **Xanh lơ sàn (Floor):** `#00E5FF` (-7% HOSE / -10% HNX / -15% UPCOM).

### 1.4. Typography Số Liệu Di Động: Tabular Figures Bắt Buộc
Ép số liệu giá và % biến động dùng font Monospace cố định chiều rộng chữ số để bảng điện không bị rung giật khi dữ liệu real-time cập nhật:
```dart
TextStyle(
  fontFamily: 'JetBrainsMono',
  fontFeatures: const [FontFeature.tabularFigures()],
  fontWeight: FontWeight.w700,
)
```

---

## 2. TRẢI NGHIỆM TƯƠNG TÁC GIỌNG NÓI & CONVERSATIONAL AI UX

Theo kiến trúc dự án `finance_stock_chat`, người dùng tương tác chủ yếu bằng **giọng nói tiếng Việt qua Micro**:

```
[Bấm giữ nút Mic] ────> [Rung Haptic] ────> [Hiển thị sóng âm thanh Wave Animation]
         │
         ▼
[On-Device STT dịch tiếng Việt] ────> [Gửi Prompt đến Cloudflare Worker]
         │
         ▼
[Gemini + SSI MCP trích xuất dữ liệu] ────> [Stream trả lời + Render Stock Card]
```

* **Voice Record Button UX:**
  * Bấm giữ để nói $\rightarrow$ Icon đổi thành hiệu ứng vòng tròn sóng âm lan tỏa (Ripple Pulse).
  * Vuốt sang trái để hủy ghi âm (Swipe to cancel).
  * Thả tay để gửi tự động.
* **Generative UI (Thẻ Trực Quan Trong Luồng Chat):**
  * Không trả về text khô khan. Khi người dùng hỏi về bất kỳ mã nào (VD: `FPT`), hiển thị ngay thẻ tóm tắt giá, % tăng giảm, Sparkline chart mini và chỉ số P/E, ROE.
  * Tích hợp các **Chip câu hỏi tiếp theo** ngay dưới câu trả lời để người dùng chạm ngón tay hỏi tiếp trong 0.5s.

---

## 3. KIẾN TRÚC MÃ NGUỒN FLUTTER MOBILE (CLEAN ARCHITECTURE + RIVERPOD)

Phân tầng mã nguồn theo cấu trúc Feature-Driven cho ứng dụng di động:

```
mobile/lib/
├── app.dart                        # Cấu hình MaterialApp, Theme di động & Locale vi_VN
├── main.dart                       # Khởi tạo Riverpod ProviderScope, Hive/Storage
│
├── core/
│   ├── constants/stock_colors.dart # Bộ mã ngũ sắc HOSE/HNX/UPCOM
│   ├── network/api_client.dart     # Dio client kết nối Cloudflare Worker
│   ├── theme/mobile_theme.dart     # Dark Theme tối ưu OLED chống tốn pin
│   └── utils/
│       ├── haptic_helper.dart      # Tiện ích rung xúc giác iOS & Android
│       ├── formatters.dart         # Định dạng số tiền VNĐ, K, M, Tỷ
│       └── speech_helper.dart      # Quản lý quyền Micro & on-device Speech-to-Text
│
├── features/
│   ├── chat/                       # Tính năng Trợ lý AI Hỏi đáp
│   │   ├── controllers/chat_controller.dart (Riverpod AsyncNotifier)
│   │   └── widgets/
│   │       ├── voice_record_button.dart    # Nút mic rung haptic & sóng âm
│   │       ├── assistant_message_bubble.dart
│   │       └── smart_followup_chips.dart
│   │
│   ├── stocks/                     # Tính năng Bảng giá & Thẻ cổ phiếu
│   │   └── widgets/
│   │       ├── mobile_stock_card.dart      # Thẻ cổ phiếu vuốt chạm mượt mà
│   │       ├── sparkline_chart.dart        # Biểu đồ mini 60/120fps
│   │       ├── financial_health_gauge.dart # Vòng tròn chấm điểm sức khỏe cổ phiếu
│   │       └── cash_flow_wave_card.dart    # Sóng áp lực dòng tiền cá mập
│   │
│   └── watchlist/                  # Danh mục theo dõi cá nhân
│       └── screens/watchlist_screen.dart   # Vuốt để xóa (Dismissible), sắp xếp kéo thả
│
└── layout/
    └── app_main_scaffold.dart      # Bottom Navigation Bar + Center Mic Button
```

---

## 4. QUẢN LÝ QUYỀN NATIVE & CI/CD BUILD MOBILE MIỄN PHÍ

### 4.1. Cấp Quyền Micro
* **iOS (`ios/Runner/Info.plist`):**
  * `NSSpeechRecognitionUsageDescription`: *"StockAI cần quyền nhận diện giọng nói để bạn tra cứu chứng khoán bằng tiếng Việt."*
  * `NSMicrophoneUsageDescription`: *"StockAI cần sử dụng micro để ghi âm câu hỏi của bạn."*
* **Android (`android/app/src/main/AndroidManifest.xml`):**
  * `<uses-permission android:name="android.permission.RECORD_AUDIO" />`
  * `<uses-permission android:name="android.permission.INTERNET" />`
  * `<uses-permission android:name="android.permission.VIBRATE" />`

### 4.2. Chiến Lược Build App 0 VNĐ
* **Android:** Chạy lệnh `flutter build apk --release` để có file cài đặt `.apk` trực tiếp.
* **iOS (Không cần máy Mac):** Tận dụng **GitHub Actions** (`macos-latest`) build file `.ipa` miễn phí $\rightarrow$ Dùng **Sideloadly** hoặc AltStore nạp vào iPhone cá nhân.

---

## 5. TÀI LIỆU HƯỚNG DẪN CHI TIẾT & MÃ NGUỒN MẪU

* 📱 **[Kiến Trúc Flutter Mobile Chuẩn](./references/flutter_mobile_architecture.md):** Riverpod, quản lý Micro, On-device STT, Hive Local Cache, xử lý bàn phím trên điện thoại.
* 📐 **[Design System Mobile Fintech](./references/design_system_finance.md):** Bảng màu ngũ sắc, font số Tabular, thiết kế tối ưu màn hình OLED, Thumb Zone.
* 🇻🇳 **[Quy Chuẩn Chứng Khoán VN & SSI MCP](./references/vietnam_stock_ux_specs.md):** Phiên giao dịch ATO/ATC, biên độ 3 sàn, cách hiển thị dữ liệu real-time.
* 🌊 **[Hoạt Họa & Trực Quan Hóa Chỉ Số Di Động](./references/fluid_animations_and_visual_metrics.md):** Kỹ thuật chuyển động 60/120Hz mượt mà học hỏi từ Mitesh77, hiệu ứng sóng xung lực dòng tiền và vòng tròn đo điểm tài chính.
* 🧩 **Code Mẫu Hoàn Chỉnh:**
  * [Khung App Di Động Kèm Nút Voice Mic (`mobile_scaffold.dart`)](./examples/mobile_scaffold.dart)
  * [Theme Tối Ưu Cho Điện Thoại (`mobile_theme.dart`)](./examples/mobile_theme.dart)
  * [Nút Bấm Ghi Âm Giọng Nói Kèm Rung Haptic (`voice_record_button.dart`)](./examples/voice_record_button.dart)
  * [Thẻ Cổ Phiếu Di Động (`stock_card_widget.dart`)](./examples/stock_card_widget.dart)
  * [Bong Bóng Chat AI + Rich UI Card (`chat_bubble_with_rich_card.dart`)](./examples/chat_bubble_with_rich_card.dart)
  * [Đồng Hồ Điểm Sức Khỏe Doanh Nghiệp (`financial_health_gauge.dart`)](./examples/financial_health_gauge.dart)
  * [Thẻ Sóng Xung Lực Dòng Tiền (`cash_flow_wave_card.dart`)](./examples/cash_flow_wave_card.dart)
  * [Hiệu Ứng Xuất Hiện So Le (`staggered_fade_in_item.dart`)](./examples/staggered_fade_in_item.dart)

---

## 6. CHECKLIST KIỂM ĐỊNH CHẤT LƯỢNG MOBILE APP FINTECH

- [ ] **Thumb-Friendly:** Người dùng có thể hoàn thành việc hỏi trợ lý AI và xem mã chứng khoán bằng **một ngón tay cái** không?
- [ ] **Haptic Feedback:** Thao tác chạm nút Mic, xóa item watchlist, hoặc khi cổ phiếu chạm giá Trần/Sàn có rung nhẹ phản hồi không?
- [ ] **Xử lý Bàn phím Di động:** Khung nhập chat có tự động trượt lên trên bàn phím ảo mà không bị lỗi đè màn hình (`overflow pixels`) không?
- [ ] **Tabular Numerals:** Font chữ số giá và % có dùng font số cố định để chống rung lắc khi khớp lệnh không?
- [ ] **Hỗ trợ Safe Area:** Giao diện có tương thích với tai thỏ (Notch), Dynamic Island trên iPhone và đục lỗ camera trên Android không?
- [ ] **Quyền Micro rõ ràng:** Lời nhắc xin quyền micro và nhận diện giọng nói có giải thích lý do minh bạch, thân thiện bằng tiếng Việt không?

