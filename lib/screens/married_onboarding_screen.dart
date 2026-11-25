import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/family_model.dart';
import '../services/sound_service.dart';
import '../services/covenant_quiz_service.dart';
import 'covenant_quiz_screen.dart';
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

  // Individual Spousal Test Results
  PersonalityCalculationResult? _husbandResult;
  PersonalityCalculationResult? _wifeResult;

  Future<void> _pickAnniversary() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4AF37),
            onPrimary: Color(0xFF0F172A),
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _anniversaryDate = picked);
  }

  void _launchHusbandTest() {
    final name = _husbandNameController.text.trim().isNotEmpty
        ? "${_husbandNameController.text.trim()} (Husband)"
        : "Husband";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CovenantQuizScreen(
          participantName: name,
          onQuizCompleted: (res) {
            setState(() => _husbandResult = res);
          },
        ),
      ),
    );
  }

  void _launchWifeTest() {
    final name = _wifeNameController.text.trim().isNotEmpty
        ? "${_wifeNameController.text.trim()} (Wife)"
        : "Wife";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CovenantQuizScreen(
          participantName: name,
          onQuizCompleted: (res) {
            setState(() => _wifeResult = res);
          },
        ),
      ),
    );
  }

  Future<void> _handleEnrollFamily() async {
    if (!_formKey.currentState!.validate()) return;
    if (_anniversaryDate == null) {
      setState(() => _errorMessage = "Please enter your wedding anniversary date.");
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

      final family = FamilyProfile(
        id: familyDoc.id,
        familyName: "The ${_husbandNameController.text.trim()} Household",
        spouseAUid: uid,
        spouseAName: _husbandNameController.text.trim(),
        spouseAMbti: _husbandResult?.fullCode ?? "Pending Test",
        spouseAScores: _husbandResult != null ? Map<String, int>.from(_husbandResult!.toMap()) : {},
        spouseAGender: 'Male',
        spouseBUid: 'spouse_wife_$uid',
        spouseBName: _wifeNameController.text.trim(),
        spouseBMbti: _wifeResult?.fullCode ?? "Pending Test",
        spouseBScores: _wifeResult != null ? Map<String, int>.from(_wifeResult!.toMap()) : {},
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
          "Family enrolled. Husband MBTI: ${_husbandResult?.fullCode ?? 'Pending'}, Wife MBTI: ${_wifeResult?.fullCode ?? 'Pending'}.",
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
                        child: Text("DIM Household Enrollment & Spousal Psychometrics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Husband and Wife take the assessment as individuals. Press the test button when each of you is ready so the Admin can advise your family based on your unique cognitive reports.",
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

                  // Anniversary
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

                  // Login Credentials
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

                  // --- DEDICATED INDIVIDUAL SPOUSAL TEST SECTION ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "INDIVIDUAL SPOUSAL ASSESSMENTS",
                          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Each spouse taps their button when ready. The results attach to each name for the Admin's counseling dossier.",
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        const SizedBox(height: 16),

                        // Husband Button
                        _buildSpouseTestCard(
                          spouseRole: "Husband",
                          name: _husbandNameController.text.trim().isNotEmpty ? _husbandNameController.text.trim() : "Husband",
                          result: _husbandResult,
                          onPressed: _launchHusbandTest,
                        ),
                        const SizedBox(height: 12),

                        // Wife Button
                        _buildSpouseTestCard(
                          spouseRole: "Wife",
                          name: _wifeNameController.text.trim().isNotEmpty ? _wifeNameController.text.trim() : "Wife",
                          result: _wifeResult,
                          onPressed: _launchWifeTest,
                        ),
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
                          : const Text("SOLEMNIZE HOUSEHOLD PROFILE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
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

  Widget _buildSpouseTestCard({
    required String spouseRole,
    required String name,
    required PersonalityCalculationResult? result,
    required VoidCallback onPressed,
  }) {
    final bool isDone = result != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDone ? const Color(0xFF10B981) : Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isDone ? Icons.check_circle : Icons.pending_outlined, color: isDone ? const Color(0xFF34D399) : Colors.white38, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$spouseRole: $name", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    isDone ? "Completed: ${result.fullCode}" : "Ready to take test",
                    style: TextStyle(color: isDone ? const Color(0xFFD4AF37) : Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? const Color(0xFF0F172A) : const Color(0xFFD4AF37),
              foregroundColor: isDone ? const Color(0xFFD4AF37) : const Color(0xFF0F172A),
              side: isDone ? const BorderSide(color: Color(0xFFD4AF37)) : BorderSide.none,
            ),
            child: Text(isDone ? "RETAKE" : "TAKE TEST", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
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