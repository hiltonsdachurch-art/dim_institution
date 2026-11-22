enum CourtshipStage {
  courtshipDiscovery,
  intentionalBetrothal,
  preMaritalPreparation,
  holyMatrimonyMerged,
}

enum DimMembershipTier {
  shepherdedFamilyMember,
  independentGraduated,
}

class FamilyProfile {
  final String id;
  final String familyName;
  final String spouseAUid;
  final String spouseAName;
  final String spouseAMbti;
  final Map<String, int> spouseAScores;
  final String spouseAGender;

  final String spouseBUid;
  final String spouseBName;
  final String spouseBMbti;
  final Map<String, int> spouseBScores;
  final String spouseBGender;

  final DateTime weddingDate;
  final String familyVisionStatement;
  final CourtshipStage courtshipStage;
  final DimMembershipTier membershipTier;
  final List<String> familyMilestones;
  final List<String> shepherdCounselNotes;
  final DateTime createdAt;

  FamilyProfile({
    required this.id,
    required this.familyName,
    required this.spouseAUid,
    required this.spouseAName,
    required this.spouseAMbti,
    required this.spouseAScores,
    required this.spouseAGender,
    required this.spouseBUid,
    required this.spouseBName,
    required this.spouseBMbti,
    required this.spouseBScores,
    required this.spouseBGender,
    required this.weddingDate,
    required this.familyVisionStatement,
    required this.courtshipStage,
    required this.membershipTier,
    required this.familyMilestones,
    required this.shepherdCounselNotes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyName': familyName,
      'spouseAUid': spouseAUid,
      'spouseAName': spouseAName,
      'spouseAMbti': spouseAMbti,
      'spouseAScores': spouseAScores,
      'spouseAGender': spouseAGender,
      'spouseBUid': spouseBUid,
      'spouseBName': spouseBName,
      'spouseBMbti': spouseBMbti,
      'spouseBScores': spouseBScores,
      'spouseBGender': spouseBGender,
      'weddingDate': weddingDate.toIso8601String(),
      'familyVisionStatement': familyVisionStatement,
      'courtshipStage': courtshipStage.name,
      'membershipTier': membershipTier.name,
      'familyMilestones': familyMilestones,
      'shepherdCounselNotes': shepherdCounselNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyProfile.fromMap(Map<String, dynamic> map, String docId) {
    return FamilyProfile(
      id: docId,
      familyName: map['familyName'] ?? 'Covenant Family',
      spouseAUid: map['spouseAUid'] ?? '',
      spouseAName: map['spouseAName'] ?? 'Spouse A',
      spouseAMbti: map['spouseAMbti'] ?? 'INTJ',
      spouseAScores: Map<String, int>.from(map['spouseAScores'] ?? {}),
      spouseAGender: map['spouseAGender'] ?? 'Male',
      spouseBUid: map['spouseBUid'] ?? '',
      spouseBName: map['spouseBName'] ?? 'Spouse B',
      spouseBMbti: map['spouseBMbti'] ?? 'ENFJ',
      spouseBScores: Map<String, int>.from(map['spouseBScores'] ?? {}),
      spouseBGender: map['spouseBGender'] ?? 'Female',
      weddingDate: DateTime.tryParse(map['weddingDate'] ?? '') ?? DateTime.now(),
      familyVisionStatement: map['familyVisionStatement'] ?? 'Building an intentional, peaceful home.',
      courtshipStage: CourtshipStage.values.firstWhere(
        (e) => e.name == map['courtshipStage'],
        orElse: () => CourtshipStage.holyMatrimonyMerged,
      ),
      membershipTier: DimMembershipTier.values.firstWhere(
        (e) => e.name == map['membershipTier'],
        orElse: () => DimMembershipTier.shepherdedFamilyMember,
      ),
      familyMilestones: List<String>.from(map['familyMilestones'] ?? []),
      shepherdCounselNotes: List<String>.from(map['shepherdCounselNotes'] ?? []),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}