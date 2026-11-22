enum IntroState {
  requested,
  recipientRejected,
  recipientAccepted,
  interviewsInProgress,
  gatekeeperRejected,
  gatekeeperApproved,
  canceledByInitiator,
}

class CompetencyScorecard {
  final double emotionalMaturity;
  final double communicationClarity;
  final double commitmentReadiness;
  final String mbtiAssessment;
  final String gatekeeperNotes;
  final DateTime evaluatedAt;

  CompetencyScorecard({
    required this.emotionalMaturity,
    required this.communicationClarity,
    required this.commitmentReadiness,
    required this.mbtiAssessment,
    required this.gatekeeperNotes,
    required this.evaluatedAt,
  });

  double get compositeScore =>
      (emotionalMaturity + communicationClarity + commitmentReadiness) / 3.0;

  Map<String, dynamic> toMap() {
    return {
      'emotionalMaturity': emotionalMaturity,
      'communicationClarity': communicationClarity,
      'commitmentReadiness': commitmentReadiness,
      'compositeScore': compositeScore,
      'mbtiAssessment': mbtiAssessment,
      'gatekeeperNotes': gatekeeperNotes,
      'evaluatedAt': evaluatedAt.toIso8601String(),
    };
  }

  factory CompetencyScorecard.fromMap(Map<String, dynamic> map) {
    return CompetencyScorecard(
      emotionalMaturity: (map['emotionalMaturity'] as num?)?.toDouble() ?? 5.0,
      communicationClarity: (map['communicationClarity'] as num?)?.toDouble() ?? 5.0,
      commitmentReadiness: (map['commitmentReadiness'] as num?)?.toDouble() ?? 5.0,
      mbtiAssessment: map['mbtiAssessment'] ?? 'Pending Assessment',
      gatekeeperNotes: map['gatekeeperNotes'] ?? '',
      evaluatedAt: DateTime.tryParse(map['evaluatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class IntroductionRequest {
  final String id;
  final String initiatorUid;
  final String initiatorAlias;
  final String recipientUid;
  final String recipientAlias;
  final IntroState state;
  final CompetencyScorecard? candidateAScorecard;
  final CompetencyScorecard? candidateBScorecard;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  IntroductionRequest({
    required this.id,
    required this.initiatorUid,
    required this.initiatorAlias,
    required this.recipientUid,
    required this.recipientAlias,
    required this.state,
    this.candidateAScorecard,
    this.candidateBScorecard,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'initiatorUid': initiatorUid,
      'initiatorAlias': initiatorAlias,
      'recipientUid': recipientUid,
      'recipientAlias': recipientAlias,
      'state': state.name,
      'candidateAScorecard': candidateAScorecard?.toMap(),
      'candidateBScorecard': candidateBScorecard?.toMap(),
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory IntroductionRequest.fromMap(Map<String, dynamic> map, String docId) {
    return IntroductionRequest(
      id: docId,
      initiatorUid: map['initiatorUid'] ?? '',
      initiatorAlias: map['initiatorAlias'] ?? 'Anonymous Initiator',
      recipientUid: map['recipientUid'] ?? '',
      recipientAlias: map['recipientAlias'] ?? 'Anonymous Recipient',
      state: IntroState.values.firstWhere(
        (e) => e.name == map['state'],
        orElse: () => IntroState.requested,
      ),
      candidateAScorecard: map['candidateAScorecard'] != null
          ? CompetencyScorecard.fromMap(map['candidateAScorecard'] as Map<String, dynamic>)
          : null,
      candidateBScorecard: map['candidateBScorecard'] != null
          ? CompetencyScorecard.fromMap(map['candidateBScorecard'] as Map<String, dynamic>)
          : null,
      rejectionReason: map['rejectionReason'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}