enum KycStatus {
  unverified,
  pendingVerification,
  verified,
  rejected,
}

enum UserRole {
  candidate,
  mentor,
  admin,
}

class CandidateProfile {
  final String uid;
  final String alias;
  final String gender;
  final String ageBracket;
  final String mbtiType;
  final Map<String, int> personalityScores;
  final String religion;
  final int religiosityLevel;
  final String financialGoal;
  final String familyIntention;
  final List<String> coreValues;
  final String bioPhilosophy;
  final KycStatus kycStatus;
  final UserRole role;
  final bool hasUploadedId;
  final bool hasUploadedFacePhoto;
  final String? facePhotoUrl;
  final bool isOnline;
  final DateTime lastActive;
  final DateTime createdAt;
  final Map<String, dynamic>? pendingProfileUpdates;
  final bool deletionRequested;

  CandidateProfile({
    required this.uid,
    required this.alias,
    required this.gender,
    required this.ageBracket,
    required this.mbtiType,
    required this.personalityScores,
    required this.religion,
    required this.religiosityLevel,
    required this.financialGoal,
    required this.familyIntention,
    required this.coreValues,
    required this.bioPhilosophy,
    required this.kycStatus,
    required this.role,
    this.hasUploadedId = false,
    this.hasUploadedFacePhoto = false,
    this.facePhotoUrl,
    this.isOnline = false,
    required this.lastActive,
    required this.createdAt,
    this.pendingProfileUpdates,
    this.deletionRequested = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'alias': alias,
      'gender': gender,
      'ageBracket': ageBracket,
      'mbtiType': mbtiType,
      'personalityScores': personalityScores,
      'religion': religion,
      'religiosityLevel': religiosityLevel,
      'financialGoal': financialGoal,
      'familyIntention': familyIntention,
      'coreValues': coreValues,
      'bioPhilosophy': bioPhilosophy,
      'kycStatus': kycStatus.name,
      'role': role.name,
      'hasUploadedId': hasUploadedId,
      'hasUploadedFacePhoto': hasUploadedFacePhoto,
      'facePhotoUrl': facePhotoUrl,
      'isOnline': isOnline,
      'lastActive': lastActive.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'pendingProfileUpdates': pendingProfileUpdates,
      'deletionRequested': deletionRequested,
    };
  }

  factory CandidateProfile.fromMap(Map<String, dynamic> map) {
    return CandidateProfile(
      uid: map['uid'] ?? '',
      alias: map['alias'] ?? 'Anonymous Candidate',
      gender: map['gender'] ?? 'Male',
      ageBracket: map['ageBracket'] ?? '25-29',
      mbtiType: map['mbtiType'] ?? 'INTJ',
      personalityScores: Map<String, int>.from(map['personalityScores'] ?? {}),
      religion: map['religion'] ?? 'Traditional',
      religiosityLevel: map['religiosityLevel'] ?? 3,
      financialGoal: map['financialGoal'] ?? 'Balanced Growth',
      familyIntention: map['familyIntention'] ?? 'Open to Children',
      coreValues: List<String>.from(map['coreValues'] ?? ['Commitment', 'Integrity']),
      bioPhilosophy: map['bioPhilosophy'] ?? 'Seeking an intentional marriage covenant.',
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == map['kycStatus'],
        orElse: () => KycStatus.unverified,
      ),
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.candidate,
      ),
      hasUploadedId: map['hasUploadedId'] ?? false,
      hasUploadedFacePhoto: map['hasUploadedFacePhoto'] ?? false,
      facePhotoUrl: map['facePhotoUrl'],
      isOnline: map['isOnline'] ?? false,
      lastActive: DateTime.tryParse(map['lastActive'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      pendingProfileUpdates: map['pendingProfileUpdates'] != null
          ? Map<String, dynamic>.from(map['pendingProfileUpdates'])
          : null,
      deletionRequested: map['deletionRequested'] ?? false,
    );
  }
}

class UserPiiVault {
  final String uid;
  final String legalFullName;
  final DateTime exactDob;
  final String idDocumentUrl;
  final String? facialPhotoUrl;
  final DateTime submittedAt;

  UserPiiVault({
    required this.uid,
    required this.legalFullName,
    required this.exactDob,
    required this.idDocumentUrl,
    this.facialPhotoUrl,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'legalFullName': legalFullName,
      'exactDob': exactDob.toIso8601String(),
      'idDocumentUrl': idDocumentUrl,
      'facialPhotoUrl': facialPhotoUrl,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}