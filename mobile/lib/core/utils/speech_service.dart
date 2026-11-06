import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Dịch vụ Speech-To-Text On-Device cho tiếng Việt
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  /// Khởi tạo và kiểm tra quyền Micro
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Kiểm tra quyền Micro
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final req = await Permission.microphone.request();
      if (!req.isGranted) {
        debugPrint('[SpeechService] Người dùng từ chối quyền Micro');
        return false;
      }
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: (errorNotification) {
          debugPrint('[SpeechService] Lỗi: ${errorNotification.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('[SpeechService] Trạng thái: $status');
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('[SpeechService] Exception khởi tạo: $e');
      return false;
    }
  }

  /// Bắt đầu lắng nghe giọng nói tiếng Việt
  Future<void> startListening({
    required Function(String recognizedWords) onResult,
    Function()? onSoundLevelChanged,
  }) async {
    final available = await initialize();
    if (!available) return;

    // Lựa chọn locale tiếng Việt vi_VN nếu có
    final locales = await _speech.locales();
    final viLocale = locales.firstWhere(
      (l) => l.localeId.startsWith('vi'),
      orElse: () => locales.isNotEmpty ? locales.first : stt.LocaleName('vi_VN', 'Tiếng Việt'),
    );

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      localeId: viLocale.localeId,
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  /// Dừng lắng nghe
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Hủy phiên lắng nghe
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
