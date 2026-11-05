# Kiến Trúc Flutter Web & Kỹ Thuật Lập Trình Chuyên Nghiệp (Flutter Web Architecture)

Tài liệu này hướng dẫn chi tiết cách tổ chức mã nguồn, định tuyến Web (Routing), quản lý trạng thái (Riverpod), xử lý tương tác bàn phím/chuột và tối ưu hóa hiệu năng cho ứng dụng **Flutter Web** chuẩn Enterprise.

---

## 1. CẤU TRÚC THƯ MỤC CHUẨN FEATURE-FIRST

```
lib/
├── app.dart                        # MaterialApp.router, cấu hình Theme & Router
├── main.dart                       # Entry point, ProviderScope, khởi tạo services
│
├── core/                           # Các thành phần dùng chung toàn app
│   ├── constants/
│   │   ├── api_endpoints.dart      # URLs Cloudflare Worker & SSE endpoints
│   │   └── stock_colors.dart       # Bảng mã ngũ sắc HOSE/HNX/UPCOM
│   ├── network/
│   │   ├── api_client.dart         # Dio client kèm interceptors
│   │   └── sse_client.dart         # Xử lý Server-Sent Events stream từ Worker
│   ├── theme/
│   │   ├── app_colors.dart         # Color tokens cho Dark/Light mode
│   │   ├── app_typography.dart     # Font Be Vietnam Pro + Monospace Tabular
│   │   └── finance_theme.dart      # ThemeData hoàn chỉnh
│   └── utils/
│       ├── formatters.dart         # Định dạng tiền tệ VND, tỷ lệ %, khối lượng (K, M, B)
│       └── responsive_helper.dart  # Breakpoints: isMobile, isTablet, isDesktop
│
├── features/                       # Chia theo tính năng (Feature-Driven)
│   ├── chat/                       # Tính năng Trợ lý AI Chat
│   │   ├── data/
│   │   │   ├── chat_repository.dart
│   │   │   └── models/chat_message.dart
│   │   ├── presentation/
│   │   │   ├── controllers/chat_controller.dart (Riverpod AsyncNotifier)
│   │   │   ├── screens/chat_view.dart
│   │   │   └── widgets/
│   │   │       ├── chat_bubble.dart
│   │   │       ├── streaming_text_view.dart
│   │   │       ├── voice_input_web_bar.dart
│   │   │       └── suggestion_chips_row.dart
│   │
│   ├── stocks/                     # Tính năng Thẻ cổ phiếu & Bảng giá
│   │   ├── data/
│   │   │   ├── stock_repository.dart
│   │   │   └── models/stock_quote.dart
│   │   ├── presentation/
│   │   │   ├── controllers/stock_detail_controller.dart
│   │   │   └── widgets/
│   │   │       ├── stock_summary_card.dart
│   │   │       ├── sparkline_chart.dart
│   │   │       └── price_ticker_bar.dart
│   │
│   └── watchlist/                  # Tính năng Danh mục theo dõi
│       ├── data/watchlist_repository.dart
│       └── presentation/
│           ├── controllers/watchlist_controller.dart
│           └── widgets/watchlist_side_panel.dart
│
└── routing/
    └── app_router.dart             # Cấu hình GoRouter với ShellRoute responsive
```

---

## 2. WEB ROUTING VỚI `go_router` & ĐIỀU HƯỚNG DEEP LINKING

Trên nền tảng Web, URL đóng vai trò là trạng thái của ứng dụng. Người dùng cần có thể bookmark, gửi link cho đồng nghiệp, hoặc dùng nút Back/Forward của trình duyệt.

```dart
// lib/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/chat',
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        // Tự động bọc layout Responsive (3 cột trên Web, 1 cột trên Mobile)
        return MainResponsiveScaffold(body: child);
      },
      routes: [
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatView(),
          routes: [
            GoRoute(
              path: ':conversationId',
              name: 'chat-detail',
              builder: (context, state) {
                final id = state.pathParameters['conversationId'] ?? '';
                return ChatView(conversationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/stock/:symbol',
          name: 'stock-detail',
          builder: (context, state) {
            final symbol = state.pathParameters['symbol']?.toUpperCase() ?? 'VNINDEX';
            return StockDetailModalOrPane(symbol: symbol);
          },
        ),
      ],
    ),
  ],
);
```

---

## 3. TƯƠNG TÁC CHUỘT & BÀN PHÍM CHUẨN DESKTOP WEB

### 3.1. Xử lý Phím Tắt Gửi Tin Nhắn (Enter / Shift+Enter)
Trên Web, người dùng kỳ vọng bấm `Enter` để gửi tin nhắn và `Shift + Enter` để xuống dòng mới mà không gửi nhầm.

```dart
Focus(
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        // Cho phép xuống dòng bình thường
        return KeyEventResult.ignored;
      } else {
        // Gửi tin nhắn ngay lập tức
        _sendMessage();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  },
  child: TextField(
    controller: _textController,
    maxLines: 5,
    minLines: 1,
    decoration: const InputDecoration(
      hintText: 'Hỏi về mã cổ phiếu, P/E, thị trường hôm nay... (Enter để gửi)',
    ),
  ),
)
```

### 3.2. Hover States & Mouse Cursors
Mọi phần tử click được (Actionable elements) **phải** hiển thị con trỏ tay:

```dart
MouseRegion(
  cursor: SystemMouseCursors.click,
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    decoration: BoxDecoration(
      color: _isHovered ? AppColors.surfaceHover : AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: _isHovered ? AppColors.accentBlue : AppColors.borderSubtle,
      ),
    ),
    child: widget.child,
  ),
)
```

---

## 4. QUẢN LÝ TRẠNG THÁI HIỆN ĐẠI VỚI RIVERPOD (STREAMING & REAL-TIME)

Khi nhận phản hồi từ Gemini và SSI MCP qua Cloudflare Worker, phản hồi sẽ stream từng token về giao diện. Sử dụng `AsyncNotifier` để render tin nhắn gõ chữ mà không gây lag cả trang:

```dart
// lib/features/chat/presentation/controllers/chat_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? activeSymbolCard;

  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.activeSymbolCard,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? activeSymbolCard,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      activeSymbolCard: activeSymbolCard ?? this.activeSymbolCard,
    );
  }
}

class ChatNotifier extends AutoDisposeAsyncNotifier<ChatState> {
  @override
  Future<ChatState> build() async {
    // Tải lịch sử chat từ Cloudflare D1
    final initialMessages = await ref.read(chatRepositoryProvider).fetchHistory();
    return ChatState(messages: initialMessages);
  }

  Future<void> sendPrompt(String prompt) async {
    final userMsg = ChatMessage.user(content: prompt);
    state = AsyncData(state.value!.copyWith(
      messages: [...state.value!.messages, userMsg],
      isStreaming: true,
    ));

    // Nhận stream token từ Worker
    final stream = ref.read(chatRepositoryProvider).streamGeminiResponse(prompt);
    
    // Khởi tạo tin nhắn trống của Assistant
    final assistantMsgId = DateTime.now().toIso8601String();
    
    await for (final chunk in stream) {
      // Cập nhật nội dung token mới vào tin nhắn cuối cùng
      // Riverpod rebuild tối ưu chỉ tin nhắn đang streaming
      _appendAssistantChunk(assistantMsgId, chunk);
    }
  }

  void _appendAssistantChunk(String id, String chunk) {
    // Logic cập nhật text mượt mà
  }
}
```

---

## 5. TỐI ƯU HÓA HIỆU NĂNG WEB (WASM & WEB OPTIMIZATION)

1. **Biên Dịch Flutter Web Wasm (WebAssembly):**
   ```bash
   flutter build web --wasm --release
   ```
   * *Ưu điểm:* Tốc độ tải và thực thi CPU tăng 2-3x, biểu đồ nến và sparkline vẽ ở 60fps mượt mà như native app.
2. **Cấu Hình Font Loading trong `web/index.html`:**
   * Preload trước các font chính trong thẻ `<head>` để tránh hiệu ứng nhảy font (FOUT - Flash of Unstyled Text):
   ```html
   <link rel="preconnect" href="https://fonts.googleapis.com">
   <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
   <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">
   ```
3. **Sử Dụng `RepaintBoundary`:**
   * Đặt `RepaintBoundary` bao quanh các widget có hoạt ảnh nhấp nháy giá hoặc Sparkline chart để Flutter Web chỉ vẽ lại vùng đó, không re-render toàn bộ DOM/Canvas của cây cha.

