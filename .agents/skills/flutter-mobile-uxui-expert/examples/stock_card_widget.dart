import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mobile_theme.dart';

class StockData {
  final String symbol;
  final String companyName;
  final String exchange;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double refPrice;
  final double ceilingPrice;
  final double floorPrice;
  final double pe;
  final double pb;
  final double roe;
  final String marketCap;
  final List<double> sparklinePoints;

  const StockData({
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.refPrice,
    required this.ceilingPrice,
    required this.floorPrice,
    required this.pe,
    required this.pb,
    required this.roe,
    required this.marketCap,
    required this.sparklinePoints,
  });
}

/// Thẻ Cổ Phiếu Tối Ưu Cho Điện Thoại Di Động
class StockSummaryCard extends StatelessWidget {
  final StockData stock;
  final VoidCallback? onWatchlistToggle;
  final VoidCallback? onTap;

  const StockSummaryCard({
    super.key,
    required this.stock,
    this.onWatchlistToggle,
    this.onTap,
  });

  Color _getStockColor(VietnamStockColors colors) {
    if (stock.currentPrice >= stock.ceilingPrice) return colors.ceiling;
    if (stock.currentPrice <= stock.floorPrice) return colors.floor;
    if (stock.currentPrice > stock.refPrice) return colors.up;
    if (stock.currentPrice < stock.refPrice) return colors.down;
    return colors.reference;
  }

  @override
  Widget build(BuildContext context) {
    final stockColors = Theme.of(context).extension<VietnamStockColors>() ?? VietnamStockColors.dark;
    final primaryColor = _getStockColor(stockColors);
    final isPositive = stock.change >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151D2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF222E42)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hàng 1: Mã cổ phiếu, Sàn & Nút Lưu
              Row(
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222E42),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      stock.exchange,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, size: 20, color: Color(0xFF94A3B8)),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onWatchlistToggle?.call();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Text(
                stock.companyName,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Hàng 2: Giá lớn + % biến động + Mini Sparkline Chart
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.currentPrice.toStringAsFixed(2),
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${isPositive ? "+" : ""}${stock.change.toStringAsFixed(2)} (${isPositive ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%)',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Sparkline mini
                  SizedBox(
                    width: 80,
                    height: 36,
                    child: CustomPaint(
                      painter: _MiniSparklinePainter(
                        points: stock.sparklinePoints,
                        lineColor: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF222E42), height: 1),
              const SizedBox(height: 10),

              // Hàng 3: 4 Chỉ số tài chính
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('P/E', stock.pe.toStringAsFixed(1)),
                  _buildMetric('P/B', stock.pb.toStringAsFixed(1)),
                  _buildMetric('ROE', '${stock.roe.toStringAsFixed(1)}%'),
                  _buildMetric('Vốn hóa', stock.marketCap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontFeatures: [FontFeature.tabularFigures()],
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  _MiniSparklinePainter({required this.points, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minVal) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}

