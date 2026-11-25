import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../services/sound_service.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  final PaymentTier tier;
  final String referenceId; // introId or familyId
  final String payerUid;
  final String payerAlias;
  final VoidCallback onPaymentSuccessful;

  const PaymentCheckoutScreen({
    super.key,
    required this.tier,
    required this.referenceId,
    required this.payerUid,
    required this.payerAlias,
    required this.onPaymentSuccessful,
  });

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedMethod = "Debit / Credit Card (Visa & Mastercard)";
  bool _isProcessing = false;

  final List<String> _methods = [
    "Debit / Credit Card (Visa & Mastercard)",
    "Capitec Pay / Ozow Instant EFT",
    "SnapScan / Zapper QR",
  ];

  double get _amount => widget.tier == PaymentTier.tier2GatekeeperScreening ? 700.0 : 199.0;
  String get _title => widget.tier == PaymentTier.tier2GatekeeperScreening
      ? "Tier 2: Gatekeeper Screening & Reveal Fee"
      : "Tier 3: Monthly Shepherd Membership";

  String get _description => widget.tier == PaymentTier.tier2GatekeeperScreening
      ? "Covers two private 45-minute Gatekeeper verification interviews, background vetting, and competency scorecards before contact details are revealed."
      : "Enrolls your household in active monthly pastoral shepherding, 24/7 emergency marital lines, and Teams/Zoom advisory sessions.";

  Future<void> _handleAuthorizePayment() async {
    setState(() => _isProcessing = true);

    try {
      if (widget.tier == PaymentTier.tier2GatekeeperScreening) {
        await _paymentService.processTier2GatekeeperFee(
          introId: widget.referenceId,
          payerUid: widget.payerUid,
          payerAlias: widget.payerAlias,
          paymentMethod: _selectedMethod,
        );
      } else {
        await _paymentService.processTier3ShepherdSubscription(
          familyId: widget.referenceId,
          payerUid: widget.payerUid,
          familyName: widget.payerAlias,
          paymentMethod: _selectedMethod,
        );
      }

      await SoundService.playCelebrationChime();

      if (!mounted) return;
      Navigator.pop(context);
      widget.onPaymentSuccessful();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment of R${_amount.toStringAsFixed(0)} ZAR Authorized Successfully!"),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 22),
                    SizedBox(width: 8),
                    Text(
                      "DIM COVENANT PAYMENT GATE",
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(_title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_description, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
            const SizedBox(height: 20),

            // Amount Display Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("TOTAL ADMINISTRATION FEE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        widget.tier == PaymentTier.tier2GatekeeperScreening ? "One-off Match Fee" : "Monthly Recurring Retainer",
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    "R${_amount.toStringAsFixed(0)} ZAR",
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // South African Payment Methods Selector
            const Text("Select South African Payment Method:", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ..._methods.map((method) {
              final bool isSelected = _selectedMethod == method;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.white12),
                ),
                child: RadioListTile<String>(
                  value: method,
                  groupValue: _selectedMethod,
                  activeColor: const Color(0xFFD4AF37),
                  title: Text(method, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  onChanged: (val) => setState(() => _selectedMethod = val!),
                ),
              );
            }),
            const SizedBox(height: 22),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleAuthorizePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)))
                    : Text(
                        "AUTHORIZE & PAY R${_amount.toStringAsFixed(0)} ZAR",
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}