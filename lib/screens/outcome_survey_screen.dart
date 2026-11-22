import 'package:flutter/material.dart';
import '../models/case_file_model.dart';
import '../services/case_file_service.dart';

class OutcomeSurveyScreen extends StatefulWidget {
  final String introId;
  final String respondentUid;
  final String respondentAlias;

  const OutcomeSurveyScreen({
    super.key,
    required this.introId,
    required this.respondentUid,
    required this.respondentAlias,
  });

  @override
  State<OutcomeSurveyScreen> createState() => _OutcomeSurveyScreenState();
}

class _OutcomeSurveyScreenState extends State<OutcomeSurveyScreen> {
  final CaseFileService _caseFileService = CaseFileService();
  MeetingOutcome _outcome = MeetingOutcome.failed;
  String _selectedReason = 'Conversational Imbalance & Poor Listening';
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _failureReasons = [
    'Conversational Imbalance & Poor Listening',
    'Misaligned Financial Vision & Goals',
    'Spiritual & Theological Friction',
    'Lack of Demonstrated Emotional Maturity',
    'Hesitation on Marriage Timeline',
    'Chemistry / Authentic Alignment Missing',
  ];

  final List<String> _successReasons = [
    'High Alignment on Faith & Marriage Intentions',
    'Exceptional Communication & Mutual Respect',
    'Shared Financial Discipline & Ambition',
    'Mutual Desire to Enter Marriage Shepherd Mentorship',
  ];

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      await _caseFileService.submitOutcomeSurvey(
        introId: widget.introId,
        respondentUid: widget.respondentUid,
        respondentAlias: widget.respondentAlias,
        outcome: _outcome,
        primaryReason: _selectedReason,
        qualitativeNotes: _notesController.text,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 26),
              SizedBox(width: 10),
              Text("Survey Recorded", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: const Text(
            "Your feedback has been integrated into the candidate's longitudinal Case File. The Gatekeeper will review this assessment for mentorship tracking.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0F172A),
              ),
              child: const Text("RETURN"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting survey: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _outcome == MeetingOutcome.succeeded ? _successReasons : _failureReasons;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "POST-MEETING OUTCOME SURVEY",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Institutional Retrospective",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "DIM tracks every introduction outcome longitudinally. Your qualitative feedback fuels the Gatekeeper's coaching recommendations.",
                  style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Outcome Toggle
                const Text(
                  "Did this meeting advance toward a marriage covenant?",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _outcome = MeetingOutcome.succeeded;
                            _selectedReason = _successReasons.first;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _outcome == MeetingOutcome.succeeded
                                ? const Color(0xFF064E3B)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _outcome == MeetingOutcome.succeeded
                                  ? const Color(0xFF10B981)
                                  : Colors.white12,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check, color: Color(0xFF34D399), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "YES (SUCCEEDED)",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _outcome = MeetingOutcome.failed;
                            _selectedReason = _failureReasons.first;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _outcome == MeetingOutcome.failed
                                ? const Color(0xFF78350F)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _outcome == MeetingOutcome.failed
                                  ? const Color(0xFFF59E0B)
                                  : Colors.white12,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.close, color: Color(0xFFFBBF24), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "NO (CONCLUDED)",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Primary Categorical Reason
                const Text(
                  "Primary Analytical Factor",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedReason,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (val) => setState(() => _selectedReason = val!),
                  ),
                ),
                const SizedBox(height: 20),

                // Detailed Qualitative Notes
                const Text(
                  "Qualitative Observations for the Gatekeeper",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Detail specific communication dynamics, posture, or reservations...",
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2),
                          )
                        : const Text(
                            "SUBMIT TO CASE FILE",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}