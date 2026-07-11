import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/chat_repository.dart';
import '../data/models/chat_message_model.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatNotifier extends Notifier<ChatState> {
  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  @override
  ChatState build() => const ChatState();

  Future<void> loadHistory() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final messages = await _repo.history();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      state = state.copyWith(isSending: true, error: null);
      final pair = await _repo.send(content);
      state = state.copyWith(messages: [...state.messages, ...pair], isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  /// Clears the visible conversation. The backend has no per-conversation
  /// session concept yet (history is keyed only by user), so this only
  /// resets local UI state — calling [loadHistory] again would restore the
  /// same backend history.
  // TODO(sessions): once the backend supports multiple chat sessions,
  // start a real new session here instead of just clearing local state.
  void startNewChat() {
    state = const ChatState();
  }
}
