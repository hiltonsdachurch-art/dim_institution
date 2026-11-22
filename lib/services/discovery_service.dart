import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DiscoveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream candidates strictly from public discovery collection (Zero PII queried)
  Stream<List<CandidateProfile>> getCandidatesStream({
    String? selectedMbti,
    String? selectedReligion,
    String? selectedFamilyIntention,
  }) {
    Query query = _db.collection('user_profiles');

    if (selectedMbti != null && selectedMbti != 'ALL') {
      query = query.where('mbtiType', isEqualTo: selectedMbti);
    }
    if (selectedReligion != null && selectedReligion != 'ALL') {
      query = query.where('religion', isEqualTo: selectedReligion);
    }
    if (selectedFamilyIntention != null && selectedFamilyIntention != 'ALL') {
      query = query.where('familyIntention', isEqualTo: selectedFamilyIntention);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CandidateProfile.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Seed sample anonymous marriage candidates matching the updated CandidateProfile model
  Future<void> seedCuratedDemoProfiles() async {
    final List<CandidateProfile> demoCandidates = [
      CandidateProfile(
        uid: 'seed_cand_001',
        alias: 'Steadfast Anchor #402',
        gender: 'Male',
        ageBracket: '25-29',
        mbtiType: 'INTJ',
        personalityScores: const {'E': 0, 'I': 3, 'S': 0, 'N': 3, 'T': 3, 'F': 0, 'J': 3, 'P': 0},
        religion: 'Christian',
        religiosityLevel: 4,
        financialGoal: 'Debt-Free & Long-Term Wealth',
        familyIntention: 'Children in 1-2 Years',
        coreValues: ['Faith', 'Fidelity', 'Discipline', 'Growth'],
        bioPhilosophy:
            'Marriage is a sacred covenant requiring intentional communication, shared spiritual foundations, and mutual support under pressure.',
        kycStatus: KycStatus.verified,
        role: UserRole.candidate,
        hasUploadedId: true,
        isOnline: true,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      CandidateProfile(
        uid: 'seed_cand_002',
        alias: 'Compassionate Leader #781',
        gender: 'Female',
        ageBracket: '30-34',
        mbtiType: 'ENFJ',
        personalityScores: const {'E': 3, 'I': 0, 'S': 0, 'N': 3, 'T': 0, 'F': 3, 'J': 3, 'P': 0},
        religion: 'Christian',
        religiosityLevel: 5,
        financialGoal: 'Generational Legacy & Stewardship',
        familyIntention: 'Children in 1-2 Years',
        coreValues: ['Servant Leadership', 'Hospitality', 'Empathy'],
        bioPhilosophy:
            'A strong marriage creates a peaceful home and serves the community. Seeking an emotionally mature partner who values personal development.',
        kycStatus: KycStatus.verified,
        role: UserRole.candidate,
        hasUploadedId: true,
        isOnline: true,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      CandidateProfile(
        uid: 'seed_cand_003',
        alias: 'Patient Architect #512',
        gender: 'Female',
        ageBracket: '25-29',
        mbtiType: 'INFJ',
        personalityScores: const {'E': 0, 'I': 3, 'S': 0, 'N': 3, 'T': 0, 'F': 3, 'J': 3, 'P': 0},
        religion: 'Spiritual',
        religiosityLevel: 3,
        financialGoal: 'Balanced Work-Life & Property',
        familyIntention: 'Open to Children',
        coreValues: ['Loyalty', 'Quiet Depth', 'Intellectual Honesty'],
        bioPhilosophy:
            'I believe marriage thrives when two whole people commit unconditionally to helping one another flourish mentally, emotionally, and practically.',
        kycStatus: KycStatus.verified,
        role: UserRole.candidate,
        hasUploadedId: true,
        isOnline: false,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      CandidateProfile(
        uid: 'seed_cand_004',
        alias: 'Noble Sovereign #334',
        gender: 'Male',
        ageBracket: '35-39',
        mbtiType: 'ENTJ',
        personalityScores: const {'E': 3, 'I': 0, 'S': 0, 'N': 3, 'T': 3, 'F': 0, 'J': 3, 'P': 0},
        religion: 'Traditional',
        religiosityLevel: 4,
        financialGoal: 'Enterprise & Asset Expansion',
        familyIntention: 'Desires Large Family',
        coreValues: ['Integrity', 'Ambition', 'Order', 'Generational Wealth'],
        bioPhilosophy:
            'Marriage is the ultimate covenant partnership. It requires shared high standards, resilience during trials, and mutual respect.',
        kycStatus: KycStatus.verified,
        role: UserRole.candidate,
        hasUploadedId: true,
        isOnline: false,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      ),
      CandidateProfile(
        uid: 'seed_cand_005',
        alias: 'Gentle Shepherd #919',
        gender: 'Female',
        ageBracket: '30-34',
        mbtiType: 'ISFJ',
        personalityScores: const {'E': 0, 'I': 3, 'S': 3, 'N': 0, 'T': 0, 'F': 3, 'J': 3, 'P': 0},
        religion: 'Christian',
        religiosityLevel: 5,
        financialGoal: 'Financial Peace & Home Ownership',
        familyIntention: 'Children in 1-2 Years',
        coreValues: ['Devotion', 'Family-First', 'Kindness', 'Patience'],
        bioPhilosophy:
            'A warm, peaceful home built on steadfast love, shared prayer, and daily sacrifices for the family is life’s highest calling.',
        kycStatus: KycStatus.verified,
        role: UserRole.candidate,
        hasUploadedId: true,
        isOnline: true,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];

    final WriteBatch batch = _db.batch();
    for (final candidate in demoCandidates) {
      final docRef = _db.collection('user_profiles').doc(candidate.uid);
      batch.set(docRef, candidate.toMap());
    }
    await batch.commit();
  }
}