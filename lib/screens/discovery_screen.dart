import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/introduction_model.dart';
import '../services/discovery_service.dart';
import '../services/introduction_service.dart';
import '../services/direct_chat_service.dart';
import '../services/sound_service.dart';
import 'direct_chat_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  final String currentCandidateUid;
  final String currentCandidateAlias;

  const DiscoveryScreen({
    super.key,
    required this.currentCandidateUid,
    required this.currentCandidateAlias,
  });

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  final IntroductionService _introService = IntroductionService();
  final DirectChatService _directChatService = DirectChatService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _filterGender = 'ALL';
  String _filterMbti = 'ALL';
  String _filterReligion = 'ALL';
  bool _isSeeding = false;

  final List<String> _genderOptions = ['ALL', 'Male', 'Female'];
  final List<String> _mbtiOptions = ['ALL', 'INTJ', 'INFJ', 'ENFJ', 'ENTJ', 'INFP', 'ENFP', 'ISTJ', 'ISFJ'];
  final List<String> _religionOptions = ['ALL', 'Christian', 'Spiritual', 'Traditional'];

  Future<void> _seedDatabase() async {
    setState(() => _isSeeding = true);
    try {
      await _discoveryService.seedCuratedDemoProfiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Curated Profiles Seeded!"), backgroundColor: Color(0xFF10B981)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _openDirectInbox(CandidateProfile candidate) async {
    final thread = await _directChatService.getOrCreateDirectThread(
      currentUid: widget.currentCandidateUid,
      currentAlias: widget.currentCandidateAlias,
      targetUid: candidate.uid,
      targetAlias: candidate.alias,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DirectChatScreen(
          chatId: thread.id,
          currentUid: widget.currentCandidateUid,
          currentAlias: widget.currentCandidateAlias,
          counterpartAlias: candidate.alias,
        ),
      ),
    );
  }

  void _showIntroductionModal(CandidateProfile candidate, bool currentUserHasId) {
    // 1. Strict Gating Rule: Cannot request without an ID
    if (!currentUserHasId) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.badge_outlined, color: Color(0xFFF59E0B), size: 24),
              SizedBox(width: 10),
              Text("ID Verification Required", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: const Text(
            "Institutional Gate: You skipped ID upload during onboarding. In DIM, you must attach your government ID in the 'My Profile' tab before requesting introductions.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
              child: const Text("I UNDERSTAND"),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Normal Introduction Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.handshake_outlined, color: Color(0xFFD4AF37), size: 26),
            SizedBox(width: 12),
            Text("Request Introduction", style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Candidate: ${candidate.alias} (${candidate.gender})", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
            const SizedBox(height: 8),
            const Text(
              "In DIM, you may only pursue ONE introduction at a time.\n• Candidate reviews your profile.\n• You can cancel anytime before they accept.",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _introService.submitIntroductionRequest(
                  initiatorUid: widget.currentCandidateUid,
                  initiatorAlias: widget.currentCandidateAlias,
                  recipientUid: candidate.uid,
                  recipientAlias: candidate.alias,
                );
                await SoundService.playNotificationChime();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request lodged with ${candidate.alias}."), backgroundColor: const Color(0xFF10B981)));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.amber[800]));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
            child: const Text("LODGE REQUEST"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text("DISCOVERY (${widget.currentCandidateAlias})", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          TextButton.icon(
            onPressed: _isSeeding ? null : _seedDatabase,
            icon: _isSeeding ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37))) : const Icon(Icons.add_moderator_outlined, color: Color(0xFFD4AF37), size: 18),
            label: Text(_isSeeding ? "Seeding..." : "Seed Profiles", style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('user_profiles').doc(widget.currentCandidateUid).snapshots(),
        builder: (context, userSnapshot) {
          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          final bool currentUserHasId = userData?['hasUploadedId'] ?? false;

          return StreamBuilder<IntroductionRequest?>(
            stream: _introService.getActivePendingRequestStream(widget.currentCandidateUid),
            builder: (context, activeSnapshot) {
              final activeRequest = activeSnapshot.data;
              final bool hasPendingRequest = activeRequest != null;

              return Column(
                children: [
                  if (hasPendingRequest)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: const Color(0xFF78350F),
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_top, color: Color(0xFFFBBF24), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("ACTIVE PURSUIT: ${activeRequest.recipientAlias} • One introduction at a time allowed.", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () async {
                              await _introService.cancelIntroductionRequest(introId: activeRequest.id, initiatorUid: widget.currentCandidateUid);
                              await SoundService.playNotificationChime();
                            },
                            style: TextButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
                            child: const Text("CANCEL", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),

                  // Filter Bar with Gender
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: const Color(0xFF0F172A),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildDropdown("Gender", _filterGender, _genderOptions, (v) => setState(() => _filterGender = v!)),
                        _buildDropdown("MBTI", _filterMbti, _mbtiOptions, (v) => setState(() => _filterMbti = v!)),
                        _buildDropdown("Religion", _filterReligion, _religionOptions, (v) => setState(() => _filterReligion = v!)),
                      ],
                    ),
                  ),

                  // Candidate Catalog Stream
                  Expanded(
                    child: StreamBuilder<List<CandidateProfile>>(
                      stream: _discoveryService.getCandidatesStream(selectedMbti: _filterMbti, selectedReligion: _filterReligion),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                        }

                        final candidates = (snapshot.data ?? []).where((c) {
                          if (_filterGender == 'ALL') return true;
                          return c.gender.toLowerCase() == _filterGender.toLowerCase();
                        }).toList();

                        if (candidates.isEmpty) {
                          return const Center(child: Text("No candidates match filters.", style: TextStyle(color: Colors.white54)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(18),
                          itemCount: candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = candidates[index];
                            final bool isSelf = candidate.uid == widget.currentCandidateUid;
                            final bool isPending = hasPendingRequest && activeRequest.recipientUid == candidate.uid;

                            return _buildCandidateCard(
                              candidate: candidate,
                              isSelf: isSelf,
                              hasActivePending: hasPendingRequest,
                              isCurrentPending: isPending,
                              currentUserHasId: currentUserHasId,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.white54, fontSize: 11)),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard({
    required CandidateProfile candidate,
    required bool isSelf,
    required bool hasActivePending,
    required bool isCurrentPending,
    required bool currentUserHasId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCurrentPending ? const Color(0xFFF59E0B) : Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0F172A),
                    child: Text(candidate.mbtiType.substring(0, 2), style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(candidate.alias, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 6),
                          Icon(candidate.gender == 'Male' ? Icons.male : Icons.female, color: const Color(0xFFD4AF37), size: 16),
                        ],
                      ),
                      Text("${candidate.gender} • Age: ${candidate.ageBracket} • ${candidate.isOnline ? 'Online' : 'Offline'}", style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(candidate.mbtiType, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("“${candidate.bioPhilosophy}”", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 16),

          if (!isSelf)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openDirectInbox(candidate),
                    icon: const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFFD4AF37)),
                    label: const Text("1-ON-1 INBOX", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (hasActivePending && !isCurrentPending) ? null : () => _showIntroductionModal(candidate, currentUserHasId),
                    icon: const Icon(Icons.handshake_outlined, size: 14),
                    label: Text(isCurrentPending ? "PENDING" : "REQUEST INTRO", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                  ),
                ),
              ],
            )
          else
            const Center(child: Text("YOUR CANDIDATE DOSSIER", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}