import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/sound_service.dart';
import '../widgets/forensic_watermark_overlay.dart';

class CommunityLoungeScreen extends StatefulWidget {
  final String currentUid;
  final String currentAlias;

  const CommunityLoungeScreen({
    super.key,
    required this.currentUid,
    required this.currentAlias,
  });

  @override
  State<CommunityLoungeScreen> createState() => _CommunityLoungeScreenState();
}

class _CommunityLoungeScreenState extends State<CommunityLoungeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _dlpWarningMessage;

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _dlpWarningMessage = null);

    try {
      // 1. Run Data Loss Prevention Check (Throws exception if contact info is detected)
      _chatService.enforceAntiLeakDlp(text);

      // 2. Write to public community chamber
      final docRef = _db.collection('community_lounge_messages').doc();
      final message = ChatMessage(
        id: docRef.id,
        senderUid: widget.currentUid,
        senderAlias: widget.currentAlias,
        text: text,
        timestamp: DateTime.now(),
      );

      await docRef.set(message.toMap());
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

  void _showOnlineMembersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "INSTITUTION MEMBERS ONLINE",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('user_profiles').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                  }

                  final profiles = snapshot.data!.docs
                      .map((d) => CandidateProfile.fromMap(d.data() as Map<String, dynamic>))
                      .toList();

                  return ListView.builder(
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final p = profiles[index];
                      final bool isOnline = p.isOnline || p.uid == widget.currentUid;

                      return ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF0F172A),
                              radius: 18,
                              child: Text(
                                p.mbtiType.substring(0, 2),
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isOnline ? const Color(0xFF10B981) : Colors.white24,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                                ),
                              ),
                            )
                          ],
                        ),
                        title: Text(
                          p.alias,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isOnline ? "Active in Institution" : "Offline",
                          style: TextStyle(
                            color: isOnline ? const Color(0xFF34D399) : Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.mbtiType,
                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "COMMUNITY LOUNGE & AGORA",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            SizedBox(height: 2),
            Text(
              "Public Chamber • DLP Anti-Leak Shield Active",
              style: TextStyle(fontSize: 10, color: Color(0xFFD4AF37)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined, color: Color(0xFFD4AF37)),
            tooltip: "View Online Members",
            onPressed: () => _showOnlineMembersSheet(context),
          ),
        ],
      ),
      body: ForensicWatermarkOverlay(
        viewerIdentifier: widget.currentAlias,
        viewerUid: widget.currentUid,
        child: Column(
          children: [
            // Institutional Rule Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF78350F).withOpacity(0.4),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFFFBBF24), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Chamber Protocol: Converse freely about marriage philosophy, character, and ideals. Contact numbers, emails, and social handles are automatically intercepted.",
                      style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, height: 1.3),
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
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
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

            // Real-Time Lounge Stream
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db
                    .collection('community_lounge_messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.forum_outlined, size: 52, color: Colors.white24),
                          SizedBox(height: 12),
                          Text(
                            "The Institutional Chamber is Open",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Start a discussion with enrolled candidates on marriage and character.",
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = docs.map((d) => ChatMessage.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg.senderUid == widget.currentUid;
                      return _buildLoungeMessage(msg, isMe);
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
                        hintText: "Contribute to the marriage discussion...",
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

  Widget _buildLoungeMessage(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 420),
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