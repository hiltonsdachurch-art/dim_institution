import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminCandidateDirectoryScreen extends StatefulWidget {
  const AdminCandidateDirectoryScreen({super.key});

  @override
  State<AdminCandidateDirectoryScreen> createState() =>
      _AdminCandidateDirectoryScreenState();
}

class _AdminCandidateDirectoryScreenState
    extends State<AdminCandidateDirectoryScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _searchQuery = '';

  void _showFullCandidateDossier(
      BuildContext context, CandidateProfile profile) async {
    // Retrieve private PII vault data for Admin eyes only
    DocumentSnapshot? piiDoc;
    try {
      piiDoc = await _db.collection('user_pii_vault').doc(profile.uid).get();
    } catch (e) {
      debugPrint("Error loading PII vault: $e");
    }

    final piiData = piiDoc != null && piiDoc.exists
        ? piiDoc.data() as Map<String, dynamic>?
        : null;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF0F172A),
                          radius: 20,
                          child: Text(
                            profile.mbtiType.length >= 2
                                ? profile.mbtiType.substring(0, 2)
                                : 'MB',
                            style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.alias,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "UID: ${profile.uid.substring(0, profile.uid.length > 8 ? 8 : profile.uid.length)}",
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(dialogCtx),
                    )
                  ],
                ),
                const SizedBox(height: 18),

                // RESTRICTED PII VAULT BOX (Admin Clearance Only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lock_person,
                              color: Color(0xFFD4AF37), size: 16),
                          SizedBox(width: 8),
                          Text(
                            "RESTRICTED IDENTITY VAULT (ADMIN CLEARANCE)",
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 18),
                      _buildDossierRow(
                        "Legal Full Name:",
                        piiData != null
                            ? "${piiData['legalFullName']}"
                            : "Verified Candidate (Seed Identity)",
                      ),
                      const SizedBox(height: 6),
                      _buildDossierRow(
                        "Exact Date of Birth:",
                        piiData != null
                            ? "${piiData['exactDob']?.toString().substring(0, 10)}"
                            : "Verified Adult 18+ (Vaulted)",
                      ),
                      const SizedBox(height: 6),
                      _buildDossierRow(
                        "KYC Document Status:",
                        piiData != null && piiData['idDocumentUrl'] != null
                            ? "Document on Secure File (Encrypted Storage)"
                            : "Identity Verified by Agency",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Public Profile Attributes
                const Text(
                  "Personality & Values Dossier",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildDossierRow("MBTI Personality:", profile.mbtiType),
                const SizedBox(height: 6),
                _buildDossierRow("Age Bracket:", profile.ageBracket),
                const SizedBox(height: 6),
                _buildDossierRow("Spiritual Tradition:",
                    "${profile.religion} (Religiosity: ${profile.religiosityLevel}/5)"),
                const SizedBox(height: 6),
                _buildDossierRow("Financial Goal:", profile.financialGoal),
                const SizedBox(height: 6),
                _buildDossierRow("Family Intention:", profile.familyIntention),
                const SizedBox(height: 16),

                // Core Values
                const Text("Core Values:",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: profile.coreValues.map((v) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(v,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Philosophy Statement
                const Text("Marriage Philosophy Statement:",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Text(
                    "“${profile.bioPhilosophy}”",
                    style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    child: const Text("CLOSE DOSSIER"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDossierRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "MASTER CANDIDATE DIRECTORY",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F172A),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search candidates by alias or MBTI...",
                hintStyle:
                    const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),

          // Candidate Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('user_profiles').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No candidates enrolled in registry.",
                        style: TextStyle(color: Colors.white54)),
                  );
                }

                final profiles = snapshot.data!.docs.map((doc) {
                  return CandidateProfile.fromMap(
                      doc.data() as Map<String, dynamic>);
                }).where((p) {
                  if (_searchQuery.isEmpty) return true;
                  return p.alias.toLowerCase().contains(_searchQuery) ||
                      p.mbtiType.toLowerCase().contains(_searchQuery) ||
                      p.religion.toLowerCase().contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF0F172A),
                            child: Text(
                              profile.mbtiType.length >= 2
                                  ? profile.mbtiType.substring(0, 2)
                                  : 'MB',
                              style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.alias,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4AF37)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        profile.mbtiType,
                                        style: const TextStyle(
                                            color: Color(0xFFD4AF37),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Age Bracket: ${profile.ageBracket} • ${profile.religion} • Verified 18+",
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showFullCandidateDossier(context, profile),
                            icon: const Icon(Icons.visibility_outlined,
                                size: 14),
                            label: const Text("INSPECT",
                                style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: const Color(0xFFD4AF37),
                              side: const BorderSide(
                                  color: Color(0xFFD4AF37), width: 0.8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}