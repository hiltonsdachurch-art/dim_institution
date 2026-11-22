import 'package:flutter/material.dart';
import '../models/introduction_model.dart';
import '../models/direct_chat_model.dart';
import '../services/introduction_service.dart';
import '../services/direct_chat_service.dart';
import '../services/sound_service.dart';
import 'reveal_dossier_screen.dart';
import 'chaperoned_chat_screen.dart';
import 'direct_chat_screen.dart';

class CandidateInboxScreen extends StatelessWidget {
  final String currentCandidateUid;
  final String currentCandidateAlias;

  const CandidateInboxScreen({
    super.key,
    required this.currentCandidateUid,
    required this.currentCandidateAlias,
  });

  @override
  Widget build(BuildContext context) {
    final IntroductionService introService = IntroductionService();
    final DirectChatService directChatService = DirectChatService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "INBOX & CONVERSATIONS ($currentCandidateAlias)",
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: DIRECT 1-ON-1 INBOXES
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline,
                    color: Color(0xFFD4AF37), size: 18),
                SizedBox(width: 8),
                Text(
                  "DIRECT 1-ON-1 INBOXES (DISCOVERY CHATS)",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<DirectChatThread>>(
              stream: directChatService
                  .getUserDirectThreadsStream(currentCandidateUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37)));
                }

                final threads = snapshot.data ?? [];

                if (threads.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Center(
                      child: Text(
                        "No direct chats started yet. Scroll down Discovery to message a candidate.",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  );
                }

                return Column(
                  children: threads.map((thread) {
                    final counterpartAlias =
                        thread.getOtherAlias(currentCandidateUid);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0F172A),
                          child: const Icon(Icons.person,
                              color: Color(0xFFD4AF37), size: 18),
                        ),
                        title: Text(
                          counterpartAlias,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        subtitle: Text(
                          thread.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Color(0xFFD4AF37)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DirectChatScreen(
                                chatId: thread.id,
                                currentUid: currentCandidateUid,
                                currentAlias: currentCandidateAlias,
                                counterpartAlias: counterpartAlias,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // SECTION 2: FORMAL CURATED MATCH DOSSIERS
            Row(
              children: const [
                Icon(Icons.handshake_outlined,
                    color: Color(0xFFD4AF37), size: 18),
                SizedBox(width: 8),
                Text(
                  "FORMAL GATEKEEPER MATCH REQUESTS",
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<IntroductionRequest>>(
              stream: introService
                  .getCandidateInboxStream(currentCandidateUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37)));
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: const Center(
                      child: Text(
                        "No formal introduction requests received.",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  );
                }

                return Column(
                  children: requests.map((req) {
                    return _buildRequestCard(
                        context, req, introService);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    IntroductionRequest req,
    IntroductionService service,
  ) {
    final bool isActionable = req.state == IntroState.requested;
    final bool isApproved = req.state == IntroState.gatekeeperApproved;
    final bool hasChatAccess = req.state == IntroState.recipientAccepted ||
        req.state == IntroState.interviewsInProgress ||
        req.state == IntroState.gatekeeperApproved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApproved
              ? const Color(0xFFD4AF37).withOpacity(0.4)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Formal Match: ${req.initiatorAlias}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              _buildStatusBadge(req.state),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "This candidate has reviewed your values and formally requested a curated introduction.",
            style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 16),

          if (isActionable) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await service.respondToIntroduction(
                          introId: req.id, accept: false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Introduction declined.")),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    child: const Text("DECLINE"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await service.respondToIntroduction(
                          introId: req.id, accept: true);
                      await SoundService.playNotificationChime();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Accepted! Chaperoned Pre-Screening Chat is active."),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    child: const Text("ACCEPT"),
                  ),
                ),
              ],
            )
          ] else ...[
            if (hasChatAccess) ...[
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChaperonedChatScreen(
                          introId: req.id,
                          viewerUid: currentCandidateUid,
                          viewerAlias: currentCandidateAlias,
                          counterpartAlias: req.initiatorAlias,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.forum_outlined,
                      size: 15, color: Color(0xFFD4AF37)),
                  label: const Text(
                    "CHAPERONED PRE-SCREENING CHAT",
                    style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (isApproved) ...[
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RevealDossierScreen(
                          introId: req.id,
                          viewerUid: currentCandidateUid,
                          viewerAlias: currentCandidateAlias,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_open_outlined, size: 18),
                  label: const Text(
                    "VIEW UNVEILED CONTACT DOSSIER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IntroState state) {
    Color bg = Colors.white12;
    Color fg = Colors.white70;

    switch (state) {
      case IntroState.requested:
        bg = Colors.amber.withOpacity(0.2);
        fg = Colors.amber;
        break;
      case IntroState.recipientAccepted:
        bg = Colors.blue.withOpacity(0.2);
        fg = Colors.lightBlueAccent;
        break;
      case IntroState.recipientRejected:
      case IntroState.gatekeeperRejected:
        bg = Colors.red.withOpacity(0.2);
        fg = Colors.redAccent;
        break;
      case IntroState.gatekeeperApproved:
        bg = Colors.green.withOpacity(0.2);
        fg = const Color(0xFF34D399);
        break;
      case IntroState.interviewsInProgress:
        bg = Colors.purple.withOpacity(0.2);
        fg = Colors.purpleAccent;
        break;
      case IntroState.canceledByInitiator:
        bg = Colors.white10;
        fg = Colors.white38;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        state.name.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}