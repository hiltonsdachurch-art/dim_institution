import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_model.dart';

class AuthKycService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Strict 18+ Date Calculation
  static bool isStrictlyAdult(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age >= 18;
  }

  // Derive non-revealing age bracket
  static String calculateAgeBracket(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    if (age < 25) return "18-24";
    if (age < 30) return "25-29";
    if (age < 35) return "30-34";
    if (age < 40) return "35-39";
    if (age < 50) return "40-49";
    return "50+";
  }

  // Generate dignified, anonymous alias
  static String generateAlias() {
    const archetypes = [
      "Noble Guardian",
      "Compassionate Leader",
      "Steadfast Anchor",
      "Serene Builder",
      "Thoughtful Sage",
      "Devoted Shepherd",
      "Gentle Sovereign",
      "Patient Architect"
    ];
    final random = Random();
    final archetype = archetypes[random.nextInt(archetypes.length)];
    final code = 100 + random.nextInt(900); // 3-digit randomized tag
    return "$archetype #$code";
  }

  // Complete Registration with KYC Vaulting
  Future<void> registerAndSubmitKyc({
    required String email,
    required String password,
    required String legalFullName,
    required DateTime exactDob,
    required PlatformFile idFile,
  }) async {
    // 1. Enforce 18+ Guard
    if (!isStrictlyAdult(exactDob)) {
      throw Exception("Registration Rejected: DIM is strictly restricted to adults aged 18 and older.");
    }

    // 2. Create Firebase Auth Credential
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final String uid = credential.user!.uid;

    // 3. Upload ID Document to Secure Storage (Handling Web and Mobile)
    final String extension = idFile.extension ?? 'jpg';
    final String storagePath = 'kyc_vault/$uid/government_id.$extension';
    final Reference storageRef = _storage.ref().child(storagePath);

    UploadTask uploadTask;
    if (kIsWeb) {
      // Flutter Web requires byte streaming
      uploadTask = storageRef.putData(
        idFile.bytes!,
        SettableMetadata(contentType: 'image/$extension'),
      );
    } else {
      // Mobile platforms
      uploadTask = storageRef.putData(idFile.bytes!);
    }

    final TaskSnapshot snapshot = await uploadTask;
    final String documentUrl = await snapshot.ref.getDownloadURL();

    // 4. Batch Write: Public Profile vs Private PII Vault
    final WriteBatch batch = _db.batch();

    // Collection A: Public Discovery Profile (Zero PII)
    final candidateProfile = CandidateProfile(
      uid: uid,
      alias: generateAlias(),
      ageBracket: calculateAgeBracket(exactDob),
      gender: "Not specified",
      mbtiType: "INTJ", // Default starter until MBTI test in Milestone 3
      personalityScores: const {},
      kycStatus: KycStatus.pendingVerification,
      role: UserRole.candidate,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
      religion: "Not specified",
      religiosityLevel: 0,
      financialGoal: "Not specified",
      familyIntention: "Not specified",
      coreValues: const [],
      bioPhilosophy: "",
    );

    final profileRef = _db.collection('user_profiles').doc(uid);
    batch.set(profileRef, candidateProfile.toMap());

    // Collection B: Restricted PII Vault (Heavily Protected)
    final piiVault = UserPiiVault(
      uid: uid,
      legalFullName: legalFullName.trim(),
      exactDob: exactDob,
      idDocumentUrl: documentUrl,
      submittedAt: DateTime.now(),
    );

    final vaultRef = _db.collection('user_pii_vault').doc(uid);
    batch.set(vaultRef, piiVault.toMap());

    // Commit both writes atomically
    await batch.commit();
  }
}