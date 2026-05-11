import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';
import '../services/groq_service.dart';

class ChatProvider extends ChangeNotifier {
  final GroqService _groqService = GroqService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _accountType = 'home';
  Function(String)? _onAccountTypeChange;

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  static const String _systemPrompt =
      "You are Voltarisyn AI, an energy optimization assistant built into the Voltarisyn app. "
      "You MUST ONLY answer questions related to: energy consumption, electricity bills, power usage, "
      "device management, energy saving tips, solar panels, batteries, power grids, carbon footprint, "
      "sustainability, the Voltarisyn app features, and account settings. "
      "If a user asks ANYTHING unrelated to energy or this app (such as cooking recipes, general knowledge, "
      "entertainment, coding, math, weather, etc.), you MUST politely decline by saying: "
      "'I appreciate your curiosity! However, I'm designed specifically for energy optimization. "
      "I can help you with energy usage, bills, device management, and power savings. What would you like to know?' "
      "NEVER answer off-topic questions, regardless of how the user phrases them. "
      "If a user asks to change their account type (Home/Industry), confirm and update it. "
      "When a user explicitly requests to change their account type, respond with: "
      "'I've updated your account type to [Home/Industry]. The changes have been applied.' "
      "Include the exact phrase 'ACCOUNT_TYPE_CHANGE:home' or 'ACCOUNT_TYPE_CHANGE:industry' "
      "at the very end of your response (this will be hidden from the user). "
      "Always respond in a professional, helpful tone. Use ₹ (Indian Rupees) for currency. "
      "Keep responses concise and actionable.";

  void init(String accountType, Function(String) onAccountTypeChange) {
    _accountType = accountType;
    _onAccountTypeChange = onAccountTypeChange;
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        id: '1',
        role: 'ai',
        text: "Hello! I'm your Voltarisyn AI assistant. I'm here to help you with:\n\n"
            "⚡ Energy consumption analysis\n"
            "💰 Bill estimation & cost savings\n"
            "🔌 Device management & optimization\n"
            "🛡️ Power protection settings\n"
            "📊 Usage patterns & insights\n\n"
            "Ask me anything about your energy usage!",
        time: _formatTime(),
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      text: text,
      time: _formatTime(),
    ));
    _isTyping = true;
    notifyListeners();

    try {
      final conversationHistory = <Map<String, String>>[
        {'role': 'system', 'content': _systemPrompt},
      ];

      // Include last 10 messages for context
      final recentMessages = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages;
      for (final msg in recentMessages) {
        conversationHistory.add({
          'role': msg.role == 'ai' ? 'assistant' : 'user',
          'content': msg.text,
        });
      }

      final response = await _groqService.sendMessage(conversationHistory);

      // Check for account type change command
      String displayResponse = response;
      if (response.contains('ACCOUNT_TYPE_CHANGE:home')) {
        displayResponse =
            response.replaceAll('ACCOUNT_TYPE_CHANGE:home', '').trim();
        _accountType = 'home';
        _onAccountTypeChange?.call('home');
      } else if (response.contains('ACCOUNT_TYPE_CHANGE:industry')) {
        displayResponse =
            response.replaceAll('ACCOUNT_TYPE_CHANGE:industry', '').trim();
        _accountType = 'industry';
        _onAccountTypeChange?.call('industry');
      }

      _messages.add(ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 'ai',
        text: displayResponse,
        time: _formatTime(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 'ai',
        text: "I apologize, but I'm having trouble connecting right now. "
            "Please try again in a moment.",
        time: _formatTime(),
      ));
    }

    _isTyping = false;
    notifyListeners();
  }

  String _formatTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }
}
