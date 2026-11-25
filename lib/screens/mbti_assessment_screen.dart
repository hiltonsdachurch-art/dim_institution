import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/sound_service.dart';
import 'candidate_portal_screen.dart';

class QuizQuestion {
  final String dimension;
  final String questionText;
  final String optionALabel;
  final String optionAValue;
  final String optionBLabel;
  final String optionBValue;

  const QuizQuestion({
    required this.dimension,
    required this.questionText,
    required this.optionALabel,
    required this.optionAValue,
    required this.optionBLabel,
    required this.optionBValue,
  });
}

class MbtiAssessmentScreen extends StatefulWidget {
  final String candidateUid;
  final String candidateAlias;
  final String gender;
  final String ageBracket;
  final bool hasUploadedId;
  final bool hasUploadedFacePhoto;

  const MbtiAssessmentScreen({
    super.key,
    required this.candidateUid,
    required this.candidateAlias,
    required this.gender,
    required this.ageBracket,
    this.hasUploadedId = false,
    this.hasUploadedFacePhoto = false,
  });

  @override
  State<MbtiAssessmentScreen> createState() => _MbtiAssessmentScreenState();
}

class _MbtiAssessmentScreenState extends State<MbtiAssessmentScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<QuizQuestion> _quizQuestions = const [
    // --- ENERGY (E vs I) ---
    QuizQuestion(
      dimension: 'EI',
      questionText: "1. On an ideal weekend together as a couple, you would rather:",
      optionALabel: "Host friends, attend social events, or explore busy places together",
      optionAValue: "E",
      optionBLabel: "Enjoy a quiet, cozy day at home just the two of you",
      optionBValue: "I",
    ),
    QuizQuestion(
      dimension: 'EI',
      questionText: "2. After a stressful day at work, how do you prefer to reconnect?",
      optionALabel: "Talk through everything that happened right away",
      optionAValue: "E",
      optionBLabel: "Take some quiet time to decompress before having a deep conversation",
      optionBValue: "I",
    ),
    QuizQuestion(
      dimension: 'EI',
      questionText: "3. When celebrating anniversaries or major milestones, you prefer:",
      optionALabel: "A lively gathering surrounded by loved ones and family",
      optionAValue: "E",
      optionBLabel: "An intimate, private celebration with just your spouse",
      optionBValue: "I",
    ),

    // --- INFORMATION (S vs N) ---
    QuizQuestion(
      dimension: 'SN',
      questionText: "4. In marriage, what brings you the strongest sense of security?",
      optionALabel: "Practical stability, shared daily routines, and reliable habits",
      optionAValue: "S",
      optionBLabel: "A shared long-term vision, deep intellectual connection, and future dreams",
      optionBValue: "N",
    ),
    QuizQuestion(
      dimension: 'SN',
      questionText: "5. When planning your future together, you naturally focus on:",
      optionALabel: "Concrete details like budgets, timelines, and immediate next steps",
      optionAValue: "S",
      optionBLabel: "Big-picture possibilities, lifestyle goals, and what life could look like years from now",
      optionBValue: "N",
    ),
    QuizQuestion(
      dimension: 'SN',
      questionText: "6. Which type of conversation energizes you most with a partner?",
      optionALabel: "Sharing stories about your day, practical plans, and real-life experiences",
      optionAValue: "S",
      optionBLabel: "Exploring abstract ideas, personal growth, philosophy, and 'what-if' scenarios",
      optionBValue: "N",
    ),

    // --- DECISIONS (T vs F) ---
    QuizQuestion(
      dimension: 'TF',
      questionText: "7. When a disagreement comes up in a relationship, your first instinct is to:",
      optionALabel: "Analyze the issue logically and find a fair, practical solution",
      optionAValue: "T",
      optionBLabel: "Check in on each other's feelings first and restore emotional harmony",
      optionBValue: "F",
    ),
    QuizQuestion(
      dimension: 'TF',
      questionText: "8. How do you primarily show love and care to your spouse?",
      optionALabel: "Solving problems for them, offering honest advice, and practical support",
      optionAValue: "T",
      optionBLabel: "Warmth, verbal encouragement, empathy, and emotional closeness",
      optionBValue: "F",
    ),
    QuizQuestion(
      dimension: 'TF',
      questionText: "9. When making major family decisions together, you prioritize:",
      optionALabel: "Objective pros, cons, and what makes the most rational sense",
      optionAValue: "T",
      optionBLabel: "How the decision aligns with your shared values and affects everyone emotionally",
      optionBValue: "F",
    ),

    // --- STRUCTURE (J vs P) ---
    QuizQuestion(
      dimension: 'JP',
      questionText: "10. How do you prefer to manage household routines and finances?",
      optionALabel: "With clear budgets, schedules, and agreed-upon plans",
      optionAValue: "J",
      optionBLabel: "With flexibility, adapting as life changes without strict rules",
      optionBValue: "P",
    ),
    QuizQuestion(
      dimension: 'JP',
      questionText: "11. When planning a couple's vacation, you enjoy:",
      optionALabel: "Booking flights, stays, and activities well in advance",
      optionAValue: "J",
      optionBLabel: "Picking a destination and leaving plenty of room for spontaneous adventures",
      optionBValue: "P",
    ),
    QuizQuestion(
      dimension: 'JP',
      questionText: "12. When unexpected changes disrupt your plans for the week, you feel:",
      optionALabel: "Frustrated until a new structured plan is put in place",
      optionAValue: "J",
      optionBLabel: "Easygoing and quick to pivot to something new",
      optionBValue: "P",
    ),
  ];

  final Map<int, String> _userAnswers = {};
  String _selectedReligion = 'Christian';
  int _religiosityLevel = 4;
  String _financialGoal = 'Debt-Free & Long-Term Wealth';
  String _familyIntention = 'Children in 1-2 Years';
  final TextEditingController _bioController = TextEditingController();
  bool _isSaving = false;

  Map<String, dynamic> _computeResults() {
    final Map<String, int> scores = {
      'E': 0, 'I': 0,
      'S': 0, 'N': 0,
      'T': 0, 'F': 0,
      'J': 0, 'P': 0,
    };

    for (final val in _userAnswers.values) {
      if (scores.containsKey(val)) {
        scores[val] = scores[val]! + 1;
      }
    }

    final String mbti = 
        (scores['E']! >= scores['I']! ? 'E' : 'I') +
        (scores['S']! >= scores['N']! ? 'S' : 'N') +
        (scores['T']! >= scores['F']! ? 'T' : 'F') +
        (scores['J']! >= scores['P']! ? 'J' : 'P');

    return {'mbti': mbti, 'scores': scores};
  }

  Future<void> _handleSubmit() async {
    if (_userAnswers.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please answer all 12 questions (${_userAnswers.length}/12 completed)."),
          backgroundColor: Colors.amber[800],
        ),
      );
      return;
    }

    if (_bioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write a statement on your marriage philosophy."),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final results = _computeResults();
      final String personalityType = results['mbti'] as String;
      final Map<String, int> dimensionalScores = results['scores'] as Map<String, int>;

      final List<String> coreValues = [];
      if (dimensionalScores['J']! >= 2) coreValues.add('Order & Reliability');
      if (dimensionalScores['P']! >= 2) coreValues.add('Adaptability');
      if (dimensionalScores['F']! >= 2) coreValues.add('Emotional Harmony');
      if (dimensionalScores['T']! >= 2) coreValues.add('Rational Integrity');
      if (dimensionalScores['N']! >= 2) coreValues.add('Vision & Ideals');
      if (dimensionalScores['S']! >= 2) coreValues.add('Practical Stability');
      coreValues.add('Faith');

      final profile = CandidateProfile(
        uid: widget.candidateUid,
        alias: widget.candidateAlias,
        gender: widget.gender,
        ageBracket: widget.ageBracket,
        mbtiType: personalityType,
        personalityScores: dimensionalScores,
        religion: _selectedReligion,
        religiosityLevel: _religiosityLevel,
        financialGoal: _financialGoal,
        familyIntention: _familyIntention,
        coreValues: coreValues,
        bioPhilosophy: _bioController.text.trim(),
        kycStatus: widget.hasUploadedId && widget.hasUploadedFacePhoto ? KycStatus.verified : KycStatus.unverified,
        role: UserRole.candidate,
        hasUploadedId: widget.hasUploadedId,
        hasUploadedFacePhoto: widget.hasUploadedFacePhoto,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _db.collection('user_profiles').doc(widget.candidateUid).set(profile.toMap());
      await SoundService.playCelebrationChime();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CandidatePortalScreen(
            currentUid: widget.candidateUid,
            currentAlias: widget.candidateAlias,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int answered = _userAnswers.length;
    final results = _computeResults();
    final String currentType = answered == 12 ? results['mbti'] : "----";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "RELATIONSHIP PERSONALITY QUIZ",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // PASTORAL INTEGRITY ADVISORY CARD
                // =========================================================
                Container(
                  margin: const EdgeInsets.only(bottom: 22),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.balance, color: Color(0xFFD4AF37), size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "IMPORTANT NOTICE: ANSWER WITH UNCOMPROMISING HONESTY",
                              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Your answers determine how prospective spouses see your marital character and compatibility. Furthermore, the Gatekeeper and your Marriage Shepherd will use this exact report to conduct verification interviews and provide lifelong marriage guidance.\n\n"
                        "Answering falsely or trying to guess the 'best' answer will lead to mismatched introductions and inaccurate counseling. Answer according to who you truly are today.",
                        style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.candidateAlias} (${widget.gender})",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Step 2 of 2 • $answered/12 Questions Completed",
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        "MBTI: $currentType",
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: answered / 12.0,
                    backgroundColor: const Color(0xFF0F172A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 28),

                // 12 Questions
                ..._quizQuestions.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final QuizQuestion q = entry.value;
                  final String? currentAnswer = _userAnswers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentAnswer != null ? const Color(0xFFD4AF37).withOpacity(0.4) : Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.questionText,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                        const SizedBox(height: 14),

                        // Option A
                        InkWell(
                          onTap: () => setState(() => _userAnswers[index] = q.optionAValue),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: currentAnswer == q.optionAValue ? const Color(0xFFD4AF37).withOpacity(0.18) : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: currentAnswer == q.optionAValue ? const Color(0xFFD4AF37) : Colors.white12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  currentAnswer == q.optionAValue ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: currentAnswer == q.optionAValue ? const Color(0xFFD4AF37) : Colors.white38,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    q.optionALabel,
                                    style: TextStyle(
                                      color: currentAnswer == q.optionAValue ? Colors.white : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: currentAnswer == q.optionAValue ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Option B
                        InkWell(
                          onTap: () => setState(() => _userAnswers[index] = q.optionBValue),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: currentAnswer == q.optionBValue ? const Color(0xFFD4AF37).withOpacity(0.18) : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: currentAnswer == q.optionBValue ? const Color(0xFFD4AF37) : Colors.white12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  currentAnswer == q.optionBValue ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: currentAnswer == q.optionBValue ? const Color(0xFFD4AF37) : Colors.white38,
                                  size: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    q.optionBLabel,
                                    style: TextStyle(
                                      color: currentAnswer == q.optionBValue ? Colors.white : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: currentAnswer == q.optionBValue ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(color: Colors.white12, height: 32),

                const Text("Marriage Alignment & Philosophy", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                _buildDropdown("Spiritual Tradition", _selectedReligion, ['Christian', 'Traditional', 'Spiritual', 'Jewish', 'Muslim', 'Other'], (v) => setState(() => _selectedReligion = v!)),
                const SizedBox(height: 14),

                _buildDropdown("Financial Philosophy", _financialGoal, ['Debt-Free & Long-Term Wealth', 'Enterprise & Asset Expansion', 'Balanced Work-Life & Property', 'Generational Legacy & Stewardship'], (v) => setState(() => _financialGoal = v!)),
                const SizedBox(height: 14),

                _buildDropdown("Family Intentions", _familyIntention, ['Children in 1-2 Years', 'Desires Large Family', 'Open to Children', 'No Children Intended'], (v) => setState(() => _familyIntention = v!),),
                const SizedBox(height: 16),

                const Text("Philosophy on Marriage Covenant", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "What does an honorable, lasting marriage require of both spouses?",
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2))
                        : const Text("ATTACH PERSONALITY & ENTER DISCOVERY", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}