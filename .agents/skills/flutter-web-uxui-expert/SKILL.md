---
name: flutter-web-uxui-expert
description: >-
  Chuyên gia hàng đầu về thiết kế UX/UI Fintech và kỹ thuật lập trình Flutter Web chuyên nghiệp.
  Kích hoạt skill này khi người dùng yêu cầu thiết kế giao diện (UI), tối ưu trải nghiệm người dùng (UX),
  xây dựng kiến trúc frontend Flutter Web, tạo biểu đồ/thẻ cổ phiếu (Stock Card/Sparkline),
  thiết kế responsive dashboard đa màn hình, hoặc chuẩn hóa design system cho ứng dụng tài chính/chứng khoán Việt Nam.
---

# Chuyên Gia UX/UI & Flutter Web - Nền Tảng Tài Chính & Chứng Khoán (Finance Stock Chat)

Skill này biến Antigravity thành một **Senior UI/UX Designer & Lead Flutter Web Architect** đẳng cấp quốc tế, chuyên biệt cho lĩnh vực **Fintech, Chứng khoán Việt Nam (VN-Index/HOSE/HNX/UPCOM)** và **AI Conversational Interface**.

---

## 1. TRIẾT LÝ THIẾT KẾ UX/UI FINTECH & STOCK (CORE DESIGN PHILOSOPHY)

Giao diện tài chính đòi hỏi tính **chuẩn xác tuyệt đối**, **mật độ thông tin cao (High Information Density)** nhưng **không gây ngợp thị giác (Zero Cognitive Overload)**.

### 1.1. Quy tắc Ngũ sắc Chứng khoán Việt Nam (The 5-Color Rule)
Không áp dụng màu sắc tùy tiện trong bảng giá và dữ liệu chứng khoán VN:
* 🟣 **Ceiling (Tím trần):** `#BD00FF` hoặc `#B946E6` – Biên độ cao nhất trong phiên (+7% HOSE, +10% HNX, +15% UPCOM).
* 🟢 **Up (Xanh lá tăng giá):** `#00C087` hoặc `#00E676` – Tăng so với giá tham chiếu.
* 🟡 **Reference (Vàng tham chiếu):** `#FFB800` hoặc `#FFD600` – Giá đóng cửa phiên trước đó.
* 🔴 **Down (Đỏ giảm giá):** `#FF3B30` hoặc `#F43F5E` – Giảm so với giá tham chiếu.
* 🔵 **Floor (Xanh lơ/Lam sàn):** `#00E5FF` hoặc `#00B0FF` – Biên độ thấp nhất trong phiên.

> **UX Rule:** Luôn hiển thị dấu `+` cho phần trăm tăng (`+2.45%`) và `-` cho phần trăm giảm (`-1.20%`). Luôn sử dụng icon hướng mũi tên `▲` và `▼` đi kèm để hỗ trợ người dùng mù màu (Accessibility).

### 1.2. Mật độ Thông tin & Typography Số liệu (Tabular Figures)
* **Tabular Numerals (Số có chiều rộng cố định):** Khi giá trị số nhảy liên tục theo phiên khớp lệnh real-time, font số **bắt buộc** phải sử dụng tính năng tabular:
  ```dart
  TextStyle(
    fontFamily: 'JetBrainsMono', // hoặc RobotoMono, Inter
    fontFeatures: const [FontFeature.tabularFigures()],
  )
  ```
* **Mặt chữ tài chính:** Dùng `Be Vietnam Pro` hoặc `Inter` cho văn bản thông thường (tiếng Việt không lỗi dấu), dùng monospace/tabular font cho toàn bộ số liệu giá, P/E, EPS, khối lượng.
* **Nguyên tắc "Scan-and-Act":** Nhà đầu tư lướt qua bảng trong 1.5 giây để ra quyết định: Mã cổ phiếu (Ticker) $\rightarrow$ Giá hiện tại + Màu sắc $\rightarrow$ % Biến động $\rightarrow$ Biểu đồ xu hướng mini (Sparkline).

### 1.3. Dark Mode First & High Contrast Theme
* Giao diện theo dõi bảng điện và chat tài chính chủ yếu được dùng trong điều kiện làm việc liên tục:
  * **Background:** Deep Navy/Black `#0A0D14` hoặc `#0F172A` (tránh đen tuyền `#000000` để không gây gắt mắt).
  * **Surface / Card Background:** `#151D2A` với viền siêu mảnh (border `1px solid rgba(255, 255, 255, 0.08)`).
  * **Glassmorphism tinh tế:** `BackdropFilter` mờ nhẹ trên các thanh điều hướng (blur 12px, opacity 0.7).

---

## 2. KIẾN TRÚC FLUTTER WEB CHUYÊN NGHIỆP (ENTERPRISE FLUTTER WEB)

Flutter Web không đơn thuần là compile từ Mobile. Một ứng dụng Web chuyên nghiệp cần đáp ứng chuẩn desktop browser:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            FLUTTER WEB WORKSPACE                            │
├─────────────────┬──────────────────────────────────┬────────────────────────┤
│  NAVBAR /       │     AI CONVERSATION FEED         │  MARKET SIDE PANEL     │
│  WATCHLIST PANE │  - Streaming Assistant Markdown  │  - Mini Bảng Giá HOSE  │
│  - Quick Search │  - Embedded Stock Cards (Rich)   │  - Sparkline Biểu đồ   │
│  - Saved Tickers│  - Follow-up Query Chips         │  - Sổ lệnh / Dòng tiền │
│  - Phiên Chat cũ│  - Voice Input Web Waves         │  - Chỉ số VN-Index     │
│  (Width: 280px) │  (Flexible: flex 5)              │  (Width: 340px)        │
└─────────────────┴──────────────────────────────────┴────────────────────────┘
```

### 2.1. Responsive Layout Matrix
Ứng dụng phải tự động thích ứng mượt mà qua các Breakpoints:
* **Desktop ($\ge 1200\text{px}$):** 3 Cột (Watchlist/Sidebar bên trái, Khung Chat chính giữa, Panel Biểu đồ & Ticker bên phải).
* **Laptop / Tablet Landscape ($840\text{px} - 1199\text{px}$):** 2 Cột (Collapsible Sidebar + Chat tích hợp thẻ tài chính).
* **Mobile & Tablet Portrait ($< 840\text{px}$):** 1 Cột với Bottom Navigation Bar, Drawer cho menu phiên chat, Stock Card hiển thị dạng BottomSheet hoặc Inline.

Sử dụng bộ template chuẩn tại [responsive_scaffold.dart](./examples/responsive_scaffold.dart).

### 2.2. Web Ergonomics & Input
* **Bàn phím Desktop:**
  * Nhấn `Enter` để gửi tin nhắn.
  * Nhấn `Shift + Enter` để xuống dòng mới.
  * Nhấn `Ctrl + K` hoặc `Cmd + K` để mở thanh tìm kiếm nhanh mã cổ phiếu (Command Palette).
  * Nhấn `Esc` để đóng Modal / BottomSheet.
* **Cursor & Hover Effect:**
  * Toàn bộ Button, Chip, Card, Ticker Item phải có `SystemMouseCursors.click`.
  * Hiệu ứng hover mềm mại (chuyển đổi màu nền 150ms qua `AnimatedContainer` hoặc `InkWell`).
* **Web Routing (`go_router`):**
  * Hỗ trợ URL trực tiếp: `/chat`, `/chat/:conversationId`, `/stock/:symbol` (ví dụ: `https://stockai.vn/stock/FPT`).
  * Tương thích hoàn toàn với nút Back/Forward của trình duyệt và chia sẻ link trực tiếp.

### 2.3. Tối ưu Hiệu năng Web (Performance & Wasm)
* Sử dụng **Flutter Wasm (WebAssembly)** hoặc **CanvasKit** renderer để vẽ biểu đồ và chuyển động mượt mà 60fps/120fps.
* Bật deferred loading cho các module nặng (như thư viện biểu đồ kỹ thuật chuyên sâu).
* Đặt `const` triệt để cho các Widget tĩnh để ngăn ngừa re-render toàn bộ cây giao diện khi nhận stream WebSocket / SSE tin nhắn AI.
* Tách biệt Render Rebuild bằng `RepaintBoundary` tại các khu vực nhấp nháy giá real-time.

---

## 3. THIẾT KẾ GIAO DIỆN CHAT AI & THẺ TÀI CHÍNH TƯƠNG TÁC (RICH UI)

Trải nghiệm hội thoại AI trong tài chính không chỉ là văn bản thô (Plain Text) mà là **Generative UI**:

### 3.1. Cấu trúc Tin nhắn AI Trợ lý
1. **Phần Phân tích Ngắn gọn (Markdown Stream):** Tóm tắt xu hướng, luận điểm đầu tư theo định dạng có gạch đầu dòng, highlight chỉ số quan trọng.
2. **Thẻ Cổ phiếu Trực quan (Stock Summary Card):**
   * Ticker + Tên công ty đầy đủ + Sàn (HOSE/HNX).
   * Giá hiện tại, Khối lượng giao dịch trong phiên, Biên độ tăng giảm (Badge màu tương ứng).
   * Mini Sparkline Chart (biểu đồ đường 7 ngày hoặc trong phiên).
   * 4 chỉ số cơ bản nhanh: P/E, P/B, ROE, Vốn hóa thị trường.
   * Nút tác vụ nhanh: `[+ Theo dõi]`, `[Xem BCTC đầy đủ]`, `[So sánh ngành]`.
3. **Smart Follow-up Chips (Gợi ý hành động tiếp theo):**
   * AI tự sinh ra 3 câu hỏi liên quan để người dùng bấm ngay mà không cần gõ (ví dụ: *"Khối ngoại đang mua hay bán ròng FPT?", "So sánh P/E của FPT với CMG và FOX"*).

---

## 4. TÀI LIỆU HƯỚNG DẪN CHI TIẾT & MẪU CODE SẴN SÀNG

Để triển khai nhanh chóng và chuẩn xác, tham khảo các tài liệu chuyên sâu đính kèm:

* 📐 **[Tài liệu Design System Tài chính](./references/design_system_finance.md):** Bảng mã màu hex chuẩn, quy chuẩn khoảng cách 8pt grid, typography, hiệu ứng viền bóng.
* ⚡ **[Kiến trúc Flutter Web & Best Practices](./references/flutter_web_architecture.md):** Thiết lập `go_router`, State Management Riverpod, tối ưu build Wasm/PWA, xử lý bàn phím và chuột.
* 🇻🇳 **[Quy chuẩn Chứng khoán Việt Nam & SSI MCP UX](./references/vietnam_stock_ux_specs.md):** Các phiên khớp lệnh (ATO, ATC), cách hiển thị dữ liệu trả về từ SSI MCP Server.
* 🧩 **Code Mẫu Hoàn Chỉnh:**
  * [Theme Tài chính Đẳng cấp (`finance_theme.dart`)](./examples/finance_theme.dart)
  * [Thẻ Cổ phiếu Tương tác (`stock_card_widget.dart`)](./examples/stock_card_widget.dart)
  * [Bố cục Dashboard 3 Cột Responsive (`responsive_scaffold.dart`)](./examples/responsive_scaffold.dart)
  * [Bong bóng Chat AI Kèm Thẻ Trực quan (`chat_bubble_with_rich_card.dart`)](./examples/chat_bubble_with_rich_card.dart)

---

## 5. CHECKLIST ĐÁNH GIÁ CHẤT LƯỢNG UI/UX FLUTTER WEB

Khi review hoặc viết code UI/UX trong dự án `finance_stock_chat`, hãy đảm bảo đạt 100% các tiêu chí sau:

- [ ] **Màu sắc chuẩn sàn VN:** Đã đúng 5 màu (Tím trần, Xanh lá tăng, Vàng tham chiếu, Đỏ giảm, Xanh lơ sàn) chưa?
- [ ] **Tabular Numerals:** Các con số biến động đã dùng font cố định chiều rộng chưa?
- [ ] **Responsive Breakpoints:** Mở trên màn hình Desktop rộng (>1400px), Laptop (1024px) và Điện thoại di động có bị tràn màn hình (Overflow error) không?
- [ ] **Desktop Web Interactions:** Đã có hiệu ứng hover chuột (`MouseRegion`), con trỏ tay (`click`), phím tắt `Enter` gửi tin và `Shift+Enter` xuống dòng chưa?
- [ ] **Hiệu ứng Nhịp đập Giá (Price Flash):** Khi giá thay đổi, ô giá có nhấp nháy nền xanh/đỏ nhẹ trong 400ms rồi trở lại bình thường không?
- [ ] **Tải trang & Shimmer:** Đã có hiệu ứng Shimmer Skeleton cho các thẻ cổ phiếu trong khi chờ AI gọi Tool SSI MCP chưa?
- [ ] **Streaming Animation:** Tin nhắn phản hồi từ Gemini có hiệu ứng gõ chữ mượt mà, không giật lag danh sách cuộn (`ListView`) không?

