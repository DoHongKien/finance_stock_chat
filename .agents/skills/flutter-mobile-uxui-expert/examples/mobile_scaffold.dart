import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'voice_record_button.dart';

/// Khung Giao Diện Chính Của Ứng Dụng Mobile (StockAI / FinChat VN)
/// Tối ưu công thái học ngón tay cái với Bottom Navigation Bar & Nút Mic Trung Tâm
class AppMainScaffold extends StatefulWidget {
  final Widget currentTabBody;
  final int selectedIndex;
  final Function(int index) onTabSelected;
  final Function(String voiceQuery)? onVoiceInputSubmit;

  const AppMainScaffold({
    super.key,
    required this.currentTabBody,
    this.selectedIndex = 0,
    required this.onTabSelected,
    this.onVoiceInputSubmit,
  });

  @override
  State<AppMainScaffold> createState() => _AppMainScaffoldState();
}

class _AppMainScaffoldState extends State<AppMainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      // App Bar mỏng hiển thị trạng thái thị trường VN-Index
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0D14),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF00C087)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('StockAI VN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Trợ lý Chứng khoán SSI', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
        actions: [
          // Badge trạng thái thị trường
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: Color(0xFF00C087)),
                SizedBox(width: 6),
                Text(
                  'VN-INDEX: 1,288.50 (+0.98%)',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00C087),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Nội dung màn hình hiện tại
      body: SafeArea(
        child: widget.currentTabBody,
      ),

      // Nút Micro Nổi ở Vị Trí Vàng Ngón Cái (Docked Center)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: VoiceRecordButton(
        onResultSubmitted: (text) {
          widget.onVoiceInputSubmit?.call(text);
        },
      ),

      // Bottom Navigation Bar chuẩn ngón tay cái
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              const SizedBox(width: 48), // Chỗ trống cho Floating Action Button
              _buildNavItem(
                icon: Icons.show_chart,
                activeIcon: Icons.show_chart,
                label: 'Bảng giá',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
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
    final isSelected = widget.selectedIndex == index;
    final color = isSelected ? const Color(0xFF38BDF8) : const Color(0xFF64748B);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTabSelected(index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

