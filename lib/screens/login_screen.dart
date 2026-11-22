import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/sound_service.dart';
import 'candidate_portal_screen.dart';
import 'family_dashboard_screen.dart';
import 'onboarding_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      final UserCredential cred = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final String uid = cred.user!.uid;
      final db = FirebaseFirestore.instance;
      final doc = await db.collection('user_profiles').doc(uid).get();

      await SoundService.playNotificationChime();

      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data()!;
        final String role = (data['role'] ?? 'candidate').toString().toLowerCase();

        // 1. Admin Routing
        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminMasterDashboardScreen()),
            (route) => false,
          );
          return;
        }

        // 2. Married Family Routing
        if (role == 'married_family') {
          final String familyId = data['familyId'] ?? data['activeFamilyId'] ?? '';
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => FamilyDashboardScreen(familyId: familyId)),
            (route) => false,
          );
          return;
        }

        // 3. Candidate Routing
        final profile = CandidateProfile.fromMap(data);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CandidatePortalScreen(
              currentUid: profile.uid,
              currentAlias: profile.alias,
            ),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Profile not found. Please complete the application process.";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorMessage = "Invalid credentials. Please verify your email and password.";
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
          "COVENANT SIGN IN",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(32),
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
                  const Text("Sign In to Your Account", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text("Candidates, Married Families, and Shepherds log in here.", style: TextStyle(fontSize: 13, color: Colors.white60)),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                    const SizedBox(height: 18),
                  ],

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Email Address", filled: true, fillColor: Color(0xFF0F172A)),
                    validator: (v) => v == null || !v.contains("@") ? "Valid email required" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: "Secure Password", filled: true, fillColor: Color(0xFF0F172A)),
                    validator: (v) => v == null || v.isEmpty ? "Password required" : null,
                  ),
                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)))
                          : const Text("AUTHENTICATE & ENTER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
                      },
                      child: const Text("Seeking marriage? Begin Candidate Application (18+ & MBTI)", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
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
}