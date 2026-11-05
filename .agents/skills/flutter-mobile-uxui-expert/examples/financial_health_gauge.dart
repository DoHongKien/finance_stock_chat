import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Widget Thang Đo Sức Khỏe Tài Chính Doanh Nghiệp (Mobile Financial Health Gauge)
class FinancialHealthGauge extends StatefulWidget {
  final double score; // Thang điểm từ 0.0 đến 100.0
  final String ratingTitle; // "Rất Tốt", "Khả Quan", "Rủi Ro"
  final String symbol; // Mã cổ phiếu (VD: "FPT")
  final double roe;
  final double pe;
  final double debtToEquity;

  const FinancialHealthGauge({
    super.key,
    required this.score,
    required this.ratingTitle,
    required this.symbol,
    required this.roe,
    required this.pe,
    required this.debtToEquity,
  });

  @override
  State<FinancialHealthGauge> createState() => _FinancialHealthGaugeState();
}

class _FinancialHealthGaugeState extends State<FinancialHealthGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return const Color(0xFF00C087);
    if (score >= 50) return const Color(0xFFFFB800);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _getScoreColor(widget.score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222E42)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sức Khỏe Tài Chính: ${widget.symbol}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.ratingTitle,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: activeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GaugeCirclePainter(
                    progress: _scoreAnimation.value / 100.0,
                    progressColor: activeColor,
                    backgroundColor: const Color(0xFF222E42),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _scoreAnimation.value.toInt().toString(),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'ĐIỂM / 100',
                          style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('ROE', '${widget.roe.toStringAsFixed(1)}%', const Color(0xFF00C087)),
              _buildMiniMetric('P/E', widget.pe.toStringAsFixed(1), const Color(0xFF38BDF8)),
              _buildMiniMetric('Nợ/Vốn', widget.debtToEquity.toStringAsFixed(2), const Color(0xFFFFB800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontFeatures: const [FontFeature.tabularFigures()],
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _GaugeCirclePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  _GaugeCirclePainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final activePaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.progressColor != progressColor;
  }
}

