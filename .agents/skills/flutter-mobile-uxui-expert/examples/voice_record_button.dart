import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Nút Bấm Ghi Âm Giọng Nói Bằng Tiếng Việt Kèm Rung Xúc Giác & Hoạt Họa Sóng Âm
/// Cho phép người dùng bấm giữ để nói, thả ra để gửi câu hỏi đến Gemini & SSI MCP
class VoiceRecordButton extends StatefulWidget {
  final Function(String queryText)? onResultSubmitted;

  const VoiceRecordButton({super.key, this.onResultSubmitted});

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;

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

  void _startRecording() {
    HapticFeedback.mediumImpact();
    setState(() => _isRecording = true);
    _pulseController.repeat(reverse: true);
  }

  void _stopRecordingAndSubmit() {
    HapticFeedback.lightImpact();
    setState(() => _isRecording = false);
    _pulseController.stop();
    _pulseController.reset();

    // Giả lập câu lệnh nhận diện được từ giọng nói (trong thực tế lấy từ speech_to_text)
    widget.onResultSubmitted?.call('Hôm nay cổ phiếu FPT giá bao nhiêu và P/E thế nào?');
  }

  void _cancelRecording() {
    HapticFeedback.selectionClick();
    setState(() => _isRecording = false);
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
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mẹo: Bấm và GIỮ nút Micro để hỏi bằng tiếng Việt'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isRecording ? 1.0 + (_pulseController.value * 0.25) : 1.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Vòng sóng âm lan tỏa khi đang ghi âm
              if (_isRecording)
                Container(
                  width: 76 * scale,
                  height: 76 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00C087).withOpacity(0.3 * (1 - _pulseController.value)),
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
                          .withOpacity(0.4),
                      blurRadius: _isRecording ? 16 : 8,
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

