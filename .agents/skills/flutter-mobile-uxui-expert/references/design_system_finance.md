# Design System Mobile Fintech & Chứng Khoán Việt Nam

Tài liệu này định nghĩa hệ thống thiết kế (Design Tokens, Touch Targets & Mobile Ergonomics) cho ứng dụng di động **StockAI / FinChat VN** trên iOS và Android.

---

## 1. HỆ THỐNG MÀU SẮC (COLOR TOKENS)

### 1.1. Bảng Màu Ngũ Sắc Bảng Điện Việt Nam
Tuân thủ 100% quy ước 3 sàn giao dịch (HOSE, HNX, UPCOM):

| Token Name | Hex Code | Ý Nghĩa / Trạng Thái | Khi Nào Sử Dụng |
| :--- | :--- | :--- | :--- |
| `stockCeiling` | `#BD00FF` | **Tím trần (Ceiling)** | Giá đạt biên độ tối đa trong phiên (+7% HOSE, +10% HNX, +15% UPCOM) |
| `stockUp` | `#00C087` | **Xanh lá tăng (Up)** | Giá cao hơn giá tham chiếu phiên trước |
| `stockReference` | `#FFB800` | **Vàng tham chiếu (Ref)**| Bằng giá đóng cửa phiên trước, không đổi |
| `stockDown` | `#FF3B30` | **Đỏ giảm (Down)** | Giá thấp hơn giá tham chiếu phiên trước |
| `stockFloor` | `#00E5FF` | **Xanh lơ sàn (Floor)** | Giá chạm biên độ sàn tối thiểu trong phiên |

### 1.2. Màu Nền Tối Ưu Cho Màn Hình OLED (Battery-Saving Dark Theme)
* `bgPrimary`: `#0A0D14` (Đen xanh sâu thẳm, dịu mắt, tiết kiệm pin cho màn hình OLED/Super AMOLED).
* `surfaceCard`: `#151D2A` (Nền thẻ cổ phiếu, bong bóng chat, bảng dữ liệu).
* `surfaceElevated`: `#1C2638` (Modal BottomSheet khi vuốt mở chi tiết mã).
* `borderSubtle`: `#222E42` (Đường viền mỏng 1px phân tách các khối nội dung).
* `accentBlue`: `#2563EB` (Màu chính của nút bấm và trạng thái kích hoạt).
* `accentCyan`: `#38BDF8` (Màu nhấn cho icon AI và trích dẫn).

---

## 2. QUY CHUẨN KÍCH THƯỚC CHẠM & CÔNG THÁI HỌC DI ĐỘNG (MOBILE ERGONOMICS)

### 2.1. Kích Thước Chạm Tối Thiểu (Minimum Touch Targets)
* Toàn bộ các phần tử tương tác bằng ngón tay (Nút bấm, Chip gợi ý, Icon bookmark, Nút mic) **bắt buộc** có kích thước chạm tối thiểu:
  $$\text{Kích thước vùng bấm} \ge 44 \times 44\,\text{pt (iOS)} \quad \text{hoặc} \quad 48 \times 48\,\text{dp (Android)}$$
* Nếu icon có kích thước hiển thị nhỏ (VD: `20px`), bọc ngoài bằng `IconButton` hoặc `Padding` để mở rộng vùng bấm, tránh trường hợp người dùng bấm trượt khi đang di chuyển.

### 2.2. Vùng Ngón Cái (Thumb Zone)
* Đặt toàn bộ các tác vụ chính (Nút Mic, Thanh nhập chat, Chuyển tab Watchlist) ở vùng đáy màn hình.
* Đặt các thông tin tham khảo thụ động (VN-Index header, biểu đồ nến lịch sử) ở vùng trên cùng.

---

## 3. TYPOGRAPHY & TABULAR NUMERALS TRÊN DI ĐỘNG

### 3.1. Font Chữ
* **Font Văn bản Tiếng Việt:** `Be Vietnam Pro` hoặc `Inter` (Hiển thị trọn vẹn dấu tiếng Việt trên cả iOS và Android, không lỗi chân chữ).
* **Font Số Liệu Tài Chính:** `JetBrains Mono` hoặc `Roboto Mono`.

### 3.2. Cấu Hình Font Số Tabular (Bắt Buộc)
Khi bảng giá khớp lệnh liên tục, các con số thay đổi liên tục. Nếu dùng font tỷ lệ (proportional), các con số sẽ nhảy vị trí tạo cảm giác giật mắt.
```dart
const TextStyle mobileStockPriceStyle = TextStyle(
  fontFamily: 'JetBrainsMono',
  fontFeatures: [FontFeature.tabularFigures()],
  fontWeight: FontWeight.w700,
  fontSize: 22.0,
);
```

---

## 4. QUY CHUẨN TƯƠNG TÁC VUỐT & CHẠM (GESTURES)

* **Vuốt Xuống Để Đóng (Swipe-to-Dismiss):** Áp dụng cho `StockDetailBottomSheet`. Khi người dùng xem xong chi tiết mã, chỉ cần vuốt nhẹ ngón cái xuống dưới để trở lại luồng chat.
* **Vuốt Để Xóa (Dismissible):** Trong màn hình Watchlist, vuốt một mã cổ phiếu sang trái để xóa khỏi danh mục, kèm rung haptic nhẹ.
* **Bấm Giữ Để Ghi Âm (Long Press to Record):** Bấm giữ nút Mic để kích hoạt thu âm, thả tay để gửi, vuốt ngang để hủy lệnh ghi âm.

