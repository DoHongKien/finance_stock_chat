import 'dart:ui';
import 'package:flutter/material.dart';
import 'finance_theme.dart';

/// Dữ liệu mẫu đại diện cho một mã cổ phiếu từ SSI MCP
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

/// Widget Thẻ Cổ Phiếu Trực Quan Chuẩn UX/UI Tài Chính Việt Nam
class StockSummaryCard extends StatefulWidget {
  final StockData stock;
  final VoidCallback? onWatchlistToggle;
  final VoidCallback? onTapDetails;

  const StockSummaryCard({
    super.key,
    required this.stock,
    this.onWatchlistToggle,
    this.onTapDetails,
  });

  @override
  State<StockSummaryCard> createState() => _StockSummaryCardState();
}

class _StockSummaryCardState extends State<StockSummaryCard> {
  bool _isHovered = false;

  Color _getStockColor(VietnamStockColors colors) {
    if (widget.stock.currentPrice >= widget.stock.ceilingPrice) return colors.ceiling;
    if (widget.stock.currentPrice <= widget.stock.floorPrice) return colors.floor;
    if (widget.stock.currentPrice > widget.stock.refPrice) return colors.up;
    if (widget.stock.currentPrice < widget.stock.refPrice) return colors.down;
    return colors.reference;
  }

  @override
  Widget build(BuildContext context) {
    final stockColors = Theme.of(context).extension<VietnamStockColors>() ?? VietnamStockColors.dark;
    final primaryColor = _getStockColor(stockColors);
    final isPositive = widget.stock.change >= 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFF1B2433) : const Color(0xFF151D2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? primaryColor.withOpacity(0.5) : const Color(0xFF222E42),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: primaryColor.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hàng 1: Ticker, Tên công ty, Tag Sàn & Icon theo dõi
            Row(
              children: [
                Text(
                  widget.stock.symbol,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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
                    widget.stock.exchange,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, size: 20, color: Color(0xFF94A3B8)),
                  onPressed: widget.onWatchlistToggle,
                  tooltip: 'Thêm vào danh mục theo dõi',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            Text(
              widget.stock.companyName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // Hàng 2: Giá lớn + Biến động % + Sparkline chart mini
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Giá khớp với font Tabular Numerals
                    Text(
                      widget.stock.currentPrice.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge Tăng/Giảm %
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            size: 16,
                            color: primaryColor,
                          ),
                          Text(
                            '${isPositive ? "+" : ""}${widget.stock.change.toStringAsFixed(2)} (${isPositive ? "+" : ""}${widget.stock.changePercent.toStringAsFixed(2)}%)',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontFeatures: const [FontFeature.tabularFigures()],
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Sparkline biểu đồ đường mini
                SizedBox(
                  width: 90,
                  height: 40,
                  child: CustomPaint(
                    painter: MiniSparklinePainter(
                      points: widget.stock.sparklinePoints,
                      lineColor: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF222E42), height: 1),
            const SizedBox(height: 12),

            // Hàng 3: 4 Chỉ số tài chính cốt lõi (P/E, P/B, ROE, Vốn hóa)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRatioItem('P/E', widget.stock.pe.toStringAsFixed(1)),
                _buildRatioItem('P/B', widget.stock.pb.toStringAsFixed(1)),
                _buildRatioItem('ROE', '${widget.stock.roe.toStringAsFixed(1)}%'),
                _buildRatioItem('Vốn hóa', widget.stock.marketCap),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontFeatures: [FontFeature.tabularFigures()],
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter vẽ Sparkline nhẹ nhàng và chuẩn xác 60fps trên Web
class MiniSparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  MiniSparklinePainter({required this.points, required this.lineColor});

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
  bool shouldRepaint(covariant MiniSparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}

