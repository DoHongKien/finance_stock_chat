# Quy Chuẩn Chứng Khoán Việt Nam & Ánh Xạ Dữ Liệu SSI MCP (Vietnam Stock UX Specs)

Tài liệu này cung cấp toàn bộ kiến thức nghiệp vụ chuyên sâu về thị trường chứng khoán Việt Nam (VnStock) và cách chuyển hóa dữ liệu JSON từ **SSI MCP Server** thành các thành phần giao diện trực quan (Rich UI Widgets).

---

## 1. CÁC PHIÊN GIAO DỊCH & TRẠNG THÁI THỊ TRƯỜNG TRÊN GIAO DIỆN

Thời gian thị trường giao dịch trực tiếp tác động đến trạng thái (Market State) trên Header của ứng dụng:

| Khung Giờ (Thứ 2 - Thứ 6) | Phiên Giao Dịch | Hiển Thị Giao Diện (Badge & Trạng Thái) |
| :--- | :--- | :--- |
| **09:00 - 09:15** | Khớp lệnh định kỳ mở cửa (**ATO**) | 🟡 `ATO (Đang khớp mở cửa)` - Giá dự kiến khớp |
| **09:15 - 11:30** | Khớp lệnh liên tục sáng | 🟢 `Đang giao dịch (Sáng)` - Real-time Ticker nhấp nháy |
| **11:30 - 13:00** | Tạm nghỉ trưa | ⚪ `Nghỉ trưa` - Đóng băng giá, hiển thị giá đóng sáng |
| **13:00 - 14:30** | Khớp lệnh liên tục chiều | 🟢 `Đang giao dịch (Chiều)` - Dữ liệu khớp thời gian thực |
| **14:30 - 14:45** | Khớp lệnh định kỳ đóng cửa (**ATC**) | 🟡 `ATC (Đang khớp đóng cửa)` - Xác định giá đóng phiên |
| **14:45 - 15:00** | Giao dịch thỏa thuận (Put-through) | ⚪ `Thỏa thuận` |
| **15:00 - 09:00 hôm sau** | Đóng cửa thị trường / Cuối tuần | 🔴 `Thị trường đóng cửa` - Hiển thị giá chốt phiên |

> **UX Rule:** Khi thị trường đóng cửa, không hiển thị các chấm nhấp nháy "Live" màu xanh mà đổi sang màu xám kèm thông báo nhỏ: *"Số liệu chốt phiên ngày DD/MM/YYYY"*.

---

## 2. BIÊN ĐỘ GIAO DỊCH & CÔNG THỨC MÀU SẮC

### 2.1. Biên Độ Theo Sàn
* **HOSE (Sở GDCK TP.HCM):** $\pm 7\%$ so với giá tham chiếu.
* **HNX (Sở GDCK Hà Nội):** $\pm 10\%$ so với giá tham chiếu.
* **UPCOM:** $\pm 15\%$ so với giá bình quân phiên trước.

### 2.2. Thuật Toán Xác Định Màu Widget Trong Flutter
Khi nhận giá hiện tại `currentPrice` và giá tham chiếu `refPrice` từ SSI:

```dart
enum StockPriceColorType { ceiling, up, reference, down, floor }

StockPriceColorType getPriceColorType({
  required double currentPrice,
  required double refPrice,
  required double ceilingPrice,
  required double floorPrice,
}) {
  if (currentPrice >= ceilingPrice) return StockPriceColorType.ceiling;
  if (currentPrice <= floorPrice) return StockPriceColorType.floor;
  if (currentPrice > refPrice) return StockPriceColorType.up;
  if (currentPrice < refPrice) return StockPriceColorType.down;
  return StockPriceColorType.reference;
}
```

---

## 3. ÁNH XẠ DỮ LIỆU TỪ SSI MCP SERVER SANG GIAO DIỆN (UI MAPPING)

### 3.1. Tool `get_stock_info(symbol: 'FPT')`
* **Dữ liệu SSI trả về:**
  ```json
  {
    "symbol": "FPT",
    "company_name": "Công ty Cổ phần FPT",
    "exchange": "HOSE",
    "match_price": 135500,
    "price_change": 3200,
    "percent_change": 2.42,
    "ref_price": 132300,
    "ceiling_price": 141500,
    "floor_price": 123100,
    "total_volume": 4820000,
    "foreign_buy": 1250000,
    "foreign_sell": 430000
  }
  ```
* **Ánh xạ thành Widget `StockSummaryCard`:**
  * Ticker: `FPT` (Font Bold 20px).
  * Tag Sàn: `HOSE` (Nền xám mờ).
  * Giá: `135.50` (Chia 1.000 theo thông lệ bảng điện VN, hoặc hiển thị đầy đủ `135.500 ₫`).
  * Badge %: `+2.42% ▲` với màu xanh `stockUp` (`#00C087`).
  * Khối lượng: Format thân thiện `4.82M CP`.
  * Khối ngoại mua ròng: `+820K CP` (Xanh lá vì Mua > Bán).

### 3.2. Tool `get_financial_ratios(symbol: 'FPT')`
* **Dữ liệu SSI trả về:**
  ```json
  {
    "pe": 21.4,
    "pb": 4.8,
    "roe": 26.5,
    "roa": 12.1,
    "eps": 6320,
    "market_cap_bil": 198500
  }
  ```
* **Ánh xạ thành Grid Chỉ Số:**
  * Hiển thị bảng mini 2x3 ngay bên dưới thẻ giá.
  * Mỗi ô có Tooltip giải thích cho nhà đầu tư mới (ví dụ hover vào `P/E`: *"Hệ số giá trên thu nhập mỗi cổ phiếu"*).

---

## 4. QUY TẮC HIỂN THỊ ĐƠN VỊ TÀI CHÍNH VIỆT NAM (FORMATTERS)

1. **Đơn Vị Giá:**
   * Trên bảng giá tiêu chuẩn: Giá cổ phiếu thường được chia cho `1.000` (Ví dụ `135.5` tương đương `135.500 VNĐ`).
   * Trong câu trả lời của AI Trợ lý: Luôn viết rõ ràng kèm chữ đồng: `135.500 đồng/cổ phiếu`.
2. **Khối Lượng Khớp Lệnh:**
   * $< 1.000$: Viết nguyên số (ví dụ: `850 CP`).
   * $\ge 1.000$ và $< 1.000.000$: Viết dạng `K` (ví dụ: `350.5K CP`).
   * $\ge 1.000.000$: Viết dạng `M` hoặc `triệu CP` (ví dụ: `4.82M CP`).
   * $\ge 1.000.000.000$: Viết dạng `Tỷ` (ví dụ vốn hóa: `198.500 tỷ VNĐ`).
3. **Dấu Phân Cách Số Chuẩn Việt Nam:**
   * Sử dụng dấu chấm `.` phân cách hàng nghìn và dấu phẩy `,` phân cách thập phân: `135.500,00` (hoặc định dạng quốc tế `135,500.00` tùy cấu hình locale `vi_VN`).

