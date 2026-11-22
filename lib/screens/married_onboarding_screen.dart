import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';
import '../services/sound_service.dart';
import 'family_dashboard_screen.dart';

class MarriedOnboardingScreen extends StatefulWidget {
  const MarriedOnboardingScreen({super.key});

  @override
  State<MarriedOnboardingScreen> createState() => _MarriedOnboardingScreenState();
}

class _MarriedOnboardingScreenState extends State<MarriedOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _husbandNameController = TextEditingController();
  final _wifeNameController = TextEditingController();
  final _visionController = TextEditingController();

  DateTime? _anniversaryDate;
  DimMembershipTier _tier = DimMembershipTier.shepherdedFamilyMember;
  bool _isLoading = false;
  String? _errorMessage;

  // Spousal Psychometric Answers
  final Map<int, String> _husbandAnswers = {};
  final Map<int, String> _wifeAnswers = {};

  final List<String> _questions = const [
    "1. Weekend Preference: (A) Social events / host friends OR (B) Quiet cozy home together?",
    "2. Stress Recovery: (A) Talk it through immediately OR (B) Quiet decompression first?",
    "3. Milestone Celebrations: (A) Large lively gathering OR (B) Intimate private dinner?",
    "4. Marital Security: (A) Practical routine & stability OR (B) Deep vision & shared dreams?",
    "5. Future Planning: (A) Budgets & concrete steps OR (B) Lifestyle & big-picture goals?",
    "6. Energy Conversation: (A) Real-life day events OR (B) Ideas, philosophy & what-if scenarios?",
    "7. Handling Disagreements: (A) Logical practical analysis OR (B) Emotional harmony check first?",
    "8. Showing Affection: (A) Solving problems & support OR (B) Warmth & emotional closeness?",
    "9. Major Family Choices: (A) Rational pros and cons OR (B) How everyone feels & shared values?",
    "10. Household Routines: (A) Agreed budgets & schedules OR (B) Flexible adaptation?",
    "11. Vacation Style: (A) Itinerary booked in advance OR (B) Spontaneous adventures?",
    "12. Disrupted Week: (A) Frustrated until plan reset OR (B) Easygoing and quick to pivot?",
  ];

  final List<List<String>> _options = const [
    ["E", "I"], ["E", "I"], ["E", "I"],
    ["S", "N"], ["S", "N"], ["S", "N"],
    ["T", "F"], ["T", "F"], ["T", "F"],
    ["J", "P"], ["J", "P"], ["J", "P"],
  ];

  Map<String, dynamic> _computeMbti(Map<int, String> answers) {
    final Map<String, int> scores = {'E': 0, 'I': 0, 'S': 0, 'N': 0, 'T': 0, 'F': 0, 'J': 0, 'P': 0};
    for (final v in answers.values) {
      if (scores.containsKey(v)) scores[v] = scores[v]! + 1;
    }
    final String type = (scores['E']! >= scores['I']! ? 'E' : 'I') +
        (scores['S']! >= scores['N']! ? 'S' : 'N') +
        (scores['T']! >= scores['F']! ? 'T' : 'F') +
        (scores['J']! >= scores['P']! ? 'J' : 'P');
    return {'type': type, 'scores': scores};
  }

  Future<void> _pickAnniversary() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFFD4AF37), onPrimary: Color(0xFF0F172A), surface: Color(0xFF1E293B)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _anniversaryDate = picked);
  }

  Future<void> _handleEnrollFamily() async {
    if (!_formKey.currentState!.validate()) return;
    if (_anniversaryDate == null) {
      setState(() => _errorMessage = "Please enter your wedding anniversary date.");
      return;
    }

    if (_husbandAnswers.length < 12 || _wifeAnswers.length < 12) {
      setState(() => _errorMessage = "Both Husband and Wife must complete all 12 personality questions.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = cred.user!.uid;
      final db = FirebaseFirestore.instance;
      final familyDoc = db.collection('family_profiles').doc();

      final husbandRes = _computeMbti(_husbandAnswers);
      final wifeRes = _computeMbti(_wifeAnswers);

      final family = FamilyProfile(
        id: familyDoc.id,
        familyName: "The ${_husbandNameController.text.trim()} Household",
        spouseAUid: uid,
        spouseAName: _husbandNameController.text.trim(),
        spouseAMbti: husbandRes['type'],
        spouseAScores: Map<String, int>.from(husbandRes['scores']),
        spouseAGender: 'Male',
        spouseBUid: 'spouse_wife_$uid',
        spouseBName: _wifeNameController.text.trim(),
        spouseBMbti: wifeRes['type'],
        spouseBScores: Map<String, int>.from(wifeRes['scores']),
        spouseBGender: 'Female',
        weddingDate: _anniversaryDate!,
        familyVisionStatement: _visionController.text.trim().isNotEmpty
            ? _visionController.text.trim()
            : "Building an honorable household of faithful devotion, mutual respect, and peace.",
        courtshipStage: CourtshipStage.holyMatrimonyMerged,
        membershipTier: _tier,
        familyMilestones: [
          "${_anniversaryDate!.toIso8601String().substring(0, 10)}: Holy Matrimony Solemnized",
          "${DateTime.now().toIso8601String().substring(0, 10)}: Enrolled in DIM Family Network",
        ],
        shepherdCounselNotes: [
          "Family enrolled with verified spousal psychometrics (Husband: ${husbandRes['type']}, Wife: ${wifeRes['type']}).",
        ],
        createdAt: DateTime.now(),
      );

      await familyDoc.set(family.toMap());

      await db.collection('user_profiles').doc(uid).set({
        'uid': uid,
        'alias': family.familyName,
        'role': 'married_family',
        'familyId': familyDoc.id,
        'isOnline': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await SoundService.playCelebrationChime();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FamilyDashboardScreen(familyId: family.id)),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ENROLL MARRIED FAMILY PROFILE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.house_siding_rounded, color: Color(0xFFD4AF37), size: 30),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text("DIM Household Enrollment & Psychometric Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Both Husband and Wife take the marriage assessment so the Admin Shepherd understands your cognitive dynamics during counsel.",
                    style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                  ),
                  const SizedBox(height: 22),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent.withOpacity(0.4))),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Names
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _husbandNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInput("Husband's Legal Name", Icons.person),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _wifeNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInput("Wife's Legal Name", Icons.person_outline),
                          validator: (v) => v == null || v.isEmpty ? "Required" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Anniversary & Account
                  InkWell(
                    onTap: _pickAnniversary,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite_outline, color: Color(0xFFD4AF37), size: 18),
                              const SizedBox(width: 10),
                              Text(
                                _anniversaryDate == null ? "Select Wedding Anniversary Date" : "Anniversary: ${_anniversaryDate!.toIso8601String().substring(0, 10)}",
                                style: TextStyle(color: _anniversaryDate == null ? Colors.white38 : Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                          const Text("Pick Date", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInput("Family Login Email", Icons.email_outlined),
                          validator: (v) => v == null || !v.contains("@") ? "Valid email required" : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInput("Master Password", Icons.lock_outline),
                          validator: (v) => v == null || v.length < 8 ? "Min 8 characters" : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _visionController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: "Household Covenant Vision Statement",
                      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                      hintText: "e.g., A peaceful sanctuary of mutual respect, spiritual unity, and community service.",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION: COUPLES' 12-QUESTION PSYCHOMETRIC QUIZ ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SPOUSAL RELATIONSHIP ASSESSMENT (12 QUESTIONS)", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8)),
                        const SizedBox(height: 4),
                        const Text("Both spouses select their answers so Admin sees their exact psychological harmony.", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        const SizedBox(height: 16),

                        ..._questions.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final String q = entry.value;
                          final optA = _options[idx][0];
                          final optB = _options[idx][1];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    // Husband Choice
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6)),
                                        child: Row(
                                          children: [
                                            const Text("Husband: ", style: TextStyle(color: Colors.white38, fontSize: 11)),
                                            _buildChoiceChip(optA, _husbandAnswers[idx] == optA, () => setState(() => _husbandAnswers[idx] = optA)),
                                            const SizedBox(width: 4),
                                            _buildChoiceChip(optB, _husbandAnswers[idx] == optB, () => setState(() => _husbandAnswers[idx] = optB)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Wife Choice
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6)),
                                        child: Row(
                                          children: [
                                            const Text("Wife: ", style: TextStyle(color: Colors.white38, fontSize: 11)),
                                            _buildChoiceChip(optA, _wifeAnswers[idx] == optA, () => setState(() => _wifeAnswers[idx] = optA)),
                                            const SizedBox(width: 4),
                                            _buildChoiceChip(optB, _wifeAnswers[idx] == optB, () => setState(() => _wifeAnswers[idx] = optB)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Membership Tier
                  RadioListTile<DimMembershipTier>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Full DIM Shepherd Membership (Recommended)", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Includes WhatsApp, phone, email direct access, and Teams/Zoom counseling.", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    value: DimMembershipTier.shepherdedFamilyMember,
                    groupValue: _tier,
                    activeColor: const Color(0xFFD4AF37),
                    onChanged: (v) => setState(() => _tier = v!),
                  ),
                  RadioListTile<DimMembershipTier>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Independent Covenant Registry (Go Alone)", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    value: DimMembershipTier.independentGraduated,
                    groupValue: _tier,
                    activeColor: const Color(0xFFD4AF37),
                    onChanged: (v) => setState(() => _tier = v!),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEnrollFamily,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2))
                          : const Text("SUBMIT PROFILE & ATTACH ASSESSMENTS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.white24),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0F172A) : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _buildInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}