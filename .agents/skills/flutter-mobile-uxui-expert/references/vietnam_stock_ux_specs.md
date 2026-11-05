# Quy Chuẩn Chứng Khoán Việt Nam & Ánh Xạ Dữ Liệu SSI MCP Lên Ứng Dụng Di Động

Tài liệu này cung cấp kiến thức thực tế về vận hành thị trường chứng khoán Việt Nam và cách chuyển hóa dữ liệu JSON từ **SSI MCP Server** thành giao diện thân thiện trên màn hình điện thoại di động.

---

## 1. PHIÊN GIAO DỊCH & HIỂN THỊ TRÊN STATUS BAR DI ĐỘNG

| Khung Giờ (Thứ 2 - Thứ 6) | Phiên Giao Dịch | Hiển Thị Giao Diện Mobile |
| :--- | :--- | :--- |
| **09:00 - 09:15** | Khớp lệnh định kỳ mở cửa (**ATO**) | 🟡 Badge vàng: `Phiên ATO` (Hiển thị giá khớp dự kiến) |
| **09:15 - 11:30** | Khớp lệnh liên tục sáng | 🟢 Badge xanh: `Đang GD (Sáng)` kèm chấm xanh nhấp nháy |
| **11:30 - 13:00** | Nghỉ trưa | ⚪ Badge xám: `Nghỉ trưa` (Đóng băng bảng giá) |
| **13:00 - 14:30** | Khớp lệnh liên tục chiều | 🟢 Badge xanh: `Đang GD (Chiều)` |
| **14:30 - 14:45** | Khớp lệnh định kỳ đóng cửa (**ATC**) | 🟡 Badge vàng: `Phiên ATC` (Xác định giá đóng cửa ngày) |
| **14:45 - 15:00** | Giao dịch thỏa thuận | ⚪ Badge xám: `Thỏa thuận` |
| **15:00 - 09:00 hôm sau** | Đóng cửa / Cuối tuần | 🔴 Badge đỏ mờ: `Đóng cửa` (Ghi chú ngày chốt phiên) |

---

## 2. BIÊN ĐỘ GIAO DỊCH THEO SÀN & MÀU SẮC

* **HOSE (TP.HCM):** $\pm 7\%$
* **HNX (Hà Nội):** $\pm 10\%$
* **UPCOM:** $\pm 15\%$

Quy tắc màu áp dụng cho mọi Widget hiển thị:
```dart
Color getPriceColor({
  required double current,
  required double ref,
  required double ceiling,
  required double floor,
  required VietnamStockColors colors,
}) {
  if (current >= ceiling) return colors.ceiling; // Tím trần
  if (current <= floor) return colors.floor;     // Xanh lơ sàn
  if (current > ref) return colors.up;           // Xanh lá
  if (current < ref) return colors.down;         // Đỏ
  return colors.reference;                       // Vàng tham chiếu
}
```

---

## 3. ÁNH XẠ DỮ LIỆU SSI MCP CHO MOBILE SCREEN

### 3.1. Tool `get_stock_info(symbol: 'FPT')`
* **Xử lý hiển thị trên màn hình nhỏ:**
  * Giá trên mobile: Hiển thị dạng rút gọn `135.50` (kèm tooltip giải thích `135.500 ₫`).
  * Khối lượng: Dùng ký hiệu `4.82M CP` để không chiếm diện tích ngang màn hình điện thoại.
  * Tỷ lệ % thay đổi: Luôn đi kèm icon mũi tên hướng lên `▲` hoặc xuống `▼` để người dùng nhận biết ngay lập tức mà không phụ thuộc hoàn toàn vào màu sắc.

### 3.2. Cảnh Báo Ngoài Giờ Giao Dịch (Off-Hours UX)
Khi người dùng hỏi lúc 21:00 tối hoặc vào ngày Chủ nhật:
* Trợ lý AI vẫn trả lời dựa trên dữ liệu chốt phiên gần nhất từ SSI MCP.
* Giao diện hiển thị thêm một thanh nhãn nhỏ phía dưới thẻ:
  `* Dữ liệu chốt phiên giao dịch ngày DD/MM/YYYY`.

