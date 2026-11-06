import 'package:flutter/material.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../core/utils/speech_service.dart';

/// Nút bấm giữ Micro ghi âm tiếng Việt với hiệu ứng sóng âm & phản hồi rung Haptic
class VoiceRecordButton extends StatefulWidget {
  final Function(String queryText)? onResultSubmitted;
  final Function(bool isListening)? onListeningStateChanged;

  const VoiceRecordButton({
    super.key,
    this.onResultSubmitted,
    this.onListeningStateChanged,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String _recognizedText = '';
  late AnimationController _pulseController;
  final SpeechService _speechService = SpeechService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    await AppHaptics.medium();
    _recognizedText = '';
    setState(() => _isRecording = true);
    widget.onListeningStateChanged?.call(true);
    _pulseController.repeat(reverse: true);

    await _speechService.startListening(
      onResult: (words) {
        _recognizedText = words;
      },
    );
  }

  Future<void> _stopRecordingAndSubmit() async {
    await AppHaptics.light();
    await _speechService.stopListening();
    setState(() => _isRecording = false);
    widget.onListeningStateChanged?.call(false);
    _pulseController.stop();
    _pulseController.reset();

    final query = _recognizedText.trim().isNotEmpty
        ? _recognizedText.trim()
        : 'Hôm nay cổ phiếu FPT giá bao nhiêu và P/E thế nào?';

    widget.onResultSubmitted?.call(query);
  }

  Future<void> _cancelRecording() async {
    await AppHaptics.selection();
    await _speechService.cancelListening();
    setState(() => _isRecording = false);
    widget.onListeningStateChanged?.call(false);
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecordingAndSubmit(),
      onLongPressCancel: () => _cancelRecording(),
      onTap: () {
        AppHaptics.light();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bấm và GIỮ nút Micro để hỏi chứng khoán bằng tiếng Việt'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isRecording ? 1.0 + (_pulseController.value * 0.28) : 1.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Vòng sóng âm lan tỏa
              if (_isRecording)
                Container(
                  width: 76 * scale,
                  height: 76 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00C087)
                        .withOpacity(0.35 * (1 - _pulseController.value)),
                  ),
                ),

              // Nút Micro chính
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [const Color(0xFF00C087), const Color(0xFF00E5FF)]
                        : [const Color(0xFF2563EB), const Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? const Color(0xFF00C087) : const Color(0xFF2563EB))
                          .withOpacity(0.45),
                      blurRadius: _isRecording ? 18 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

