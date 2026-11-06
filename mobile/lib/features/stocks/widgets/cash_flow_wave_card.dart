import 'package:flutter/material.dart';

/// Thẻ Trực Quan Hóa Áp Lực Dòng Tiền Mua / Bán Chủ Động
class CashFlowWaveCard extends StatelessWidget {
  final double buyPercentage; // Ví dụ: 64.0 (%)
  final num totalVolume;

  const CashFlowWaveCard({
    super.key,
    required this.buyPercentage,
    required this.totalVolume,
  });

  @override
  Widget build(BuildContext context) {
    final sellPercentage = (100.0 - buyPercentage).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222E42)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dòng tiền khớp lệnh chủ động',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
              ),
              Text(
                '${buyPercentage > 50 ? "Bên mua" : "Bên bán"} chiếm ưu thế',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: buyPercentage > 50 ? const Color(0xFF00C087) : const Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Thanh tỷ lệ Mua / Bán
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: buyPercentage.round(),
                    child: Container(color: const Color(0xFF00C087)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: sellPercentage.round(),
                    child: Container(color: const Color(0xFFFF3B30)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 3, backgroundColor: Color(0xFF00C087)),
                  const SizedBox(width: 4),
                  Text(
                    'Mua: ${buyPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00C087),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Bán: ${sellPercentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const CircleAvatar(radius: 3, backgroundColor: Color(0xFFFF3B30)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

