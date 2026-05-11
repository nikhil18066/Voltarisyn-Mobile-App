import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const _chips = [
    'Why did power cut happen?',
    'Which device uses most power?',
    "What's my peak usage time?",
    'Show savings tips',
    'What is my estimated bill?',
    'What is Auto Power Cut?',
    'How does the AI work?',
    'Change my account type',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatProvider>();
      final auth = context.read<AuthProvider>();
      final devices = context.read<DeviceProvider>();
      chat.init(auth.accountType, (newType) {
        auth.changeAccountTypeViaChatbot(newType);
        devices.setMode(newType);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    _scrollToBottom();

    return SafeArea(child: Column(children: [
      // Header
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.sparkles, size: 18, color: Colors.white)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Assistant', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
              const SizedBox(width: 4),
              Text('Online', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF22C55E))),
            ]),
          ]),
        ]),
      ).animate().fadeIn(),

      // Messages
      Expanded(child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == chat.messages.length && chat.isTyping) {
            return _TypingIndicator();
          }
          final msg = chat.messages[i];
          return _ChatBubble(role: msg.role, text: msg.text, time: msg.time).animate().fadeIn(duration: 300.ms);
        },
      )),

      // Suggestion chips
      SizedBox(height: 36, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _send(_chips[i]),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withValues(alpha: 0.06), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: Text(_chips[i], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF2563EB)))),
        ),
      )),

      const SizedBox(height: 8),

      // Input
      Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
        child: Row(children: [
          Expanded(child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withValues(alpha: 0.06), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: TextField(controller: _controller, style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              onSubmitted: _send,
              decoration: InputDecoration(hintText: 'Ask about your energy usage…', hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.3)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _send(_controller.text),
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(10)),
              child: const Icon(LucideIcons.send, size: 16, color: Colors.white)),
          ),
        ]),
      ),
    ]));
  }
}

class _ChatBubble extends StatelessWidget {
  final String role, text, time;
  const _ChatBubble({required this.role, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isUser) Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
          Container(width: 22, height: 22, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2563EB)),
            child: Center(child: Text('AI', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)))),
          const SizedBox(width: 6),
          Text('Voltarisyn AI', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ])),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.76 : 0.82)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4), bottomRight: Radius.circular(isUser ? 4 : 16)),
            border: isUser ? null : Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: isUser ? Colors.white : Colors.white.withValues(alpha: 0.85), height: 1.5)),
        ),
        const SizedBox(height: 4),
        Text(time, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
      ],
    ));
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Align(alignment: Alignment.centerLeft, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Container(
        margin: EdgeInsets.only(right: i < 2 ? 4 : 0), width: 6, height: 6,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.4)),
      ).animate(onPlay: (c) => c.repeat()).fadeIn(delay: Duration(milliseconds: i * 150)).fadeOut(delay: Duration(milliseconds: 600 + i * 150)))),
    )));
  }
}
