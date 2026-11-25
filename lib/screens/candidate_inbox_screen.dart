import 'package:flutter/material.dart';
import '../models/introduction_model.dart';
import '../models/direct_chat_model.dart';
import '../models/payment_model.dart';
import '../services/introduction_service.dart';
import '../services/direct_chat_service.dart';
import '../services/sound_service.dart';
import 'reveal_dossier_screen.dart';
import 'chaperoned_chat_screen.dart';
import 'direct_chat_screen.dart';
import 'payment_checkout_screen.dart';

class CandidateInboxScreen extends StatelessWidget {
  final String currentCandidateUid;
  final String currentCandidateAlias;

  const CandidateInboxScreen({
    super.key,
    required this.currentCandidateUid,
    required this.currentCandidateAlias,
  });

  void _openTier2PaymentGate(BuildContext context, IntroductionRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentCheckoutScreen(
        tier: PaymentTier.tier2GatekeeperScreening,
        referenceId: req.id,
        payerUid: currentCandidateUid,
        payerAlias: currentCandidateAlias,
        onPaymentSuccessful: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IntroductionService introService = IntroductionService();
    final DirectChatService directChatService = DirectChatService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "INBOX & CONVERSATIONS ($currentCandidateAlias)",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
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
                Icon(Icons.chat_bubble_outline, color: Color(0xFFD4AF37), size: 18),
                SizedBox(width: 8),
                Text(
                  "DIRECT 1-ON-1 INBOXES (DISCOVERY CHATS)",
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<DirectChatThread>>(
              stream: directChatService.getUserDirectThreadsStream(currentCandidateUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }

                final threads = snapshot.data ?? [];
                if (threads.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text("No direct chats started yet. Scroll down Discovery to message a candidate.", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                  );
                }

                return Column(
                  children: threads.map((thread) {
                    final counterpartAlias = thread.getOtherAlias(currentCandidateUid);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0F172A),
                          child: const Icon(Icons.person, color: Color(0xFFD4AF37), size: 18),
                        ),
                        title: Text(counterpartAlias, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(thread.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFD4AF37)),
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

            // SECTION 2: FORMAL CURATED MATCH REQUESTS (TIER 2 GATED)
            Row(
              children: const [
                Icon(Icons.handshake_outlined, color: Color(0xFFD4AF37), size: 18),
                SizedBox(width: 8),
                Text(
                  "FORMAL GATEKEEPER MATCH REQUESTS (TIER 2)",
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<IntroductionRequest>>(
              stream: introService.getCandidateInboxStream(currentCandidateUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }

                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                    child: const Center(
                      child: Text("No formal introduction requests received.", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ),
                  );
                }

                return Column(
                  children: requests.map((req) => _buildRequestCard(context, req, introService)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, IntroductionRequest req, IntroductionService service) {
    final bool isActionable = req.state == IntroState.requested;
    final bool isApproved = req.state == IntroState.gatekeeperApproved;
    final bool needsTier2Payment = req.state == IntroState.recipientAccepted && !req.tier2Paid;
    final bool hasChatAccess = req.state == IntroState.recipientAccepted ||
        req.state == IntroState.interviewsInProgress ||
        req.state == IntroState.gatekeeperApproved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isApproved ? const Color(0xFFD4AF37).withOpacity(0.4) : Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Formal Match: ${req.initiatorAlias}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              _buildStatusBadge(req.state, req.tier2Paid),
            ],
          ),
          const SizedBox(height: 8),
          const Text("This candidate has reviewed your values and formally requested a curated introduction.", style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4)),
          const SizedBox(height: 16),

          // TIER 2 PAYMENT REQUIRED PROMPT (R700 ZAR)
          if (needsTier2Payment) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("TIER 2 VERIFICATION FEE: R700 ZAR", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("Pending Settlement", style: TextStyle(color: Colors.amber, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Candidate B accepted! To book the two private Gatekeeper screening interviews and scorecards, settle the R700 administration fee.",
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openTier2PaymentGate(context, req),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text("SETTLE TIER 2 FEE (R700 ZAR)"),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (isActionable) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await service.respondToIntroduction(introId: req.id, accept: false);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent)),
                    child: const Text("DECLINE"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await service.respondToIntroduction(introId: req.id, accept: true);
                      await SoundService.playNotificationChime();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
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
                  icon: const Icon(Icons.forum_outlined, size: 15, color: Color(0xFFD4AF37)),
                  label: const Text("CHAPERONED PRE-SCREENING CHAT", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
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
                  label: const Text("VIEW UNVEILED CONTACT DOSSIER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(IntroState state, bool tier2Paid) {
    Color bg = Colors.white12;
    Color fg = Colors.white70;
    String label = state.name.toUpperCase();

    if (state == IntroState.recipientAccepted && !tier2Paid) {
      bg = Colors.amber.withOpacity(0.2);
      fg = Colors.amber;
      label = "AWAITING R700 FEE";
    } else if (state == IntroState.interviewsInProgress || tier2Paid) {
      bg = Colors.purple.withOpacity(0.2);
      fg = Colors.purpleAccent;
      label = "R700 PAID • IN SCREENING";
    } else if (state == IntroState.gatekeeperApproved) {
      bg = Colors.green.withOpacity(0.2);
      fg = const Color(0xFF34D399);
      label = "VERIFIED & UNLOCKED";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}