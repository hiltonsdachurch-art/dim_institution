import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_kyc_service.dart';
import '../services/liveness_ocr_service.dart';
import '../widgets/legal_policy_modal.dart';
import 'mbti_assessment_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _gender = 'Male';
  DateTime? _selectedDob;
  PlatformFile? _selectedIdFile;
  PlatformFile? _selectedFacePhoto;
  bool _isLoading = false;
  String? _errorMessage;

  // Automated OCR & Liveness Diagnostics
  OcrVerificationResult? _ocrResult;
  FacialLivenessResult? _livenessResult;
  bool _isScanningOcr = false;
  bool _isCheckingLiveness = false;

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;

  Future<void> _pickBirthDate() async {
    final DateTime initialDate = DateTime(2000, 1, 1);
    final DateTime firstDate = DateTime(1940);
    final DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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

    if (picked != null) {
      if (!AuthKycService.isStrictlyAdult(picked)) {
        setState(() {
          _errorMessage = "Underage Notice: You must be at least 18 years old to join DIM.";
          _selectedDob = null;
        });
      } else {
        setState(() {
          _selectedDob = picked;
          _errorMessage = null;
        });
      }
    }
  }

  Future<void> _pickAndScanGovernmentId() async {
    if (_selectedDob == null) {
      setState(() => _errorMessage = "Please select your date of birth first so the OCR scanner can verify your age.");
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedIdFile = file;
        _isScanningOcr = true;
      });

      // Run Optical Character Recognition
      final ocr = await LivenessOcrService.scanGovernmentId(
        file: file,
        declaredDob: _selectedDob!,
        declaredLegalName: _fullNameController.text,
      );

      setState(() {
        _ocrResult = ocr;
        _isScanningOcr = false;
      });
    }
  }

  Future<void> _pickAndVerifyFacialPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFacePhoto = file;
        _isCheckingLiveness = true;
      });

      // Run Facial Liveness & Quality Analysis
      final liveness = await LivenessOcrService.verifyFacialPortrait(file: file);

      setState(() {
        _livenessResult = liveness;
        _isCheckingLiveness = false;
      });
    }
  }

  Future<void> _handleRegisterAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      setState(() => _errorMessage = "Please verify your date of birth (Strict 18+).");
      return;
    }

    if (!_acceptedTerms || !_acceptedPrivacy) {
      setState(() => _errorMessage = "You must acknowledge both the Terms of Membership and Privacy Policy to register.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = cred.user!.uid;
      final ageBracket = AuthKycService.calculateAgeBracket(_selectedDob!);
      final alias = AuthKycService.generateAlias();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MbtiAssessmentScreen(
            candidateUid: uid,
            candidateAlias: alias,
            gender: _gender,
            ageBracket: ageBracket,
            hasUploadedId: _selectedIdFile != null && (_ocrResult?.isVerified ?? false),
            hasUploadedFacePhoto: _selectedFacePhoto != null && (_livenessResult?.passedLiveness ?? false),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'email-already-in-use') {
          _errorMessage = "An account with this email already exists.";
        } else {
          _errorMessage = e.message ?? e.code;
        }
      });
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
        title: const Text(
          "CANDIDATE ONBOARDING & BIOMETRICS",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Identity & Biometric Verification Gate",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "DIM uses automated optical OCR to verify 18+ age status and facial presence. ID and facial photo can be skipped now, but both are required before requesting introductions.",
                    style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Gender
                  const Text("Gender Identity", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _gender = 'Male'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _gender == 'Male' ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _gender == 'Male' ? const Color(0xFFD4AF37) : Colors.white12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.male, color: Color(0xFFD4AF37), size: 18),
                                  SizedBox(width: 6),
                                  Text("Gentleman / Male", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _gender = 'Female'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _gender == 'Female' ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _gender == 'Female' ? const Color(0xFFD4AF37) : Colors.white12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.female, color: Color(0xFFD4AF37), size: 18),
                                  SizedBox(width: 6),
                                  Text("Lady / Female", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Legal Name
                  TextFormField(
                    controller: _fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Legal Full Name", Icons.person_outline),
                    validator: (v) => v == null || v.trim().isEmpty ? "Legal name is required" : null,
                  ),
                  const SizedBox(height: 14),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Private Email Address", Icons.email_outlined),
                    validator: (v) => v == null || !v.contains("@") ? "Valid email required" : null,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Password (Min 8 Characters)", Icons.lock_outline),
                    validator: (v) => v == null || v.length < 8 ? "Minimum 8 characters" : null,
                  ),
                  const SizedBox(height: 18),

                  // DOB Picker
                  InkWell(
                    onTap: _pickBirthDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDob == null
                                    ? "Select Date of Birth (Strict 18+)"
                                    : "DOB: ${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: _selectedDob == null ? Colors.white54 : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const Text("Verify Age", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // AUTOMATED OCR GOVERNMENT ID SCANNER
                  InkWell(
                    onTap: _isScanningOcr ? null : _pickAndScanGovernmentId,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _ocrResult?.isVerified == true ? const Color(0xFF10B981) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_isScanningOcr)
                            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2))
                          else
                            Icon(
                              _ocrResult?.isVerified == true ? Icons.check_circle : Icons.document_scanner_outlined,
                              color: _ocrResult?.isVerified == true ? const Color(0xFF10B981) : const Color(0xFFD4AF37),
                              size: 22,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedIdFile == null ? "Government ID (Optional for Onboarding)" : _selectedIdFile!.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _ocrResult != null
                                      ? _ocrResult!.diagnosticMessage
                                      : "Optical OCR will verify age 18+ and document authenticity.",
                                  style: TextStyle(
                                    color: _ocrResult?.isVerified == true ? const Color(0xFF34D399) : Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // AUTOMATED FACIAL LIVENESS & PORTRAIT CHECK
                  InkWell(
                    onTap: _isCheckingLiveness ? null : _pickAndVerifyFacialPhoto,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _livenessResult?.passedLiveness == true ? const Color(0xFF10B981) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (_isCheckingLiveness)
                            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2))
                          else
                            Icon(
                              _livenessResult?.passedLiveness == true ? Icons.face : Icons.camera_alt_outlined,
                              color: _livenessResult?.passedLiveness == true ? const Color(0xFF10B981) : const Color(0xFFD4AF37),
                              size: 22,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFacePhoto == null ? "Live Facial Photo / Portrait (Optional)" : _selectedFacePhoto!.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _livenessResult != null
                                      ? _livenessResult!.feedback
                                      : "Scans for live human presence and clear frontal alignment.",
                                  style: TextStyle(
                                    color: _livenessResult?.passedLiveness == true ? const Color(0xFF34D399) : Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Legal Checkboxes
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _acceptedTerms,
                          activeColor: const Color(0xFFD4AF37),
                          checkColor: const Color(0xFF0F172A),
                          title: Row(
                            children: [
                              const Expanded(
                                child: Text("I agree to the ", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ),
                              InkWell(
                                onTap: () => LegalPolicyModal.showTermsAndConditions(context),
                                child: const Text(
                                  "Terms of Membership",
                                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _acceptedPrivacy,
                          activeColor: const Color(0xFFD4AF37),
                          checkColor: const Color(0xFF0F172A),
                          title: Row(
                            children: [
                              const Expanded(
                                child: Text("I consent to the POPIA-compliant ", style: TextStyle(color: Colors.white70, fontSize: 11)),
                              ),
                              InkWell(
                                onTap: () => LegalPolicyModal.showPrivacyPolicy(context),
                                child: const Text(
                                  "Privacy Policy Vault",
                                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                          onChanged: (val) => setState(() => _acceptedPrivacy = val ?? false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegisterAndProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                            )
                          : const Text(
                              "CONTINUE TO PERSONALITY ASSESSMENT",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                            ),
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
      ),
    );
  }
}