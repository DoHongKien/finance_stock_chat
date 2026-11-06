import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/haptic_helper.dart';
import '../features/chat/controllers/chat_controller.dart';
import '../features/chat/widgets/voice_record_button.dart';
import '../features/watchlist/screens/watchlist_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/market_screen.dart';
import '../screens/settings_screen.dart';

/// Khung Giao Diện Chính Của Ứng Dụng Mobile (StockAI / FinChat VN)
/// Tối ưu công thái học ngón tay cái với Bottom Navigation Bar & Nút Mic Trung Tâm
class AppMainScaffold extends ConsumerStatefulWidget {
  const AppMainScaffold({super.key});

  @override
  ConsumerState<AppMainScaffold> createState() => _AppMainScaffoldState();
}

class _AppMainScaffoldState extends ConsumerState<AppMainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    WatchlistScreen(),
    MarketScreen(),
    SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    AppHaptics.selection();
    setState(() => _currentIndex = index);
  }

  void _handleVoiceQuery(String voiceQuery) {
    // Chuyển về màn hình Chat và gửi câu hỏi
    setState(() => _currentIndex = 0);
    ref.read(chatControllerProvider.notifier).sendQuery(voiceQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      // App Bar hiển thị tiêu đề và chỉ số VN-Index thời gian thực
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D14),
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF00C087)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'StockAI VN',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          // Badge trạng thái VN-Index
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: Color(0xFF00C087)),
                SizedBox(width: 5),
                Text(
                  '1,288.50 (+0.98%)',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00C087),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Nội dung màn hình theo Tab
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),

      // Nút Micro Nổi ở Vị Trí Vàng Ngón Cái (Docked Center)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: VoiceRecordButton(
        onResultSubmitted: _handleVoiceQuery,
      ),

      // Bottom Navigation Bar chuẩn công thái học ngón tay cái
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121824),
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Trợ lý AI',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.bookmark_border,
                activeIcon: Icons.bookmark,
                label: 'Theo dõi',
                index: 1,
              ),
              const SizedBox(width: 48), // Khoảng trống cho Center Mic Button
              _buildNavItem(
                icon: Icons.show_chart,
                activeIcon: Icons.show_chart,
                label: 'Bảng giá',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Cài đặt',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B);

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
