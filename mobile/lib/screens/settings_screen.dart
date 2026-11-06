import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/haptic_helper.dart';
import '../features/chat/controllers/chat_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _secretController;

  @override
  void initState() {
    super.initState();
    final apiClient = ref.read(apiClientProvider);
    _urlController = TextEditingController(text: apiClient.baseUrl);
    _secretController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    AppHaptics.light();
    final apiClient = ref.read(apiClientProvider);
    apiClient.updateBaseUrl(_urlController.text.trim());
    if (_secretController.text.trim().isNotEmpty) {
      apiClient.updateToken(_secretController.text.trim());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu cấu hình kết nối Cloudflare Worker!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const Text(
            'Cấu hình kết nối Backend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Khung nhập URL Cloudflare Worker
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF222E42)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cloudflare Worker Endpoint',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'https://stockai-worker.subdomain.workers.dev',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'App Client Secret (Bearer Token)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _secretController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Nhập secret token bảo vệ backend (nếu có)',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _saveSettings,
                    child: const Text('Lưu Cấu Hình', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tình trạng kết nối SSI MCP & Gemini
          const Text(
            'Hạ tầng dịch vụ tích hợp',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildIntegrationTile(
            title: 'SSI MCP Server',
            subtitle: 'mcp.ssi.com.vn (Bảng giá, BCTC, P/E, VN-Index)',
            icon: Icons.hub_outlined,
            status: 'Hoạt động',
            statusColor: const Color(0xFF00C087),
          ),
          const SizedBox(height: 8),
          _buildIntegrationTile(
            title: 'Google Gemini AI',
            subtitle: 'Gemini 2.0 Flash (Function calling & tiếng Việt)',
            icon: Icons.auto_awesome,
            status: 'Sẵn sàng',
            statusColor: const Color(0xFF38BDF8),
          ),
          const SizedBox(height: 8),
          _buildIntegrationTile(
            title: 'Cloudflare D1 & Workers',
            subtitle: 'Serverless SQLite & MCP API Gateway',
            icon: Icons.cloud_done_outlined,
            status: '0 VNĐ',
            statusColor: const Color(0xFFFFB800),
          ),
          const SizedBox(height: 20),

          // Nút xóa lịch sử chat
          ListTile(
            tileColor: const Color(0xFF151D2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF222E42)),
            ),
            leading: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFFF3B30)),
            title: const Text('Xóa lịch sử trò chuyện', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text('Làm mới toàn bộ ngữ cảnh hội thoại', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            onTap: () {
              AppHaptics.medium();
              ref.read(chatControllerProvider.notifier).clearChat();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã làm mới cuộc hội thoại!')),
              );
            },
          ),
          const SizedBox(height: 20),

          // Thông tin ứng dụng
          Center(
            child: Column(
              children: [
                Text(
                  'StockAI / FinChat VN v1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Powered by Google Gemini 2.0 Flash & SSI MCP Server',
                  style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIntegrationTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222E42)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E293B),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
