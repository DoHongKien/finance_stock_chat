import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../stocks/models/stock_model.dart';
import '../models/chat_message.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isBusy;
  final String? conversationId;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isBusy = false,
    this.conversationId,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isBusy,
    String? conversationId,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isBusy: isBusy ?? this.isBusy,
      conversationId: conversationId ?? this.conversationId,
      error: error,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final ApiClient _apiClient;

  ChatController(this._apiClient)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                id: 'welcome_msg',
                sender: MessageSender.assistant,
                content:
                    'Xin chào! Tôi là **Trợ lý AI Chứng khoán**, kết nối trực tiếp với **SSI MCP Server**.\n\nBạn có thể **bấm giữ nút Micro ở giữa màn hình** hoặc gõ câu hỏi để tra cứu bảng giá, định giá P/E, P/B, biên lợi nhuận hoặc dòng tiền khối ngoại.',
                timestamp: DateTime.now(),
                followUps: [
                  'Hôm nay VN-Index tăng hay giảm?',
                  'Xem giá và P/E của FPT',
                  'Khối ngoại mua ròng mã nào nhiều nhất?',
                ],
              ),
            ],
          ),
        );

  /// Gửi câu hỏi đến hệ thống
  Future<void> sendQuery(String queryText) async {
    final cleanQuery = queryText.trim();
    if (cleanQuery.isEmpty || state.isBusy) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      content: cleanQuery,
      timestamp: DateTime.now(),
    );

    final loadingMsg = ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      content: 'Đang truy vấn SSI MCP và phân tích...',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, loadingMsg],
      isBusy: true,
      error: null,
    );

    try {
      final res = await _apiClient.sendChatMessage(
        query: cleanQuery,
        conversationId: state.conversationId,
      );

      StockModel? stockModel;
      if (res['stock_data'] != null && res['stock_data'] is Map<String, dynamic>) {
        stockModel = StockModel.fromJson(res['stock_data'] as Map<String, dynamic>);
      }

      final followUps = (res['follow_ups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];

      final assistantMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.assistant,
        content: res['content'] as String? ?? 'Không có phản hồi từ máy chủ.',
        stockData: stockModel,
        followUps: followUps,
        timestamp: DateTime.now(),
        isLoading: false,
      );

      // Thay thế loading message bằng assistantMsg
      final updatedList = List<ChatMessage>.from(state.messages)
        ..removeWhere((m) => m.id == loadingMsg.id)
        ..add(assistantMsg);

      state = state.copyWith(
        messages: updatedList,
        isBusy: false,
        conversationId: res['conversation_id'] as String? ?? state.conversationId,
      );
    } catch (e) {
      final updatedList = List<ChatMessage>.from(state.messages)
        ..removeWhere((m) => m.id == loadingMsg.id)
        ..add(
          ChatMessage(
            id: 'err_${DateTime.now().millisecondsSinceEpoch}',
            sender: MessageSender.assistant,
            content: 'Không thể kết nối đến máy chủ: $e',
            timestamp: DateTime.now(),
            isLoading: false,
          ),
        );

      state = state.copyWith(
        messages: updatedList,
        isBusy: false,
        error: e.toString(),
      );
    }
  }

  /// Xóa toàn bộ lịch sử trò chuyện
  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          id: 'welcome_new',
          sender: MessageSender.assistant,
          content: 'Cuộc trò chuyện đã được làm mới. Bạn cần hỗ trợ phân tích mã chứng khoán nào?',
          timestamp: DateTime.now(),
          followUps: ['Xem biến động VN-Index', 'Phân tích FPT', 'Phân tích HPG'],
        ),
      ],
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatController(apiClient);
});

