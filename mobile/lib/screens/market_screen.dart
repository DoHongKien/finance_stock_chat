import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  /// Xác định phiên giao dịch chứng khoán Việt Nam theo giờ hệ thống
  Map<String, dynamic> _getMarketSessionInfo() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final timeVal = hour * 60 + minute;

    // Thứ 7 hoặc Chủ Nhật
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return {'name': 'Đóng cửa (Cuối tuần)', 'color': const Color(0xFF64748B), 'active': false};
    }

    if (timeVal < 9 * 60) {
      return {'name': 'Chưa mở cửa', 'color': const Color(0xFF64748B), 'active': false};
    } else if (timeVal <= 9 * 60 + 15) {
      return {'name': 'Phiên ATO (Mở cửa)', 'color': const Color(0xFFFFB800), 'active': true};
    } else if (timeVal <= 11 * 60 + 30) {
      return {'name': 'Đang giao dịch (Sáng)', 'color': const Color(0xFF00C087), 'active': true};
    } else if (timeVal <= 13 * 60) {
      return {'name': 'Nghỉ trưa', 'color': const Color(0xFF64748B), 'active': false};
    } else if (timeVal <= 14 * 60 + 30) {
      return {'name': 'Đang giao dịch (Chiều)', 'color': const Color(0xFF00C087), 'active': true};
    } else if (timeVal <= 14 * 60 + 45) {
      return {'name': 'Phiên ATC (Đóng cửa)', 'color': const Color(0xFFFFB800), 'active': true};
    } else if (timeVal <= 15 * 60) {
      return {'name': 'Giao dịch thỏa thuận', 'color': const Color(0xFF64748B), 'active': false};
    } else {
      return {'name': 'Đã đóng phiên', 'color': const Color(0xFF64748B), 'active': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _getMarketSessionInfo();
    final sessionColor = session['color'] as Color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Banner trạng thái phiên
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: sessionColor),
                    const SizedBox(width: 8),
                    Text(
                      'Trạng thái: ${session['name']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sessionColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SSI Realtime',
                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Lưới 4 chỉ số chính (VN-Index, VN30, HNX, UPCOM)
          const Text(
            'Chỉ số thị trường',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildIndexCard(
                  name: 'VN-INDEX',
                  value: '1,288.50',
                  change: '+12.45',
                  percent: '+0.98%',
                  isUp: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildIndexCard(
                  name: 'VN30',
                  value: '1,342.10',
                  change: '+15.20',
                  percent: '+1.14%',
                  isUp: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildIndexCard(
                  name: 'HNX-INDEX',
                  value: '243.80',
                  change: '-0.65',
                  percent: '-0.27%',
                  isUp: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildIndexCard(
                  name: 'UPCOM',
                  value: '92.40',
                  change: '+0.32',
                  percent: '+0.35%',
                  isUp: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Khối lượng & Khối ngoại mua/bán ròng
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thanh khoản & Khối ngoại',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMarketStat('Tổng GTGD', '18,420 Tỷ', const Color(0xFFF8FAFC)),
                    _buildMarketStat('Khối ngoại mua ròng', '+482 Tỷ', const Color(0xFF00C087)),
                    _buildMarketStat('Mã tăng/giảm', '245 / 130', const Color(0xFF38BDF8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Nhóm ngành dẫn dắt
          const Text(
            'Nhóm ngành nổi bật hôm nay',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildSectorRow('Công nghệ thông tin', '+2.85%', 'Dẫn dắt bởi FPT, CMG', true),
          const SizedBox(height: 8),
          _buildSectorRow('Ngân hàng', '+1.45%', 'Dẫn dắt bởi MBB, TCB, VCB', true),
          const SizedBox(height: 8),
          _buildSectorRow('Bất động sản', '-0.38%', 'Áp lực điều chỉnh ngắn hạn', false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildIndexCard({
    required String name,
    required String value,
    required String change,
    required String percent,
    required bool isUp,
  }) {
    final color = isUp ? const Color(0xFF00C087) : const Color(0xFFFF3B30);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222E42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 16),
              Text(
                '$change ($percent)',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSectorRow(String sector, String change, String note, bool isUp) {
    final color = isUp ? const Color(0xFF00C087) : const Color(0xFFFF3B30);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222E42)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sector, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 2),
              Text(note, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          Text(
            change,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
