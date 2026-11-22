import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/sound_service.dart';
import '../widgets/forensic_watermark_overlay.dart';

class ChaperonedChatScreen extends StatefulWidget {
  final String introId;
  final String viewerUid;
  final String viewerAlias;
  final String counterpartAlias;

  const ChaperonedChatScreen({
    super.key,
    required this.introId,
    required this.viewerUid,
    required this.viewerAlias,
    required this.counterpartAlias,
  });

  @override
  State<ChaperonedChatScreen> createState() => _ChaperonedChatScreenState();
}

class _ChaperonedChatScreenState extends State<ChaperonedChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<ChatMessage>>? _chatSubscription;
  int _lastMessageCount = 0;
  String? _dlpWarningMessage;

  @override
  void initState() {
    super.initState();
    // Listen to real-time incoming messages to trigger the audio chime
    _chatSubscription = _chatService.getMessagesStream(widget.introId).listen((messages) {
      if (_lastMessageCount > 0 && messages.length > _lastMessageCount) {
        final lastMsg = messages.last;
        // Play chime if the incoming message is from the counterpart
        if (lastMsg.senderUid != widget.viewerUid) {
          SoundService.playNotificationChime();
        }
      }
      _lastMessageCount = messages.length;
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    setState(() => _dlpWarningMessage = null);

    try {
      await _chatService.sendMessage(
        introId: widget.introId,
        senderUid: widget.viewerUid,
        senderAlias: widget.viewerAlias,
        text: text,
      );
      _textController.clear();

      // Play chime on message dispatch
      await SoundService.playNotificationChime();

      // Scroll to bottom
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
      setState(() {
        _dlpWarningMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _dlpWarningMessage = "Transmission error: $e";
      });
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
              "CHAPERONED LOUNGE: ${widget.counterpartAlias}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            Row(
              children: const [
                Icon(Icons.volume_up_outlined, color: Color(0xFFD4AF37), size: 12),
                SizedBox(width: 4),
                Text(
                  "Audible Chimes Active • Monitored Chamber",
                  style: TextStyle(fontSize: 10, color: Color(0xFFD4AF37)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ForensicWatermarkOverlay(
        viewerIdentifier: widget.viewerAlias,
        viewerUid: widget.viewerUid,
        child: Column(
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF78350F).withOpacity(0.4),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Institutional Notice: Contact sharing is prohibited. Audio notifications are enabled for this discussion.",
                      style: TextStyle(fontSize: 11, color: Color(0xFFFDE68A), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // DLP Alert
            if (_dlpWarningMessage != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dlpWarningMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white70),
                      onPressed: () => setState(() => _dlpWarningMessage = null),
                    ),
                  ],
                ),
              ),

            // Messages Stream
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessagesStream(widget.introId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.forum_outlined, size: 48, color: Colors.white24),
                          const SizedBox(height: 12),
                          const Text(
                            "The Pre-Interview Chamber is Open",
                            style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              "Introduce yourself to ${widget.counterpartAlias}. Focus on character and marriage vision.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
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
                      final bool isMe = msg.senderUid == widget.viewerUid;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Converse about values and vision...",
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFD4AF37),
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF0F172A), size: 18),
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
          color: isMe ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMe ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
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