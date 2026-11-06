import '../../stocks/models/stock_model.dart';

enum MessageSender { user, assistant }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final StockModel? stockData;
  final List<String> followUps;
  final DateTime timestamp;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    this.stockData,
    this.followUps = const [],
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    StockModel? stockData,
    List<String>? followUps,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      stockData: stockData ?? this.stockData,
      followUps: followUps ?? this.followUps,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

