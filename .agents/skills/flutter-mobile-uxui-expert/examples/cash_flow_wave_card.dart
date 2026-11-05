import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Thẻ Sóng Áp Lực Dòng Tiền Khối Ngoại Cho Màn Hình Điện Thoại
class CashFlowWaveCard extends StatefulWidget {
  final double buyPercentage; // 0.0 -> 1.0 (VD: 0.65 = 65% Phe Mua)
  final String foreignNetText; // VD: "+45.2 tỷ VNĐ (Mua ròng)"
  final bool isForeignNetBuy;

  const CashFlowWaveCard({
    super.key,
    required this.buyPercentage,
    required this.foreignNetText,
    required this.isForeignNetBuy,
  });

  @override
  State<CashFlowWaveCard> createState() => _CashFlowWaveCardState();
}

class _CashFlowWaveCardState extends State<CashFlowWaveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = widget.isForeignNetBuy ? const Color(0xFF00C087) : const Color(0xFFFF3B30);

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222E42)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Sóng hoạt họa
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _DualWavePainter(
                    animationValue: _waveController.value,
                    fillRatio: widget.buyPercentage.clamp(0.2, 0.85),
                    waveColor: waveColor.withOpacity(0.18),
                  ),
                );
              },
            ),
          ),

          // Nội dung hiển thị
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.waterfall_chart, size: 15, color: Color(0xFF38BDF8)),
                        SizedBox(width: 6),
                        Text('XUNG LỰC DÒNG TIỀN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: waveColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(widget.buyPercentage * 100).toStringAsFixed(0)}% Phe Mua',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: waveColor),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Khối ngoại giao dịch:', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    Text(
                      widget.foreignNetText,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: waveColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DualWavePainter extends CustomPainter {
  final double animationValue;
  final double fillRatio;
  final Color waveColor;

  _DualWavePainter({
    required this.animationValue,
    required this.fillRatio,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final baseHeight = size.height * (1.0 - fillRatio);
    final waveAmplitude = 6.0;

    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(0, baseHeight);

    for (double i = 0; i <= size.width; i++) {
      final dx = i;
      final dy = baseHeight + math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * waveAmplitude;
      path1.lineTo(dx, dy);
    }
    path1.lineTo(size.width, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);
  }

  @override
  bool shouldRepaint(covariant _DualWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.fillRatio != fillRatio ||
        oldDelegate.waveColor != waveColor;
  }
}

