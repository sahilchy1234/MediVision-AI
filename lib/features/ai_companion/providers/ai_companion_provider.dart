import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_chat_service.dart';

final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return MockAiChatService();
});

class AiChatState {
  final List<ChatMessage> messages;
  final bool isThinking;

  const AiChatState({
    required this.messages,
    this.isThinking = false,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class AiCompanionNotifier extends StateNotifier<AiChatState> {
  final AiChatService _service;

  AiCompanionNotifier(this._service)
      : super(AiChatState(messages: _service.getInitialMessages()));

  Future<void> sendMessage(String text, {ChatAttachment? attachment}) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty && attachment == null) return;

    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmedText.isEmpty && attachment != null
          ? 'Uploaded: ${attachment.fileName}'
          : trimmedText,
      isUser: true,
      timestamp: DateTime.now(),
      attachment: attachment,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isThinking: true,
    );

    try {
      final aiReply = await _service.getAiResponse(
        trimmedText,
        attachment: attachment,
      );
      state = state.copyWith(
        messages: [...state.messages, aiReply],
        isThinking: false,
      );
    } catch (_) {
      state = state.copyWith(isThinking: false);
    }
  }

  void clearChat() {
    state = AiChatState(messages: _service.getInitialMessages());
  }
}

final aiCompanionProvider =
    StateNotifierProvider<AiCompanionNotifier, AiChatState>((ref) {
  final service = ref.watch(aiChatServiceProvider);
  return AiCompanionNotifier(service);
});
