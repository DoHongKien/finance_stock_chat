import 'package:flutter/material.dart';
import 'stock_card_widget.dart';

/// Đại diện một tin nhắn từ Trợ lý AI có chứa Thẻ cổ phiếu trực quan
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
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Gemini AI
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),

          // Khung nội dung phản hồi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bong bóng chữ phân tích
                Container(
                  padding: const EdgeInsets.all(16),
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
                      // Badge xác nhận nguồn dữ liệu SSI MCP
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, size: 14, color: Color(0xFF00C087)),
                          const SizedBox(width: 4),
                          Text(
                            'Nguồn: SSI MCP Server (Thời gian thực)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00C087).withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Text phân tích ngôn ngữ tự nhiên
                      Text(
                        textAnalysis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE2E8F0),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nếu có mã cổ phiếu liên quan, nhúng ngay StockSummaryCard trực quan
                if (stockData != null) ...[
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: StockSummaryCard(stock: stockData!),
                  ),
                ],

                // Các Chip câu hỏi tiếp theo thông minh (Smart Follow-up Chips)
                if (followUpQuestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: followUpQuestions.map((q) {
                      return _SuggestionChip(
                        label: q,
                        onTap: () => onSelectFollowUp?.call(q),
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

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF1E293B) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? const Color(0xFF38BDF8) : const Color(0xFF222E42),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search, size: 14, color: Color(0xFF38BDF8)),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

