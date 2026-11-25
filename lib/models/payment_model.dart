enum PaymentTier {
  tier2GatekeeperScreening, // R700
  tier3ShepherdMonthly,     // R199/mo
}

enum PaymentStatus {
  completed,
  pending,
  failed,
}

class CovenantPayment {
  final String id;
  final String payerUid;
  final String payerAlias;
  final PaymentTier tier;
  final double amountZar; // 700.0 or 199.0
  final PaymentStatus status;
  final String referenceId; // introId for Tier 2, familyId for Tier 3
  final String paymentMethod; // "Card", "Capitec Pay", "Instant EFT", "SnapScan"
  final DateTime timestamp;

  CovenantPayment({
    required this.id,
    required this.payerUid,
    required this.payerAlias,
    required this.tier,
    required this.amountZar,
    required this.status,
    required this.referenceId,
    required this.paymentMethod,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payerUid': payerUid,
      'payerAlias': payerAlias,
      'tier': tier.name,
      'amountZar': amountZar,
      'status': status.name,
      'referenceId': referenceId,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CovenantPayment.fromMap(Map<String, dynamic> map, String docId) {
    return CovenantPayment(
      id: docId,
      payerUid: map['payerUid'] ?? '',
      payerAlias: map['payerAlias'] ?? 'Candidate',
      tier: PaymentTier.values.firstWhere(
        (e) => e.name == map['tier'],
        orElse: () => PaymentTier.tier2GatekeeperScreening,
      ),
      amountZar: (map['amountZar'] as num?)?.toDouble() ?? 700.0,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.completed,
      ),
      referenceId: map['referenceId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Card',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}