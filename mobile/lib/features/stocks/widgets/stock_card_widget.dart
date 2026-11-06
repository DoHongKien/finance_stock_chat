import 'package:flutter/material.dart';
import '../../../core/constants/stock_colors.dart';
import '../../../core/utils/haptic_helper.dart';
import '../models/stock_model.dart';
import 'sparkline_chart.dart';
import 'stock_detail_bottom_sheet.dart';

/// Thẻ Cổ Phiếu Tối Ưu Cho Điện Thoại Di Động
class StockSummaryCard extends StatelessWidget {
  final StockModel stock;
  final bool isBookmarked;
  final VoidCallback? onWatchlistToggle;
  final VoidCallback? onTap;

  const StockSummaryCard({
    super.key,
    required this.stock,
    this.isBookmarked = false,
    this.onWatchlistToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stockColors =
        Theme.of(context).extension<VietnamStockColors>() ?? VietnamStockColors.dark;

    final primaryColor = VietnamStockColors.getPriceColor(
      current: stock.currentPrice,
      ref: stock.refPrice,
      ceiling: stock.ceilingPrice,
      floor: stock.floorPrice,
      colors: stockColors,
    );

    final isPositive = stock.change >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          if (onTap != null) {
            onTap!();
          } else {
            StockDetailBottomSheet.show(context, stock);
          }
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
              // Hàng 1: Mã cổ phiếu, Sàn & Nút Lưu Watchlist
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
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: isBookmarked ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                    ),
                    onPressed: () {
                      AppHaptics.selection();
                      onWatchlistToggle?.call();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 2),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                              size: 14,
                              color: primaryColor,
                            ),
                            Text(
                              '${isPositive ? "+" : ""}${stock.change.toStringAsFixed(2)} (${isPositive ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontSize: 11,
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
                  // Sparkline mini
                  SparklineChart(
                    points: stock.sparklinePoints,
                    lineColor: primaryColor,
                    width: 80,
                    height: 36,
                    showFillGradient: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF222E42), height: 1),
              const SizedBox(height: 10),

              // Hàng 3: Các chỉ số tài chính cơ bản
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetric('P/E', stock.pe > 0 ? stock.pe.toStringAsFixed(1) : '-'),
                  _buildMetric('P/B', stock.pb > 0 ? stock.pb.toStringAsFixed(1) : '-'),
                  _buildMetric('ROE', stock.roe > 0 ? '${stock.roe.toStringAsFixed(1)}%' : '-'),
                  _buildMetric('Vốn hóa', stock.marketCap.isNotEmpty ? stock.marketCap : '-'),
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
        const SizedBox(height: 1),
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
