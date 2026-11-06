import 'package:flutter/material.dart';
import '../../../core/constants/stock_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptic_helper.dart';
import '../models/stock_model.dart';
import 'cash_flow_wave_card.dart';
import 'financial_health_gauge.dart';
import 'sparkline_chart.dart';

/// Modal Bottom Sheet hiển thị chi tiết cổ phiếu theo chuẩn công thái học ngón tay cái
class StockDetailBottomSheet extends StatelessWidget {
  final StockModel stock;

  const StockDetailBottomSheet({super.key, required this.stock});

  static void show(BuildContext context, StockModel stock) {
    AppHaptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151D2A),
      builder: (ctx) => StockDetailBottomSheet(stock: stock),
    );
  }

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

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
              // Thanh kéo (Drag handle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề & Mã sàn
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            stock.symbol,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222E42),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              stock.exchange,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stock.companyName,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Giá & Bộ 3 mốc Trần / Tham chiếu / Sàn
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101722),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222E42)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stock.currentPrice.toStringAsFixed(2),
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              '${isPositive ? "+" : ""}${stock.change.toStringAsFixed(2)} (${isPositive ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        // Sparkline mở rộng
                        SparklineChart(
                          points: stock.sparklinePoints,
                          lineColor: primaryColor,
                          width: 120,
                          height: 50,
                          showFillGradient: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFF1E293B), height: 1),
                    const SizedBox(height: 12),
                    // Mốc 3 giá: Trần - Tham chiếu - Sàn
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPriceLevel(
                          label: 'Trần (Ceil)',
                          price: stock.ceilingPrice,
                          color: stockColors.ceiling,
                        ),
                        _buildPriceLevel(
                          label: 'TC (Ref)',
                          price: stock.refPrice,
                          color: stockColors.reference,
                        ),
                        _buildPriceLevel(
                          label: 'Sàn (Floor)',
                          price: stock.floorPrice,
                          color: stockColors.floor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sức khỏe tài chính & Dòng tiền
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101722),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF222E42)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Sức khỏe tài chính',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FinancialHealthGauge(score: stock.healthScore, size: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Lực mua / bán chủ động
              CashFlowWaveCard(
                buyPercentage: stock.buyPressure,
                totalVolume: 5600000,
              ),
              const SizedBox(height: 16),

              // Lưới các chỉ số định giá & cơ bản
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101722),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF222E42)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chỉ số định giá & Hiệu quả kinh doanh',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoItem('P/E', stock.pe.toStringAsFixed(1))),
                        Expanded(child: _buildInfoItem('P/B', stock.pb.toStringAsFixed(1))),
                        Expanded(child: _buildInfoItem('ROE', '${stock.roe.toStringAsFixed(1)}%')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoItem('Vốn hóa', stock.marketCap)),
                        Expanded(child: _buildInfoItem('Nguồn dữ liệu', 'SSI MCP Server')),
                        Expanded(child: _buildInfoItem('Sàn niêm yết', stock.exchange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceLevel({
    required String label,
    required double price,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          StockFormatters.formatPrice(price),
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontFeatures: const [FontFeature.tabularFigures()],
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }
}
