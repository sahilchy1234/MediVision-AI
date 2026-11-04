import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_chat_service.dart';

final aiChatServiceProvider = Provider<GroqAiChatService>((ref) {
  return GroqAiChatService();
});

class GroqConfigState {
  final String? apiKey;
  final String selectedModel;
  final bool isLoading;

  const GroqConfigState({
    this.apiKey,
    this.selectedModel = 'llama-3.3-70b-versatile',
    this.isLoading = false,
  });

  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  GroqConfigState copyWith({
    String? apiKey,
    String? selectedModel,
    bool? isLoading,
  }) {
    return GroqConfigState(
      apiKey: apiKey ?? this.apiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GroqConfigNotifier extends StateNotifier<GroqConfigState> {
  final GroqAiChatService _service;

  GroqConfigNotifier(this._service) : super(const GroqConfigState()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    state = state.copyWith(isLoading: true);
    final key = await _service.getApiKey();
    final model = await _service.getSelectedModel();
    state = GroqConfigState(
      apiKey: key,
      selectedModel: model,
      isLoading: false,
    );
  }

  Future<void> setApiKey(String key) async {
    await _service.setApiKey(key);
    state = state.copyWith(apiKey: key.trim());
  }

  Future<void> setModel(String model) async {
    await _service.setSelectedModel(model);
    state = state.copyWith(selectedModel: model.trim());
  }
}

final groqConfigProvider =
    StateNotifierProvider<GroqConfigNotifier, GroqConfigState>((ref) {
  final service = ref.watch(aiChatServiceProvider);
  return GroqConfigNotifier(service);
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
  final GroqAiChatService _service;
  final Ref _ref;

  AiCompanionNotifier(this._service, this._ref)
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

    final currentMessages = [...state.messages, userMessage];

    state = state.copyWith(
      messages: currentMessages,
      isThinking: true,
    );

    try {
      final config = _ref.read(groqConfigProvider);
      final aiReply = await _service.getAiResponse(
        trimmedText,
        attachment: attachment,
        history: currentMessages,
        model: config.selectedModel,
      );
      state = state.copyWith(
        messages: [...state.messages, aiReply],
        isThinking: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
        text: 'An error occurred while communicating with the AI service: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isThinking: false,
      );
    }
  }

  void clearChat() {
    state = AiChatState(messages: _service.getInitialMessages());
  }
}

final aiCompanionProvider =
    StateNotifierProvider<AiCompanionNotifier, AiChatState>((ref) {
  final service = ref.watch(aiChatServiceProvider);
  return AiCompanionNotifier(service, ref);
});
