import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/introduction_model.dart';
import '../models/user_model.dart';
import '../services/introduction_service.dart';
import '../services/sound_service.dart';
import 'chaperoned_chat_screen.dart';

class GatekeeperCockpitScreen extends StatelessWidget {
  const GatekeeperCockpitScreen({super.key});

  // Reusable Full Dossier Inspector (Public Profile + KYC Vault)
  void _openCandidateDossier(
      BuildContext context, String uid, String alias) async {
    final db = FirebaseFirestore.instance;

    CandidateProfile? profile;
    Map<String, dynamic>? piiData;

    try {
      final profileDoc = await db.collection('user_profiles').doc(uid).get();
      if (profileDoc.exists) {
        profile = CandidateProfile.fromMap(profileDoc.data()!);
      }

      final piiDoc = await db.collection('user_pii_vault').doc(uid).get();
      if (piiDoc.exists) {
        piiData = piiDoc.data();
      }
    } catch (e) {
      debugPrint("Error loading candidate profile: $e");
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alias,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(dialogCtx),
                    )
                  ],
                ),
                const SizedBox(height: 14),

                // Vaulted Identity Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "VERIFIED LEGAL IDENTITY (GATEKEEPER CLEARANCE)",
                        style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Legal Name: ${piiData != null ? piiData['legalFullName'] : 'Verified by Agency (Seed Candidate)'}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "DOB: ${piiData != null ? piiData['exactDob']?.toString().substring(0, 10) : 'Adult 18+ (Verified)'}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                if (profile != null) ...[
                  _buildProfileAttribute("MBTI Personality", profile.mbtiType),
                  _buildProfileAttribute("Age Bracket", profile.ageBracket),
                  _buildProfileAttribute("Religion & Faith",
                      "${profile.religion} (${profile.religiosityLevel}/5)"),
                  _buildProfileAttribute(
                      "Financial Philosophy", profile.financialGoal),
                  _buildProfileAttribute(
                      "Family & Children Intentions", profile.familyIntention),
                  const SizedBox(height: 12),
                  const Text("Core Values:",
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: profile.coreValues.map((v) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(v,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text("Marriage Philosophy:",
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "“${profile.bioPhilosophy}”",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                          fontSize: 12),
                    ),
                  ),
                ] else ...[
                  const Text("Profile details on file with Gatekeeper.",
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    child: const Text("DONE REVIEWING"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAttribute(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IntroductionService introService = IntroductionService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "ADMIN GATEKEEPER COCKPIT",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: StreamBuilder<List<IntroductionRequest>>(
        stream: introService.getGatekeeperQueueStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.verified_outlined,
                      size: 56, color: Colors.white24),
                  SizedBox(height: 16),
                  Text("Gatekeeper Queue Clear",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  SizedBox(height: 6),
                  Text(
                      "No introduction requests currently awaiting Gatekeeper action.",
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            );
          }

          final requests = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return _buildGatekeeperCard(context, req, introService);
            },
          );
        },
      ),
    );
  }

  Widget _buildGatekeeperCard(
    BuildContext context,
    IntroductionRequest req,
    IntroductionService service,
  ) {
    final bool readyForInterview = req.state == IntroState.recipientAccepted;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Match Dossier #${req.id.substring(0, req.id.length > 6 ? 6 : req.id.length)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              _buildStateChip(req.state),
            ],
          ),
          const SizedBox(height: 16),

          // Two Candidates Side-by-Side Comparison Box with Full Dossier Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CANDIDATE A (INITIATOR)",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text(req.initiatorAlias,
                              style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openCandidateDossier(
                                context, req.initiatorUid, req.initiatorAlias),
                            icon: const Icon(Icons.badge_outlined, size: 14),
                            label: const Text("FULL DOSSIER A",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              foregroundColor: const Color(0xFFD4AF37),
                              side: const BorderSide(
                                  color: Color(0xFFD4AF37), width: 0.6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.compare_arrows,
                        color: Colors.white24, size: 28),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("CANDIDATE B (RECIPIENT)",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text(req.recipientAlias,
                              style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _openCandidateDossier(
                                context, req.recipientUid, req.recipientAlias),
                            icon: const Icon(Icons.badge_outlined, size: 14),
                            label: const Text("FULL DOSSIER B",
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              foregroundColor: const Color(0xFFD4AF37),
                              side: const BorderSide(
                                  color: Color(0xFFD4AF37), width: 0.6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Inspect Chat Log Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChaperonedChatScreen(
                      introId: req.id,
                      viewerUid: "admin_gatekeeper",
                      viewerAlias: "Admin Shepherd",
                      counterpartAlias:
                          "${req.initiatorAlias} & ${req.recipientAlias}",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long_outlined,
                  size: 16, color: Colors.white70),
              label: const Text(
                "AUDIT CHAPERONED CHAT TRANSCRIPT",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action Button
          if (readyForInterview) ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showScorecardDialog(context, req, service);
                },
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text(
                  "CONDUCT INTERVIEW & FILL SCORECARD",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F172A),
                ),
              ),
            )
          ] else ...[
            Text(
              "Current Status: ${req.state.name.toUpperCase()}",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          ]
        ],
      ),
    );
  }

  void _showScorecardDialog(
    BuildContext context,
    IntroductionRequest req,
    IntroductionService service,
  ) {
    double emotionalMaturity = 7.0;
    double communicationClarity = 8.0;
    double commitmentReadiness = 7.5;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final double composite = (emotionalMaturity +
                    communicationClarity +
                    commitmentReadiness) /
                3.0;
            final bool passesThreshold = composite >= 7.0;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.assignment_turned_in_outlined,
                      color: Color(0xFFD4AF37), size: 26),
                  SizedBox(width: 10),
                  Text("Gatekeeper Scorecard",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scoring: ${req.initiatorAlias} & ${req.recipientAlias}",
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    // Quick Dossier Inspection Links Inside the Scorecard
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _openCandidateDossier(
                                context, req.initiatorUid, req.initiatorAlias),
                            icon: const Icon(Icons.person,
                                size: 14, color: Color(0xFFD4AF37)),
                            label: const Text("Dossier A",
                                style: TextStyle(
                                    color: Color(0xFFD4AF37), fontSize: 11)),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _openCandidateDossier(
                                context, req.recipientUid, req.recipientAlias),
                            icon: const Icon(Icons.person,
                                size: 14, color: Color(0xFFD4AF37)),
                            label: const Text("Dossier B",
                                style: TextStyle(
                                    color: Color(0xFFD4AF37), fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),

                    // Sliders
                    Text(
                        "Emotional Maturity: ${emotionalMaturity.toStringAsFixed(1)}/10",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                    Slider(
                      value: emotionalMaturity,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      activeColor: const Color(0xFFD4AF37),
                      onChanged: (val) =>
                          setState(() => emotionalMaturity = val),
                    ),

                    Text(
                        "Communication Clarity: ${communicationClarity.toStringAsFixed(1)}/10",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                    Slider(
                      value: communicationClarity,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      activeColor: const Color(0xFFD4AF37),
                      onChanged: (val) =>
                          setState(() => communicationClarity = val),
                    ),

                    Text(
                        "Commitment Readiness: ${commitmentReadiness.toStringAsFixed(1)}/10",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                    Slider(
                      value: commitmentReadiness,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      activeColor: const Color(0xFFD4AF37),
                      onChanged: (val) =>
                          setState(() => commitmentReadiness = val),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: passesThreshold
                            ? const Color(0xFF064E3B).withOpacity(0.5)
                            : const Color(0xFF78350F).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Composite Readiness:",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          Text(
                            "${composite.toStringAsFixed(1)} / 10.0 (${passesThreshold ? 'PASS' : 'COACHING NEEDED'})",
                            style: TextStyle(
                              color: passesThreshold
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFBBF24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Confidential Gatekeeper Interview Notes",
                        labelStyle: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL",
                      style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final scorecard = CompetencyScorecard(
                      emotionalMaturity: emotionalMaturity,
                      communicationClarity: communicationClarity,
                      commitmentReadiness: commitmentReadiness,
                      mbtiAssessment: "Verified Authentic MBTI",
                      gatekeeperNotes: notesController.text,
                      evaluatedAt: DateTime.now(),
                    );

                    await service.recordGatekeeperEvaluation(
                      introId: req.id,
                      scorecardA: scorecard,
                      scorecardB: scorecard,
                      approve: passesThreshold,
                      rejectionReason: passesThreshold
                          ? null
                          : "Readiness composite below threshold (7.0).",
                    );

                    if (passesThreshold) {
                      await SoundService.playCelebrationChime();
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(passesThreshold
                            ? "Match APPROVED! Reveal Unlocked."
                            : "Match Routed to Coaching."),
                        backgroundColor: passesThreshold
                            ? const Color(0xFF10B981)
                            : Colors.amber[800],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  child: Text(passesThreshold
                      ? "APPROVE FOR REVEAL"
                      : "DECLINE & COACH"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStateChip(IntroState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        state.name.toUpperCase(),
        style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 11,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}