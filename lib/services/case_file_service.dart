import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_file_model.dart';

class CaseFileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Submit Outcome Survey & Trigger Heuristic Evaluation
  Future<void> submitOutcomeSurvey({
    required String introId,
    required String respondentUid,
    required String respondentAlias,
    required MeetingOutcome outcome,
    required String primaryReason,
    required String qualitativeNotes,
  }) async {
    final surveyRef = _db.collection('outcome_surveys').doc();
    final survey = OutcomeSurvey(
      id: surveyRef.id,
      introId: introId,
      respondentUid: respondentUid,
      respondentAlias: respondentAlias,
      outcome: outcome,
      primaryReason: primaryReason,
      qualitativeNotes: qualitativeNotes,
      submittedAt: DateTime.now(),
    );

    await surveyRef.set(survey.toMap());

    // Update Longitudinal Case File & Run Heuristics
    await _updateCaseFileWithHeuristics(
      respondentUid: respondentUid,
      respondentAlias: respondentAlias,
      outcome: outcome,
      primaryReason: primaryReason,
    );
  }

  // 2. The Heuristic Pattern Recognition Algorithm
  Future<void> _updateCaseFileWithHeuristics({
    required String respondentUid,
    required String respondentAlias,
    required MeetingOutcome outcome,
    required String primaryReason,
  }) async {
    final caseFileRef = _db.collection('case_files').doc(respondentUid);
    final doc = await caseFileRef.get();

    UserCaseFile caseFile;
    if (doc.exists) {
      caseFile = UserCaseFile.fromMap(doc.data()!);
    } else {
      caseFile = UserCaseFile(
        userId: respondentUid,
        alias: respondentAlias,
        totalIntroductions: 1,
        totalInterviewsPassed: 1,
        totalFailedOutcomes: 0,
        totalSuccessfulMatches: 0,
        activeAlerts: [],
        shepherdStatus: ShepherdStatus.inactive,
        shepherdCheckInNotes: [],
      );
    }

    int failed = caseFile.totalFailedOutcomes + (outcome == MeetingOutcome.failed ? 1 : 0);
    int passed = caseFile.totalSuccessfulMatches + (outcome == MeetingOutcome.succeeded ? 1 : 0);
    List<BehavioralAlert> alerts = List.from(caseFile.activeAlerts);

    // PATTERN HEURISTIC 1: Post-Meeting Collapse Loop
    // Candidate passes gatekeeper interviews but repeatedly fails unmonitored 1-on-1 meetings
    if (failed >= 2 && passed == 0) {
      alerts.removeWhere((a) => a.alertType == 'POST_MEETING_COLLAPSE');
      alerts.add(
        BehavioralAlert(
          alertType: 'POST_MEETING_COLLAPSE',
          severity: 'CRITICAL',
          description:
              'Candidate consistently passes Admin screening but encounters failure in 1-on-1 unmonitored contexts ($failed failed outcomes).',
          coachingRecommendation:
              'Suspend new introductions. Schedule a private coaching session targeting interpersonal expectations, active listening, and relational authenticity.',
          triggeredAt: DateTime.now(),
        ),
      );
    }

    // PATTERN HEURISTIC 2: Conversational Imbalance Alert
    if (primaryReason.toLowerCase().contains("communication") ||
        primaryReason.toLowerCase().contains("listening")) {
      alerts.removeWhere((a) => a.alertType == 'COMMUNICATION_FRICTION');
      alerts.add(
        BehavioralAlert(
          alertType: 'COMMUNICATION_FRICTION',
          severity: 'MEDIUM',
          description: 'Counterpart reported conversational friction: "$primaryReason".',
          coachingRecommendation:
              'Assign module on emotional responsiveness and bidirectional inquiry.',
          triggeredAt: DateTime.now(),
        ),
      );
    }

    final updated = UserCaseFile(
      userId: respondentUid,
      alias: respondentAlias,
      totalIntroductions: caseFile.totalIntroductions + 1,
      totalInterviewsPassed: caseFile.totalInterviewsPassed,
      totalFailedOutcomes: failed,
      totalSuccessfulMatches: passed,
      activeAlerts: alerts,
      shepherdStatus: caseFile.shepherdStatus,
      shepherdCheckInNotes: caseFile.shepherdCheckInNotes,
    );

    await caseFileRef.set(updated.toMap());
  }

  // Stream single user Case File
  Stream<UserCaseFile?> getCaseFileStream(String userId) {
    return _db.collection('case_files').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserCaseFile.fromMap(doc.data()!);
    });
  }

  // Stream all Case Files for Gatekeeper Cockpit
  Stream<List<UserCaseFile>> getAllCaseFilesStream() {
    return _db.collection('case_files').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserCaseFile.fromMap(doc.data())).toList();
    });
  }

  // Retain Gatekeeper as Marriage Shepherd
  Future<void> updateShepherdStatus({
    required String userId,
    required ShepherdStatus status,
    required String checkInNote,
  }) async {
    final docRef = _db.collection('case_files').doc(userId);
    final doc = await docRef.get();
    if (doc.exists) {
      final current = UserCaseFile.fromMap(doc.data()!);
      final updatedNotes = List<String>.from(current.shepherdCheckInNotes)..add(checkInNote);
      await docRef.update({
        'shepherdStatus': status.name,
        'shepherdCheckInNotes': updatedNotes,
      });
    }
  }
}