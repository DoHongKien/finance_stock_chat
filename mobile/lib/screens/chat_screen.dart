import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/chat/controllers/chat_controller.dart';
import '../features/chat/models/chat_message.dart';
import '../features/chat/widgets/assistant_bubble.dart';
import '../features/chat/widgets/chat_input_bar.dart';
import '../features/chat/widgets/user_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final chatNotifier = ref.read(chatControllerProvider.notifier);

    // Tự động cuộn xuống khi có tin nhắn mới
    ref.listen<ChatState>(chatControllerProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // Danh sách tin nhắn trò chuyện
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: chatState.messages.length,
            itemBuilder: (context, index) {
              final message = chatState.messages[index];
              if (message.sender == MessageSender.user) {
                return UserBubble(
                  text: message.content,
                  timestamp: message.timestamp,
                );
              } else {
                return AssistantBubble(
                  text: message.content,
                  stockData: message.stockData,
                  followUps: message.followUps,
                  isLoading: message.isLoading,
                  onSelectFollowUp: (query) {
                    chatNotifier.sendQuery(query);
                  },
                );
              }
            },
          ),
        ),

        // Thanh nhập văn bản sát đáy
        ChatInputBar(
          isBusy: chatState.isBusy,
          onSend: (text) {
            chatNotifier.sendQuery(text);
          },
        ),
      ],
    );
  }
}

