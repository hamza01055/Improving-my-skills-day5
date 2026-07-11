import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_client.dart';
import 'models/chat_message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

/// Single source of truth for chat history and sending messages.
class ChatRepository {
  const ChatRepository(this._api);

  final ApiClient _api;

  Future<List<ChatMessageModel>> history() async {
    final res = await _api.get(ApiEndpoints.chatHistory);
    final data = res.data as List<dynamic>;
    return data
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends a message and returns the [userMessage, assistantMessage] pair.
  Future<List<ChatMessageModel>> send(String content) async {
    final res = await _api.post(ApiEndpoints.chat, data: {'content': content});
    final data = res.data as Map<String, dynamic>;
    return [
      ChatMessageModel.fromJson(data['user_message'] as Map<String, dynamic>),
      ChatMessageModel.fromJson(data['assistant_message'] as Map<String, dynamic>),
    ];
  }
}
