import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/introduction_model.dart';

class IntroductionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Submit request with strict single-request concurrency check
  Future<void> submitIntroductionRequest({
    required String initiatorUid,
    required String initiatorAlias,
    required String recipientUid,
    required String recipientAlias,
  }) async {
    // Check if Candidate A already has an active pending request
    final existingPending = await _db
        .collection('introductions')
        .where('initiatorUid', isEqualTo: initiatorUid)
        .where('state', isEqualTo: IntroState.requested.name)
        .get();

    if (existingPending.docs.isNotEmpty) {
      throw Exception(
        "Intentionality Rule: You already have an active pending introduction request. "
        "DIM restricts members to one pursuit at a time. Cancel your pending request first.",
      );
    }

    final docRef = _db.collection('introductions').doc();
    final request = IntroductionRequest(
      id: docRef.id,
      initiatorUid: initiatorUid,
      initiatorAlias: initiatorAlias,
      recipientUid: recipientUid,
      recipientAlias: recipientAlias,
      state: IntroState.requested,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(request.toMap());
  }

  // 2. Candidate A cancels their request BEFORE Candidate B accepts
  Future<void> cancelIntroductionRequest({
    required String introId,
    required String initiatorUid,
  }) async {
    final docRef = _db.collection('introductions').doc(introId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception("Request record not found.");
    }

    final data = doc.data()!;
    if (data['initiatorUid'] != initiatorUid) {
      throw Exception("Unauthorized: Only the initiator can cancel this request.");
    }

    if (data['state'] != IntroState.requested.name) {
      throw Exception(
        "Cancellation Prohibited: Candidate B has already accepted this introduction. "
        "The Gatekeeper interview pipeline has commenced.",
      );
    }

    await docRef.update({
      'state': IntroState.canceledByInitiator.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // 3. Candidate B responds (Accept or Decline)
  Future<void> respondToIntroduction({
    required String introId,
    required bool accept,
  }) async {
    await _db.collection('introductions').doc(introId).update({
      'state': accept
          ? IntroState.recipientAccepted.name
          : IntroState.recipientRejected.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // 4. Admin Gatekeeper records interview scorecard & makes final decision
  Future<void> recordGatekeeperEvaluation({
    required String introId,
    required CompetencyScorecard scorecardA,
    required CompetencyScorecard scorecardB,
    required bool approve,
    String? rejectionReason,
  }) async {
    await _db.collection('introductions').doc(introId).update({
      'candidateAScorecard': scorecardA.toMap(),
      'candidateBScorecard': scorecardB.toMap(),
      'state': approve
          ? IntroState.gatekeeperApproved.name
          : IntroState.gatekeeperRejected.name,
      'rejectionReason': rejectionReason,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Stream single active pending request for Candidate A
  Stream<IntroductionRequest?> getActivePendingRequestStream(String initiatorUid) {
    return _db
        .collection('introductions')
        .where('initiatorUid', isEqualTo: initiatorUid)
        .where('state', isEqualTo: IntroState.requested.name)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return IntroductionRequest.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    });
  }

  // Stream Candidate B Inbox
  Stream<List<IntroductionRequest>> getCandidateInboxStream(String candidateUid) {
    return _db
        .collection('introductions')
        .where('recipientUid', isEqualTo: candidateUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IntroductionRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Stream all for Admin Gatekeeper
  Stream<List<IntroductionRequest>> getGatekeeperQueueStream() {
    return _db.collection('introductions').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => IntroductionRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}