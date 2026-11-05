# Hoạt Họa & Trực Quan Hóa Chỉ Số Di Động (Mobile Fluid Animations)

Tài liệu này đúc kết các kỹ thuật animation mượt mà (chắt lọc từ `Best-Flutter-UI-Templates` của Mitesh77) và điều chỉnh để chạy mượt mà 60fps/120fps trên màn hình điện thoại iPhone (ProMotion) và Android.

---

## 1. NGUYÊN TẮC HOẠT HỌA DI ĐỘNG (MOBILE ANIMATION RULES)

1. **Phản hồi tức thì với cử chỉ chạm (Zero Latency Tap):** Khi ngón tay chạm vào nút hoặc card, hiệu ứng đổi màu/co nhẹ (`scale: 0.98`) phải xảy ra ngay trong `50ms - 100ms`, kèm phản hồi rung Haptic.
2. **Tiết kiệm Pin & Bộ nhớ:**
   * Chỉ kích hoạt Animation khi Widget đang hiển thị trên màn hình (`VisibilityDetector` hoặc ngắt ticker khi cuộn khỏi tầm nhìn).
   * Dùng `RepaintBoundary` xung quanh các widget vẽ CustomPainter (như `CashFlowWaveCard` và `FinancialHealthGauge`).

---

## 2. DANH SÁCH COMPONENT HOẠT HỌA ĐÃ TỐI ƯU CHO MOBILE

### 2.1. Vòng Tròn Điểm Sức Khỏe Doanh Nghiệp ([financial_health_gauge.dart](../examples/financial_health_gauge.dart))
* Hiệu ứng vòng tròn tiến độ chạy mượt từ 0 đến điểm thực tế trong 1.000ms với đường cong `Curves.easeOutCubic`.
* Chữ số điểm ở tâm vòng tròn đếm số tăng dần theo nhịp chạy của vòng tròn, hỗ trợ font `tabularFigures`.

### 2.2. Thẻ Sóng Áp Lực Dòng Tiền ([cash_flow_wave_card.dart](../examples/cash_flow_wave_card.dart))
* Mô phỏng 2 lớp sóng sin ngược pha chạy nhịp nhàng dưới nền thẻ, thể hiện tỷ lệ Mua/Bán chủ động và dòng tiền Khối ngoại mua ròng (Xanh lá) hoặc bán ròng (Đỏ).

### 2.3. Hiệu Ứng Xuất Hiện So Le ([staggered_fade_in_item.dart](../examples/staggered_fade_in_item.dart))
* Khi mở màn hình Watchlist hoặc nhận tin nhắn mới từ AI, các item trượt nhẹ từ dưới lên `20dp` và tăng dần độ mờ (Opacity) với độ trễ `index * 50ms`.

