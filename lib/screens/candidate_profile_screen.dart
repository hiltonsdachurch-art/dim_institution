import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_model.dart';
import '../models/family_model.dart';
import '../services/mbti_knowledge_service.dart';
import '../services/family_service.dart';
import '../services/sound_service.dart';
import 'family_dashboard_screen.dart';

class CandidateProfileScreen extends StatefulWidget {
  final String currentUid;
  final String currentAlias;

  const CandidateProfileScreen({
    super.key,
    required this.currentUid,
    required this.currentAlias,
  });

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FamilyService _familyService = FamilyService();

  Future<void> _uploadMissingCredentials() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      await _db.collection('user_profiles').doc(widget.currentUid).update({
        'hasUploadedId': true,
        'hasUploadedFacePhoto': true,
        'kycStatus': KycStatus.verified.name,
      });

      await SoundService.playCelebrationChime();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Credentials uploaded! Introduction requests are now unlocked."),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  void _showMergeFamilyDialog(BuildContext context, String familyId) {
    final nameController = TextEditingController();
    final visionController = TextEditingController();
    DimMembershipTier tier = DimMembershipTier.shepherdedFamilyMember;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.church_outlined, color: Color(0xFFD4AF37), size: 26),
              SizedBox(width: 10),
              Text("Solemnize into One Family", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Holy Matrimony Merge: Your individual candidate profiles will now merge into a single permanent Family Profile.",
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Official Family Name (e.g. The Vance Household)",
                    filled: true,
                    fillColor: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: visionController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: "Joint Marriage Covenant Vision",
                    filled: true,
                    fillColor: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                const Text("Choose Your Shepherd Covenant Relationship:", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 6),
                RadioListTile<DimMembershipTier>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Retain DIM Shepherding Benefits", style: TextStyle(color: Colors.white, fontSize: 12)),
                  value: DimMembershipTier.shepherdedFamilyMember,
                  groupValue: tier,
                  activeColor: const Color(0xFFD4AF37),
                  onChanged: (v) => setModalState(() => tier = v!),
                ),
                RadioListTile<DimMembershipTier>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Graduate Independently (Go Alone)", style: TextStyle(color: Colors.white, fontSize: 12)),
                  value: DimMembershipTier.independentGraduated,
                  groupValue: tier,
                  activeColor: const Color(0xFFD4AF37),
                  onChanged: (v) => setModalState(() => tier = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  await _familyService.mergeCandidatesIntoOneFamily(
                    familyId: familyId,
                    officialFamilyName: nameController.text.trim(),
                    weddingDate: DateTime.now(),
                    jointFamilyVision: visionController.text.trim().isNotEmpty ? visionController.text.trim() : "Building an honorable covenant family.",
                    tierChoice: tier,
                  );
                  await SoundService.playCelebrationChime();
                  if (!context.mounted) return;
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FamilyDashboardScreen(familyId: familyId)));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
              child: const Text("MERGE INTO ONE FAMILY"),
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
        title: const Text("MY COVENANT PROFILE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('user_profiles').doc(widget.currentUid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Profile not found.", style: TextStyle(color: Colors.white54)));
          }

          final profile = CandidateProfile.fromMap(data);
          final insight = MbtiKnowledgeService.getInsight(profile.mbtiType);
          final scores = profile.personalityScores;
          final String? activeFamilyId = data['activeFamilyId'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LIVE FAMILY PROGRESSION STAGES (If candidates have agreed to meet)
                    if (activeFamilyId != null) ...[
                      StreamBuilder<FamilyProfile?>(
                        stream: _familyService.getFamilyStream(activeFamilyId),
                        builder: (ctx, famSnap) {
                          final family = famSnap.data;
                          if (family == null) return const SizedBox();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("PATHWAY TO ONE FAMILY (LIVE PROGRESS)", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                      child: Text(family.courtshipStage.name.toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Progress Bar
                                _buildStageSteps(family.courtshipStage),
                                const SizedBox(height: 16),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showMergeFamilyDialog(context, family.id),
                                    icon: const Icon(Icons.favorite, size: 16),
                                    label: const Text("SOLEMNIZE & MERGE INTO ONE FAMILY"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD4AF37),
                                      foregroundColor: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],

                    // Candidate Header Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF0F172A),
                            radius: 22,
                            child: Text(profile.mbtiType.substring(0, 2), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.alias, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              Text("${profile.gender} • Age: ${profile.ageBracket}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Missing Credentials Card
                    if (!profile.hasUploadedId || !profile.hasUploadedFacePhoto) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF78350F).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CREDENTIALS INCOMPLETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            const Text("Upload government ID and facial photo to unlock introduction requests.", style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11)),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _uploadMissingCredentials,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                                child: const Text("ATTACH CREDENTIALS NOW"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Personality Intelligence
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("MARRIAGE PERSONALITY INTELLIGENCE (${profile.mbtiType})", style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(insight.archetypeTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text("“${insight.covenantPhilosophy}”", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageSteps(CourtshipStage current) {
    final stages = [
      "1. Courtship",
      "2. Betrothal",
      "3. Pre-Marital",
      "4. Solemnize Merge",
    ];

    int currentIndex = current.index;

    return Row(
      children: stages.asMap().entries.map((entry) {
        final bool isDone = entry.key <= currentIndex;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                color: isDone ? const Color(0xFFD4AF37) : Colors.white12,
              ),
              const SizedBox(height: 4),
              Text(
                entry.value,
                style: TextStyle(
                  color: isDone ? Colors.white : Colors.white38,
                  fontSize: 9,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}