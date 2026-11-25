import 'package:flutter/material.dart';
import '../services/covenant_quiz_service.dart';
import '../services/sound_service.dart';
import '../widgets/likert_scale_widget.dart';
import 'personality_report_screen.dart';

class CovenantQuizScreen extends StatefulWidget {
  final String participantName; // e.g. "Marcus (Husband)" or "Steadfast Anchor #402"
  final ValueChanged<PersonalityCalculationResult> onQuizCompleted;

  const CovenantQuizScreen({
    super.key,
    required this.participantName,
    required this.onQuizCompleted,
  });

  @override
  State<CovenantQuizScreen> createState() => _CovenantQuizScreenState();
}

class _CovenantQuizScreenState extends State<CovenantQuizScreen> {
  final Map<int, int> _answers = {}; // questionId -> score (-3 to +3)
  final questions = CovenantQuizService.questions;

  void _finishQuiz() async {
    if (_answers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please complete all questions (${_answers.length}/${questions.length} answered)."),
          backgroundColor: Colors.amber[800],
        ),
      );
      return;
    }

    final result = CovenantQuizService.calculate(_answers);
    await SoundService.playCelebrationChime();

    widget.onQuizCompleted(result);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalityReportScreen(
          personName: widget.participantName,
          fullCode: result.fullCode,
          scorePercentages: result.toMap(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int answered = _answers.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "${widget.participantName.toUpperCase()} ASSESSMENT",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // =========================================================
                // SOLEMN PASTORAL INTEGRITY ADVISORY CARD (CRUCIAL NOTICE)
                // =========================================================
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.12),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.balance, color: Color(0xFFD4AF37), size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "PASTORAL INTEGRITY ADVISORY: ANSWER WITH COMPLETE HONESTY",
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Please pause and read carefully before answering:\n\n"
                        "• Public Compatibility: Your honest answers shape the personality badge and compatibility breakdown that prospective partners view. Answering who you 'wish you were' rather than who you truly are will attract the wrong partner and sabotage real marriage compatibility.\n\n"
                        "• Shepherd Counseling & Guidance: The Gatekeeper and your assigned Marriage Shepherd will use this exact report to conduct your private verification interviews, score your emotional maturity, and provide lifelong marital guidance.\n\n"
                        "There are no 'right' or 'wrong' personality types in holy matrimony—only honest ones. Answer according to your authentic daily reactions, not an idealized version of yourself.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Header Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress: $answered of ${questions.length} Completed",
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${((answered / questions.length) * 100).round()}%",
                      style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: answered / questions.length.toDouble(),
                    backgroundColor: const Color(0xFF1E293B),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 24),

                // 7-Point Likert Scale Questions
                ...questions.map((q) {
                  return LikertScaleWidget(
                    questionText: q.text,
                    selectedScore: _answers[q.id],
                    onScoreSelected: (score) {
                      setState(() {
                        _answers[q.id] = score;
                      });
                    },
                  );
                }),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: answered == questions.length ? _finishQuiz : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    child: Text(
                      answered == questions.length
                          ? "COMPUTE AUTHENTIC PERSONALITY DOSSIER"
                          : "ANSWER ALL QUESTIONS ($answered/${questions.length})",
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}