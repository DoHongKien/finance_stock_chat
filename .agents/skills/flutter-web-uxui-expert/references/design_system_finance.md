# Design System Tài Chính & Chứng Khoán (Fintech Stock Design System)

Tài liệu này định nghĩa hệ thống thiết kế (Design Tokens & Component Specs) cho ứng dụng Web / Mobile Tài chính Chứng khoán Việt Nam, đảm bảo tính nhất quán, chuyên nghiệp và tối ưu trải nghiệm theo dõi thị trường tài chính cường độ cao.

---

## 1. HỆ THỐNG MÀU SẮC (COLOR TOKENS)

### 1.1. Bảng Màu Ngũ Sắc Thị Trường Chứng Khoán Việt Nam
Các màu sắc mang ý nghĩa sống còn trong giao dịch chứng khoán tại HOSE, HNX và UPCOM:

| Token Name | Hex Code | Ý Nghĩa / Trạng Thái | Khi Nào Sử Dụng |
| :--- | :--- | :--- | :--- |
| `stockCeiling` | `#BD00FF` | **Tím trần (Ceiling)** | Giá đạt biên độ tối đa phiên (+7% HOSE, +10% HNX, +15% UPCOM) |
| `stockUp` | `#00C087` | **Xanh lá tăng (Up)** | Giá cao hơn giá tham chiếu phiên trước |
| `stockReference` | `#FFB800` | **Vàng tham chiếu (Ref)**| Bằng giá đóng cửa phiên trước, không đổi |
| `stockDown` | `#FF3B30` | **Đỏ giảm (Down)** | Giá thấp hơn giá tham chiếu phiên trước |
| `stockFloor` | `#00E5FF` | **Xanh lơ sàn (Floor)** | Giá chạm biên độ sàn tối thiểu phiên |

### 1.2. Màu Nền & Bề Mặt (Background & Surface - Dark Mode First)

```css
/* Dark Mode Theme Tokens */
--bg-primary: #0B0E14;       /* Nền ứng dụng chính: Xanh đen sâu, chống mỏi mắt */
--bg-secondary: #121824;     /* Nền sidebar, container phụ */
--surface-card: #172030;     /* Thẻ chứng khoán, bong bóng chat, bảng dữ liệu */
--surface-hover: #1E2B40;    /* Hiệu ứng khi rê chuột vào hàng/thẻ */
--border-subtle: #222E42;    /* Đường viền mỏng phân chia phân đoạn (1px) */
--border-focus: #3B82F6;     /* Viền khi focus vào ô tìm kiếm hoặc nhập prompt */
```

### 1.3. Màu Chữ (Text Hierarchy)
* `text-primary`: `#F8FAFC` (Độ tương phản cao nhất, dùng cho Ticker, Giá chính, Tiêu đề).
* `text-secondary`: `#94A3B8` (Tên công ty, nhãn phụ, thời gian giao dịch).
* `text-tertiary`: `#64748B` (Ghi chú chân trang, watermark nguồn dữ liệu).
* `text-accent`: `#38BDF8` (Link tham chiếu nguồn SSI, thẻ tag phân tích).

---

## 2. QUY CHUẨN TYPOGRAPHY & TABULAR NUMERALS

### 2.1. Font Families
* **Font Chính (UI & Văn bản Tiếng Việt):** `Be Vietnam Pro` hoặc `Inter`. Đảm bảo hiển thị hoàn hảo dấu tiếng Việt, không bị lỗi font fallback trên các trình duyệt Chrome, Safari, Edge, Firefox.
* **Font Số Liệu Tài Chính (Prices, Rates, Quantities):** `JetBrains Mono` hoặc `Roboto Mono`.

### 2.2. Kỹ Thuật Bắt Buộc: `tabularFigures`
Trong Flutter, khi giá cổ phiếu cập nhật real-time liên tục, chữ số thông thường (proportional) có chiều rộng khác nhau (ví dụ: số `1` hẹp hơn số `8`), khiến giao diện bị "giật ngang" (horizontal jitter).
**Giải pháp bắt buộc:**
```dart
const TextStyle stockPriceStyle = TextStyle(
  fontFamily: 'JetBrainsMono',
  fontFeatures: [FontFeature.tabularFigures()],
  fontWeight: FontWeight.w700,
  fontSize: 22.0,
  letterSpacing: -0.5,
);
```

### 2.3. Cỡ Chữ & Trọng Số (Type Scale)
* **Display H1 (Giá lớn/VN-Index):** `28px` / Bold (700)
* **Heading H2 (Ticker / Card Title):** `18px` / SemiBold (600)
* **Body Normal (Chat Text, Phân tích AI):** `14px` / Regular (400) / Line-height `1.6`
* **Caption / Label (P/E, ROE, Khối lượng):** `12px` / Medium (500)
* **Badge / Tag (% Tăng giảm):** `12px` / Bold (700) kèm padding `4px 8px`, borderRadius `6px`

---

## 3. LƯỚI BỐ CỤC & KHOẢNG CÁCH (8PT SPACING SYSTEM)

Toàn bộ lề (`margin`), khoảng đệm (`padding`) và khoảng cách (`gap`) tuân theo bội số của 8:
* `4px` (xxs): Khoảng cách giữa icon nhỏ và label.
* `8px` (xs): Khoảng cách giữa các chip, badge.
* `16px` (sm): Padding bên trong card, chat bubble, input padding.
* `24px` (md): Khoảng cách giữa các khối nội dung lớn.
* `32px` (lg): Gutter giữa các cột trên giao diện Web Desktop.

---

## 4. QUY CHUẨN CÁC THÀNH PHẦN GIAO DIỆN CỐT LÕI (COMPONENT SPECS)

### 4.1. Thẻ Cổ Phiếu Rút Gọn (Stock Summary Card)
* **Bố cục:**
  * Hàng trên: Mã ticker lớn (FPT), Tên đầy đủ (Công ty CP FPT), Sàn giao dịch (HOSE tag).
  * Hàng giữa: Giá hiện tại (VD: `135.500`), Chênh lệch giá & % (Badge màu chuẩn: `+3.200 (+2.42%)`), Sparkline chart 7 ngày bên phải.
  * Hàng dưới: Lưới 4 chỉ số tài chính (P/E, P/B, ROE, Vốn hóa) theo dạng cột nhỏ `Label` trên, `Value` dưới.
* **Hiệu ứng Micro-interaction (Price Flashing):**
  * Khi giá khớp thay đổi theo dữ liệu mới, nền của ô giá sẽ nhấp nháy màu xanh lá (nếu tăng) hoặc đỏ (nếu giảm) với độ trong suốt `0.2`, mờ dần về trong suốt trong 400ms (`AnimatedContainer` hoặc `TweenAnimationBuilder`).

### 4.2. Bong Bóng Chat AI (AI Conversational Bubble)
* **Phía Assistant:**
  * Avatar Gemini/FinChat kèm glow nhẹ màu xanh neon.
  * Nền: `#172030` với viền `#222E42`.
  * Hỗ trợ gõ chữ thời gian thực (Streaming Text) với con trỏ nhấp nháy `▌`.
  * Trích dẫn nguồn dữ liệu chuẩn SSI: Tag nhỏ `Nguồn: SSI MCP lúc 14:15` có icon verified.
* **Phía User:**
  * Nền: Gradient thanh lịch `#1E3A8A` $\rightarrow$ `#2563EB` (Blue).
  * Căn phải, bo góc nhẹ (Top-Left: 16, Top-Right: 4, Bottom-Left: 16, Bottom-Right: 16).

### 4.3. Thanh Gợi Ý Hành Động Nhanh (Smart Suggestion Chips)
* Các chip nằm ngang ngay dưới câu trả lời của AI:
  * Ví dụ: `[🔍 So sánh P/E ngành]`, `[📊 Xem dòng tiền ngoại]`, `[📈 Đồ thị kỹ thuật]`.
  * Style: Nền trong suốt với viền `1px solid rgba(255,255,255,0.15)`, text màu sáng, khi hover đổi nền thành `rgba(59, 130, 246, 0.15)` và viền xanh dương.

