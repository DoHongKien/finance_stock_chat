import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../stocks/models/stock_model.dart';
import '../../stocks/widgets/stock_card_widget.dart';

/// Bong bóng phản hồi của Trợ lý AI tích hợp Markdown, Thẻ Cổ Phiếu SSI & Gợi ý câu hỏi
class AssistantBubble extends StatelessWidget {
  final String text;
  final StockModel? stockData;
  final List<String> followUps;
  final bool isLoading;
  final Function(String query)? onSelectFollowUp;

  const AssistantBubble({
    super.key,
    required this.text,
    this.stockData,
    this.followUps = const [],
    this.isLoading = false,
    this.onSelectFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar biểu tượng Gemini AI
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),

          // Nội dung phản hồi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      // Badge nguồn cấp dữ liệu SSI MCP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, size: 13, color: Color(0xFF00C087)),
                              const SizedBox(width: 4),
                              Text(
                                'Nguồn: SSI MCP Server',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00C087).withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              AppHaptics.light();
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã sao chép câu trả lời'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (isLoading)
                        const Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đang lấy số liệu từ SSI & phân tích...',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF94A3B8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      else
                        MarkdownBody(
                          data: text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFFE2E8F0),
                              height: 1.5,
                            ),
                            strong: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            listBullet: const TextStyle(color: Color(0xFF38BDF8)),
                          ),
                        ),
                    ],
                  ),
                ),

                // Thẻ StockCard trực quan nếu AI trả về mã cổ phiếu
                if (stockData != null) ...[
                  const SizedBox(height: 10),
                  StockSummaryCard(stock: stockData!),
                ],

                // Chip gợi ý các câu hỏi tiếp theo
                if (followUps.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: followUps.map((q) {
                      return ActionChip(
                        label: Text(
                          q,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFF121824),
                        side: const BorderSide(color: Color(0xFF222E42)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () {
                          AppHaptics.light();
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

