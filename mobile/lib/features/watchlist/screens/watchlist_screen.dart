import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../stocks/models/stock_model.dart';
import '../../stocks/widgets/stock_card_widget.dart';
import '../../stocks/widgets/stock_detail_bottom_sheet.dart';
import '../controllers/watchlist_controller.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  void _showAddSymbolDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151D2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thêm mã theo dõi', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontFamily: 'JetBrainsMono'),
          decoration: const InputDecoration(
            hintText: 'Nhập mã CP (VD: SSI, VNM, TCB)...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              final symbol = controller.text.trim().toUpperCase();
              if (symbol.isNotEmpty) {
                AppHaptics.light();
                ref.read(watchlistControllerProvider.notifier).addStock(
                  StockModel(
                    symbol: symbol,
                    companyName: 'Mã theo dõi cá nhân',
                    exchange: 'HOSE',
                    currentPrice: 32.5,
                    change: 0.5,
                    changePercent: 1.56,
                    refPrice: 32.0,
                    ceilingPrice: 34.24,
                    floorPrice: 29.76,
                    pe: 14.2,
                    pb: 1.8,
                    roe: 18.0,
                    marketCap: '45.0 Tỷ',
                    sparklinePoints: [32.0, 32.2, 32.1, 32.4, 32.5],
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistState = ref.watch(watchlistControllerProvider);
    final watchlistNotifier = ref.read(watchlistControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header tóm tắt danh mục
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh Mục Theo Dõi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${watchlistState.items.length} mã đang quan sát',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddSymbolDialog(context, ref),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Thêm mã', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách thẻ cổ phiếu
          Expanded(
            child: watchlistState.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_outline, size: 48, color: Color(0xFF334155)),
                        const SizedBox(height: 12),
                        const Text(
                          'Chưa có mã cổ phiếu nào',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Hỏi trợ lý AI hoặc bấm "Thêm mã" để lưu vào đây',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: watchlistState.items.length,
                    itemBuilder: (context, index) {
                      final item = watchlistState.items[index];
                      final stock = item.liveData ??
                          StockModel(
                            symbol: item.symbol,
                            companyName: item.companyName ?? item.symbol,
                            exchange: 'HOSE',
                            currentPrice: 100.0,
                            change: 0.0,
                            changePercent: 0.0,
                            refPrice: 100.0,
                            ceilingPrice: 107.0,
                            floorPrice: 93.0,
                            pe: 0,
                            pb: 0,
                            roe: 0,
                            marketCap: '-',
                            sparklinePoints: [100, 100],
                          );

                      return Dismissible(
                        key: ValueKey(item.symbol),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                        ),
                        onDismissed: (_) {
                          AppHaptics.heavy();
                          watchlistNotifier.removeSymbol(item.symbol);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: StockSummaryCard(
                            stock: stock,
                            isBookmarked: true,
                            onWatchlistToggle: () => watchlistNotifier.removeSymbol(item.symbol),
                            onTap: () => StockDetailBottomSheet.show(context, stock),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

