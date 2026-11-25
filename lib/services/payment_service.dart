import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';
import '../models/introduction_model.dart';
import '../models/family_model.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Process Tier 2 Payment (R700 ZAR) - Unlocks Gatekeeper Screening
  Future<void> processTier2GatekeeperFee({
    required String introId,
    required String payerUid,
    required String payerAlias,
    required String paymentMethod,
  }) async {
    final payDoc = _db.collection('covenant_payments').doc();
    final payment = CovenantPayment(
      id: payDoc.id,
      payerUid: payerUid,
      payerAlias: payerAlias,
      tier: PaymentTier.tier2GatekeeperScreening,
      amountZar: 700.0,
      status: PaymentStatus.completed,
      referenceId: introId,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(payDoc, payment.toMap());

    // Update Introduction record: Mark Tier 2 as paid and ready for interviews
    final introRef = _db.collection('introductions').doc(introId);
    batch.update(introRef, {
      'tier2Paid': true,
      'tier2Amount': 700.0,
      'tier2PaymentId': payDoc.id,
      'state': IntroState.interviewsInProgress.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  // 2. Process Tier 3 Shepherd Membership (R199/month ZAR)
  Future<void> processTier3ShepherdSubscription({
    required String familyId,
    required String payerUid,
    required String familyName,
    required String paymentMethod,
  }) async {
    final payDoc = _db.collection('covenant_payments').doc();
    final payment = CovenantPayment(
      id: payDoc.id,
      payerUid: payerUid,
      payerAlias: familyName,
      tier: PaymentTier.tier3ShepherdMonthly,
      amountZar: 199.0,
      status: PaymentStatus.completed,
      referenceId: familyId,
      paymentMethod: paymentMethod,
      timestamp: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(payDoc, payment.toMap());

    // Update Family Profile membership tier
    final familyRef = _db.collection('family_profiles').doc(familyId);
    batch.update(familyRef, {
      'membershipTier': DimMembershipTier.shepherdedFamilyMember.name,
      'lastSubscriptionDate': DateTime.now().toIso8601String(),
      'subscriptionActive': true,
    });

    await batch.commit();
  }

  // Stream payments for Admin audit
  Stream<List<CovenantPayment>> getAllPaymentsStream() {
    return _db.collection('covenant_payments').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((d) => CovenantPayment.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }
}