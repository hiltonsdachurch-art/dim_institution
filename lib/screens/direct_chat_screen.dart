import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/direct_chat_service.dart';
import '../services/sound_service.dart';
import '../widgets/forensic_watermark_overlay.dart';

class DirectChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUid;
  final String currentAlias;
  final String counterpartAlias;

  const DirectChatScreen({
    super.key,
    required this.chatId,
    required this.currentUid,
    required this.currentAlias,
    required this.counterpartAlias,
  });

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final DirectChatService _directChatService = DirectChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<ChatMessage>>? _chatSubscription;
  int _lastCount = 0;
  String? _dlpWarningMessage;

  @override
  void initState() {
    super.initState();
    _chatSubscription = _directChatService
        .getDirectMessagesStream(widget.chatId)
        .listen((messages) {
      if (_lastCount > 0 && messages.length > _lastCount) {
        if (messages.last.senderUid != widget.currentUid) {
          SoundService.playNotificationChime();
        }
      }
      _lastCount = messages.length;
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _dlpWarningMessage = null);

    try {
      await _directChatService.sendDirectMessage(
        chatId: widget.chatId,
        senderUid: widget.currentUid,
        senderAlias: widget.currentAlias,
        text: text,
      );

      _textController.clear();
      await SoundService.playNotificationChime();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } on DlpSecurityViolationException catch (e) {
      setState(() => _dlpWarningMessage = e.message);
    } catch (e) {
      setState(() => _dlpWarningMessage = "Message blocked: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DIRECT INBOX: ${widget.counterpartAlias}",
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            Row(
              children: const [
                Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 12),
                SizedBox(width: 4),
                Text(
                  "1-on-1 Confidential • DLP Shield Active",
                  style: TextStyle(fontSize: 10, color: Color(0xFFD4AF37)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ForensicWatermarkOverlay(
        viewerIdentifier: widget.currentAlias,
        viewerUid: widget.currentUid,
        child: Column(
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF78350F).withOpacity(0.4),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined,
                      color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Direct Inquiry Protocol: You may converse directly about marriage ideals and compatibility. Contact numbers and handles are automatically blocked.",
                      style: TextStyle(
                          color: Color(0xFFFDE68A), fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // DLP Trigger Alert
            if (_dlpWarningMessage != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dlpWarningMessage!,
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 16, color: Colors.white70),
                      onPressed: () =>
                          setState(() => _dlpWarningMessage = null),
                    ),
                  ],
                ),
              ),

            // Message Stream
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _directChatService
                    .getDirectMessagesStream(widget.chatId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFFD4AF37)));
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              size: 48, color: Colors.white24),
                          const SizedBox(height: 12),
                          Text(
                            "Start your dialogue with ${widget.counterpartAlias}",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "Discuss personal vision, faith, and character directly in this private inbox.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg.senderUid == widget.currentUid;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Send a direct message...",
                        hintStyle: const TextStyle(
                            color: Colors.white38, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFD4AF37),
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send,
                          color: Color(0xFF0F172A), size: 18),
                      onPressed: _handleSendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFD4AF37).withOpacity(0.2)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMe
                ? const Color(0xFFD4AF37).withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isMe ? "You (${msg.senderAlias})" : msg.senderAlias,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isMe ? const Color(0xFFD4AF37) : Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}