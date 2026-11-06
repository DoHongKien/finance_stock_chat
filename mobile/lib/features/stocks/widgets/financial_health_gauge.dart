import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Đồng Hồ Đo Sức Khỏe Doanh Nghiệp (0 - 100 Điểm)
class FinancialHealthGauge extends StatelessWidget {
  final double score; // 0.0 -> 100.0
  final double size;

  const FinancialHealthGauge({
    super.key,
    required this.score,
    this.size = 110,
  });

  Color _getScoreColor() {
    if (score >= 80) return const Color(0xFF00C087); // Xanh lá: Rất tốt
    if (score >= 60) return const Color(0xFF38BDF8); // Xanh dương: Khá
    if (score >= 40) return const Color(0xFFFFB800); // Vàng: Trung bình
    return const Color(0xFFFF3B30); // Đỏ: Rủi ro cao
  }

  String _getRatingText() {
    if (score >= 80) return 'Xuất sắc';
    if (score >= 60) return 'Tích cực';
    if (score >= 40) return 'Trung bình';
    return 'Cảnh báo';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor();
    final rating = _getRatingText();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              score: score,
              activeColor: color,
              trackColor: const Color(0xFF222E42),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                rating,
                style: TextStyle(
                  fontSize: size * 0.11,
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
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color activeColor;
  final Color trackColor;

  _GaugePainter({
    required this.score,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const startAngle = 0.75 * math.pi;
    const sweepTotalAngle = 1.5 * math.pi;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vẽ track nền
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotalAngle,
      false,
      trackPaint,
    );

    // Vẽ arc điểm
    final progressSweep = (score.clamp(0, 100) / 100.0) * sweepTotalAngle;
    final progressPaint = Paint()
      ..color = activeColor
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.activeColor != activeColor;
  }
}

