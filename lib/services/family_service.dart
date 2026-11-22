import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/family_model.dart';

class FamilyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Direct Registration for Already-Married Couples
  Future<FamilyProfile> registerExistingMarriedFamily({
    required String husbandEmail,
    required String password,
    required String husbandLegalName,
    required String husbandMbti,
    required String wifeLegalName,
    required String wifeMbti,
    required DateTime weddingDate,
    required String familyVision,
    required DimMembershipTier tier,
  }) async {
    final auth = FirebaseAuth.instance;
    final cred = await auth.createUserWithEmailAndPassword(
      email: husbandEmail.trim(),
      password: password,
    );

    final String uid = cred.user!.uid;
    final familyDoc = _db.collection('family_profiles').doc();

    final family = FamilyProfile(
      id: familyDoc.id,
      familyName: "The $husbandLegalName Household",
      spouseAUid: uid,
      spouseAName: husbandLegalName,
      spouseAMbti: husbandMbti,
      spouseAScores: {},
      spouseAGender: 'Male',
      spouseBUid: 'spouse_wife_$uid',
      spouseBName: wifeLegalName,
      spouseBMbti: wifeMbti,
      spouseBScores: {},
      spouseBGender: 'Female',
      weddingDate: weddingDate,
      familyVisionStatement: familyVision,
      courtshipStage: CourtshipStage.holyMatrimonyMerged,
      membershipTier: tier,
      familyMilestones: [
        "${weddingDate.toIso8601String().substring(0, 10)}: Holy Matrimony Solemnized",
        "${DateTime.now().toIso8601String().substring(0, 10)}: Enrolled as DIM Family Members",
      ],
      shepherdCounselNotes: [
        "Welcome to the DIM Family Shepherding Network. Household enrolled under active mentorship.",
      ],
      createdAt: DateTime.now(),
    );

    // Save Family Profile
    await familyDoc.set(family.toMap());

    // Update User Account to point to this Family Profile
    await _db.collection('user_profiles').doc(uid).set({
      'uid': uid,
      'alias': family.familyName,
      'role': 'married_family',
      'familyId': familyDoc.id,
      'isOnline': true,
      'createdAt': DateTime.now().toIso8601String(),
    });

    return family;
  }

  // 2. Initialize Courtship Progression between two Candidates
  Future<String> initializeCourtshipProgress({
    required String candidateAUid,
    required String candidateAAlias,
    required String candidateAMbti,
    required String candidateAGender,
    required String candidateBUid,
    required String candidateBAlias,
    required String candidateBMbti,
    required String candidateBGender,
  }) async {
    final docRef = _db.collection('family_profiles').doc();

    final family = FamilyProfile(
      id: docRef.id,
      familyName: "$candidateAAlias & $candidateBAlias",
      spouseAUid: candidateAUid,
      spouseAName: candidateAAlias,
      spouseAMbti: candidateAMbti,
      spouseAGender: candidateAGender,
      spouseBUid: candidateBUid,
      spouseBName: candidateBAlias,
      spouseBMbti: candidateBMbti,
      spouseBGender: candidateBGender,
      weddingDate: DateTime.now(),
      familyVisionStatement: "Progressing intentionally toward becoming one covenant family.",
      courtshipStage: CourtshipStage.courtshipDiscovery,
      membershipTier: DimMembershipTier.shepherdedFamilyMember,
      familyMilestones: [
        "${DateTime.now().toIso8601String().substring(0, 10)}: Formal Courtship Commenced",
      ],
      shepherdCounselNotes: [
        "Gatekeeper approved introduction. Courtship discovery initiated under institutional supervision.",
      ],
      createdAt: DateTime.now(), spouseAScores: {}, spouseBScores: {},
    );

    await docRef.set(family.toMap());

    // Link both candidate profiles to this progress record
    await _db.collection('user_profiles').doc(candidateAUid).update({'activeFamilyId': docRef.id});
    await _db.collection('user_profiles').doc(candidateBUid).update({'activeFamilyId': docRef.id});

    return docRef.id;
  }

  // 3. Advance Progressive Stage toward becoming One Family
  Future<void> advanceProgressionStage({
    required String familyId,
    required CourtshipStage newStage,
    required String milestoneNote,
  }) async {
    final docRef = _db.collection('family_profiles').doc(familyId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final family = FamilyProfile.fromMap(doc.data()!, doc.id);
    final updatedMilestones = List<String>.from(family.familyMilestones)
      ..add("${DateTime.now().toIso8601String().substring(0, 10)}: $milestoneNote");

    await docRef.update({
      'courtshipStage': newStage.name,
      'familyMilestones': updatedMilestones,
    });
  }

  // 4. Solemnize Marriage & Merge Individual Profiles into One Family
  Future<void> mergeCandidatesIntoOneFamily({
    required String familyId,
    required String officialFamilyName,
    required DateTime weddingDate,
    required String jointFamilyVision,
    required DimMembershipTier tierChoice,
  }) async {
    final docRef = _db.collection('family_profiles').doc(familyId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final family = FamilyProfile.fromMap(doc.data()!, doc.id);
    final updatedMilestones = List<String>.from(family.familyMilestones)
      ..add("${weddingDate.toIso8601String().substring(0, 10)}: Holy Matrimony Solemnized — Profiles Merged into One Family");

    await docRef.update({
      'familyName': officialFamilyName,
      'weddingDate': weddingDate.toIso8601String(),
      'familyVisionStatement': jointFamilyVision,
      'courtshipStage': CourtshipStage.holyMatrimonyMerged.name,
      'membershipTier': tierChoice.name,
      'familyMilestones': updatedMilestones,
    });

    // Update both candidates' login roles to permanent married family
    await _db.collection('user_profiles').doc(family.spouseAUid).update({'role': 'married_family'});
    await _db.collection('user_profiles').doc(family.spouseBUid).update({'role': 'married_family'});
  }

  // Stream single family record
  Stream<FamilyProfile?> getFamilyStream(String familyId) {
    return _db.collection('family_profiles').doc(familyId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return FamilyProfile.fromMap(doc.data()!, doc.id);
    });
  }
}