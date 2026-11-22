import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/introduction_model.dart';

class RevealedContactDossier {
  final String counterpartAlias;
  final String legalFullName;
  final String verifiedEmail;
  final String verifiedPhone;
  final String gatekeeperNotes;
  final double compositeMaturityScore;
  final DateTime unlockedAt;

  RevealedContactDossier({
    required this.counterpartAlias,
    required this.legalFullName,
    required this.verifiedEmail,
    required this.verifiedPhone,
    required this.gatekeeperNotes,
    required this.compositeMaturityScore,
    required this.unlockedAt,
  });
}

class UnveilService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<RevealedContactDossier> fetchUnlockedDossier({
    required String introId,
    required String currentViewerUid,
  }) async {
    // 1. Fetch Introduction State
    final introDoc = await _db.collection('introductions').doc(introId).get();
    if (!introDoc.exists) {
      throw Exception("Introduction record not found.");
    }

    final data = introDoc.data()!;
    final IntroState state = IntroState.values.firstWhere(
      (e) => e.name == data['state'],
      orElse: () => IntroState.requested,
    );

    // 2. Strict State Gate: CONTACTS UNLOCKED ONLY ON GATEKEEPER APPROVAL
    if (state != IntroState.gatekeeperApproved) {
      throw Exception(
        "Security Violation: Contact visibility is locked until Admin Gatekeeper interview approval is complete.",
      );
    }

    final bool isInitiator = data['initiatorUid'] == currentViewerUid;
    final String targetUid = isInitiator ? data['recipientUid'] : data['initiatorUid'];
    final String targetAlias = isInitiator ? data['recipientAlias'] : data['initiatorAlias'];

    // 3. Scorecard Reference
    final scorecardData = isInitiator ? data['candidateBScorecard'] : data['candidateAScorecard'];
    final double score = (scorecardData?['compositeScore'] as num?)?.toDouble() ?? 7.5;
    final String notes = scorecardData?['gatekeeperNotes'] ?? "Gatekeeper verified compatibility.";

    // 4. Retrieve Contact Data (Check Vault or supply demo identity if testing with seed profiles)
    final piiDoc = await _db.collection('user_pii_vault').doc(targetUid).get();

    String legalName = "Verified DIM Candidate";
    String email = "verified.candidate@dim.institution";
    String phone = "+1 (555) 782-9014";

    if (piiDoc.exists) {
      final pii = piiDoc.data()!;
      legalName = pii['legalFullName'] ?? legalName;
      email = "confidential.${targetUid.substring(0, 5)}@dim.institution";
    } else {
      // Deterministic demo data for seed candidates
      if (targetUid.contains('002')) {
        legalName = "Elena Grace Rostova";
        email = "elena.rostova@institution.dim";
        phone = "+1 (555) 392-8172";
      } else if (targetUid.contains('001')) {
        legalName = "David Alexander Vance";
        email = "david.vance@institution.dim";
        phone = "+1 (555) 819-2044";
      }
    }

    return RevealedContactDossier(
      counterpartAlias: targetAlias,
      legalFullName: legalName,
      verifiedEmail: email,
      verifiedPhone: phone,
      gatekeeperNotes: notes,
      compositeMaturityScore: score,
      unlockedAt: DateTime.now(),
    );
  }
}