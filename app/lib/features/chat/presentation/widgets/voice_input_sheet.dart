import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';

/// Records speech, transcribes it client-side, and sends the transcript as
/// a chat message on confirm. Reuses [chatProvider.sendMessage] — no
/// separate voice backend endpoint exists or is needed for this flow.
class VoiceInputSheet extends ConsumerStatefulWidget {
  const VoiceInputSheet({super.key});

  @override
  ConsumerState<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends ConsumerState<VoiceInputSheet> {
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _available = false;
  String _transcript = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final available = await _speech.initialize(
        onError: (e) {
          if (!mounted) return;
          setState(() {
            _error = 'Microphone error: ${e.errorMsg}';
            _isListening = false;
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      if (!mounted) return;
      setState(() => _available = available);
      if (!available) {
        setState(() {
          _error = 'Speech recognition is not available. Check microphone '
              'permission for this site in your browser settings.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _available = false;
        _error = 'Could not start speech recognition: $e';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    if (!_available) {
      setState(() => _error = 'Speech recognition is not available on this device.');
      return;
    }
    setState(() {
      _error = null;
      _isListening = true;
    });
    try {
      await _speech.listen(
        onResult: (result) => setState(() => _transcript = result.recognizedWords),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _error = 'Could not start listening: $e';
      });
    }
  }

  Future<void> _send() async {
    final text = _transcript.trim();
    if (text.isEmpty) return;
    await _speech.stop();
    if (!mounted) return;
    Navigator.of(context).pop();
    await ref.read(chatProvider.notifier).sendMessage(text);
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Speak your message',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none_outlined,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _error ??
                (_isListening
                    ? 'Listening...'
                    : _transcript.isEmpty
                        ? 'Tap the mic and start speaking.'
                        : 'Tap the mic to re-record.'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                ),
          ),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_transcript),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _transcript.trim().isEmpty ? null : _send,
            child: const Text('Send to chat'),
          ),
        ],
      ),
    );
  }
}
