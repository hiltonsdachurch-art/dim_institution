import 'package:flutter/material.dart';
import '../services/unveil_service.dart';
import '../widgets/forensic_watermark_overlay.dart';
import 'outcome_survey_screen.dart';

class RevealDossierScreen extends StatelessWidget {
  final String introId;
  final String viewerUid;
  final String viewerAlias;

  const RevealDossierScreen({
    super.key,
    required this.introId,
    required this.viewerUid,
    required this.viewerAlias,
  });

  @override
  Widget build(BuildContext context) {
    final UnveilService unveilService = UnveilService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "UNVEILED CONTACT DOSSIER",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: ForensicWatermarkOverlay(
        viewerIdentifier: viewerAlias,
        viewerUid: viewerUid,
        child: FutureBuilder<RevealedContactDossier>(
          future: unveilService.fetchUnlockedDossier(
            introId: introId,
            currentViewerUid: viewerUid,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
            }

            if (snapshot.hasError) {
              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gpp_bad_outlined, color: Colors.redAccent, size: 48),
                      const SizedBox(height: 14),
                      const Text(
                        "Access Restricted",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString().replaceAll("Exception: ", ""),
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final dossier = snapshot.data!;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.verified, color: Color(0xFF34D399), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  "GATEKEEPER VERIFIED",
                                  style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Score: ${dossier.compositeMaturityScore.toStringAsFixed(1)}/10",
                            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Text(
                        dossier.legalFullName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Alias: ${dossier.counterpartAlias}",
                        style: const TextStyle(fontSize: 13, color: Colors.white54),
                      ),
                      const SizedBox(height: 20),

                      // Contact Details
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            _buildContactRow(Icons.email_outlined, "Verified Email", dossier.verifiedEmail),
                            const Divider(color: Colors.white12, height: 20),
                            _buildContactRow(Icons.phone_outlined, "Direct Telephone", dossier.verifiedPhone),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gatekeeper Endorsement Notes
                      const Text(
                        "Gatekeeper Endorsement",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.04)),
                        ),
                        child: Text(
                          "“${dossier.gatekeeperNotes.isNotEmpty ? dossier.gatekeeperNotes : 'Candidate demonstrated exceptional emotional clarity and readiness for an intentional marriage covenant.'}”",
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Post-Meeting Outcome Action
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OutcomeSurveyScreen(
                                  introId: introId,
                                  respondentUid: viewerUid,
                                  respondentAlias: viewerAlias,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review_outlined, size: 18),
                          label: const Text(
                            "SUBMIT POST-MEETING OUTCOME SURVEY",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}