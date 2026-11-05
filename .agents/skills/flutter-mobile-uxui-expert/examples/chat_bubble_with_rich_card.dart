import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stock_card_widget.dart';

/// Bong Bóng Tin Nhắn Của Trợ Lý AI Trên Điện Thoại
class AssistantMessageWidget extends StatelessWidget {
  final String textAnalysis;
  final StockData? stockData;
  final List<String> followUpQuestions;
  final Function(String query)? onSelectFollowUp;

  const AssistantMessageWidget({
    super.key,
    required this.textAnalysis,
    this.stockData,
    this.followUpQuestions = const [],
    this.onSelectFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Avatar Gemini
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),

          // Khung nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khung chữ giải thích
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151D2A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: const Color(0xFF222E42)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 13, color: Color(0xFF00C087)),
                          const SizedBox(width: 4),
                          Text(
                            'Nguồn: SSI MCP Server',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00C087).withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textAnalysis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFFE2E8F0),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Thẻ StockCard trực quan nhúng kèm
                if (stockData != null) ...[
                  const SizedBox(height: 10),
                  StockSummaryCard(stock: stockData!),
                ],

                // Các Chip câu hỏi tiếp theo
                if (followUpQuestions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: followUpQuestions.map((q) {
                      return ActionChip(
                        label: Text(q, style: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
                        backgroundColor: const Color(0xFF121824),
                        side: const BorderSide(color: Color(0xFF222E42)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onSelectFollowUp?.call(q);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

