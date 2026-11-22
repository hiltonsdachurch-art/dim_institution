enum MeetingOutcome {
  succeeded,
  failed,
}

enum ShepherdStatus {
  inactive,
  activePreMarital,
  marriageCovenant,
}

class OutcomeSurvey {
  final String id;
  final String introId;
  final String respondentUid;
  final String respondentAlias;
  final MeetingOutcome outcome;
  final String primaryReason; // e.g. "Misaligned Financial Vision", "Conversational Imbalance"
  final String qualitativeNotes;
  final DateTime submittedAt;

  OutcomeSurvey({
    required this.id,
    required this.introId,
    required this.respondentUid,
    required this.respondentAlias,
    required this.outcome,
    required this.primaryReason,
    required this.qualitativeNotes,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'introId': introId,
      'respondentUid': respondentUid,
      'respondentAlias': respondentAlias,
      'outcome': outcome.name,
      'primaryReason': primaryReason,
      'qualitativeNotes': qualitativeNotes,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory OutcomeSurvey.fromMap(Map<String, dynamic> map, String docId) {
    return OutcomeSurvey(
      id: docId,
      introId: map['introId'] ?? '',
      respondentUid: map['respondentUid'] ?? '',
      respondentAlias: map['respondentAlias'] ?? 'Anonymous',
      outcome: MeetingOutcome.values.firstWhere(
        (e) => e.name == map['outcome'],
        orElse: () => MeetingOutcome.failed,
      ),
      primaryReason: map['primaryReason'] ?? 'General Incompatibility',
      qualitativeNotes: map['qualitativeNotes'] ?? '',
      submittedAt: DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class BehavioralAlert {
  final String alertType;
  final String severity; // LOW, MEDIUM, CRITICAL
  final String description;
  final String coachingRecommendation;
  final DateTime triggeredAt;

  BehavioralAlert({
    required this.alertType,
    required this.severity,
    required this.description,
    required this.coachingRecommendation,
    required this.triggeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'alertType': alertType,
      'severity': severity,
      'description': description,
      'coachingRecommendation': coachingRecommendation,
      'triggeredAt': triggeredAt.toIso8601String(),
    };
  }

  factory BehavioralAlert.fromMap(Map<String, dynamic> map) {
    return BehavioralAlert(
      alertType: map['alertType'] ?? 'GENERAL_OBSERVATION',
      severity: map['severity'] ?? 'LOW',
      description: map['description'] ?? '',
      coachingRecommendation: map['coachingRecommendation'] ?? '',
      triggeredAt: DateTime.tryParse(map['triggeredAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class UserCaseFile {
  final String userId;
  final String alias;
  final int totalIntroductions;
  final int totalInterviewsPassed;
  final int totalFailedOutcomes;
  final int totalSuccessfulMatches;
  final List<BehavioralAlert> activeAlerts;
  final ShepherdStatus shepherdStatus;
  final List<String> shepherdCheckInNotes;

  UserCaseFile({
    required this.userId,
    required this.alias,
    required this.totalIntroductions,
    required this.totalInterviewsPassed,
    required this.totalFailedOutcomes,
    required this.totalSuccessfulMatches,
    required this.activeAlerts,
    required this.shepherdStatus,
    required this.shepherdCheckInNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'alias': alias,
      'totalIntroductions': totalIntroductions,
      'totalInterviewsPassed': totalInterviewsPassed,
      'totalFailedOutcomes': totalFailedOutcomes,
      'totalSuccessfulMatches': totalSuccessfulMatches,
      'activeAlerts': activeAlerts.map((a) => a.toMap()).toList(),
      'shepherdStatus': shepherdStatus.name,
      'shepherdCheckInNotes': shepherdCheckInNotes,
    };
  }

  factory UserCaseFile.fromMap(Map<String, dynamic> map) {
    return UserCaseFile(
      userId: map['userId'] ?? '',
      alias: map['alias'] ?? 'Candidate',
      totalIntroductions: map['totalIntroductions'] ?? 0,
      totalInterviewsPassed: map['totalInterviewsPassed'] ?? 0,
      totalFailedOutcomes: map['totalFailedOutcomes'] ?? 0,
      totalSuccessfulMatches: map['totalSuccessfulMatches'] ?? 0,
      activeAlerts: (map['activeAlerts'] as List<dynamic>?)
              ?.map((item) => BehavioralAlert.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      shepherdStatus: ShepherdStatus.values.firstWhere(
        (e) => e.name == map['shepherdStatus'],
        orElse: () => ShepherdStatus.inactive,
      ),
      shepherdCheckInNotes: List<String>.from(map['shepherdCheckInNotes'] ?? []),
    );
  }
}