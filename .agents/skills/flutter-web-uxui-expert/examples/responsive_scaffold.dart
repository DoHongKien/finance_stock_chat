import 'package:flutter/material.dart';

/// Bộ khung giao diện thích ứng đa màn hình (Web Desktop, Tablet & Mobile)
class MainResponsiveScaffold extends StatelessWidget {
  final Widget body;

  const MainResponsiveScaffold({super.key, required this.body});

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 840 && MediaQuery.of(context).size.width < 1200;
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 840;

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      // 3 Cột: Sidebar Trái (Watchlist/Lịch sử) + Khung Chat Giữa + Panel Thị Trường Phải
      return Scaffold(
        body: Row(
          children: [
            const SizedBox(
              width: 280,
              child: LeftNavigationWatchlistPane(),
            ),
            const VerticalDivider(width: 1, color: Color(0xFF1E293B)),
            Expanded(
              child: body,
            ),
            const VerticalDivider(width: 1, color: Color(0xFF1E293B)),
            const SizedBox(
              width: 340,
              child: RightMarketSummaryPane(),
            ),
          ],
        ),
      );
    }

    if (isTablet(context)) {
      // 2 Cột: Sidebar Trái (Thu gọn hoặc drawer) + Khung Chat Giữa
      return Scaffold(
        body: Row(
          children: [
            const SizedBox(
              width: 260,
              child: LeftNavigationWatchlistPane(),
            ),
            const VerticalDivider(width: 1, color: Color(0xFF1E293B)),
            Expanded(child: body),
          ],
        ),
      );
    }

    // 1 Cột: Mobile View với App Bar & Drawer
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinChat VN AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF151D2A),
                builder: (_) => const RightMarketSummaryPane(),
              );
            },
          ),
        ],
      ),
      drawer: const Drawer(
        backgroundColor: Color(0xFF0F172A),
        child: LeftNavigationWatchlistPane(),
      ),
      body: body,
    );
  }
}

/// Panel Điều Hướng & Danh Mục Theo Dõi Bên Trái
class LeftNavigationWatchlistPane extends StatelessWidget {
  const LeftNavigationWatchlistPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Tên dự án
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF00C087)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('StockAI VN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  Text('Trợ lý SSI & Gemini', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Nút tạo đoạn hội thoại mới
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Cuộc trò chuyện mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),

          const Text('DANH MỤC THEO DÕI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 12),

          // Danh sách các mã cổ phiếu quan tâm
          Expanded(
            child: ListView(
              children: const [
                _WatchlistTile(symbol: 'FPT', price: '135.50', changePercent: '+2.42%', isUp: true),
                _WatchlistTile(symbol: 'HPG', price: '26.80', changePercent: '-0.74%', isUp: false),
                _WatchlistTile(symbol: 'MWG', price: '64.20', changePercent: '+1.10%', isUp: true),
                _WatchlistTile(symbol: 'SSI', price: '32.15', changePercent: '+3.04%', isUp: true),
                _WatchlistTile(symbol: 'VND', price: '15.90', changePercent: '0.00%', isRef: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  final String symbol;
  final String price;
  final String changePercent;
  final bool isUp;
  final bool isRef;

  const _WatchlistTile({
    required this.symbol,
    required this.price,
    required this.changePercent,
    this.isUp = true,
    this.isRef = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRef ? const Color(0xFFFFB800) : (isUp ? const Color(0xFF00C087) : const Color(0xFFFF3B30));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          Text(price, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: Color(0xFFCBD5E1))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(changePercent, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}

/// Panel Thông Tin Thị Trường Nhanh Bên Phải (Desktop Only)
class RightMarketSummaryPane extends StatelessWidget {
  const RightMarketSummaryPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THỊ TRƯỜNG CHUNG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          // Chỉ số VN-INDEX
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('VN-INDEX', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('+12.45 (+0.98%)', style: TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF00C087), fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 6),
                Text('1,288.50', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF00C087))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chỉ số VN30
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('VN30-INDEX', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('+15.20 (+1.15%)', style: TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF00C087), fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 6),
                Text('1,340.10', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF00C087))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

