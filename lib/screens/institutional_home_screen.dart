import 'package:flutter/material.dart';
import '../services/inquiry_service.dart';
import '../services/sound_service.dart';
import 'onboarding_screen.dart';
import 'married_onboarding_screen.dart';
import 'login_screen.dart';

class InstitutionalHomeScreen extends StatefulWidget {
  const InstitutionalHomeScreen({super.key});

  @override
  State<InstitutionalHomeScreen> createState() => _InstitutionalHomeScreenState();
}

class _InstitutionalHomeScreenState extends State<InstitutionalHomeScreen> {
  final InquiryService _inquiryService = InquiryService();
  final _inquiryFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General Inquiry & Questions';
  bool _isEmergency = false;
  bool _isSendingInquiry = false;

  final List<String> _categories = [
    'General Inquiry & Questions',
    'Pre-Marital Preparation Advice',
    'Emergency Marital Counsel & Mediation',
    'Shepherd Mentorship Information',
  ];

  Future<void> _handleSendInquiry() async {
    if (!_inquiryFormKey.currentState!.validate()) return;

    setState(() => _isSendingInquiry = true);

    try {
      await _inquiryService.submitInquiry(
        name: _nameController.text,
        email: _emailController.text,
        category: _selectedCategory,
        message: _messageController.text,
        isEmergency: _isEmergency,
      );

      await SoundService.playCelebrationChime();
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

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
              Text("Inquiry Lodged with Gatekeeper", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            _isEmergency
                ? "Emergency Request Received: An Institutional Shepherd has been alerted for priority pastoral response."
                : "Thank you for reaching out to DIM. A marriage shepherd will respond to your registered email shortly.",
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
              child: const Text("CLOSE"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting message: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSendingInquiry = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 24),
            SizedBox(width: 10),
            Text(
              'DIGITAL INSTITUTION FOR MARRIAGE',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              SoundService.isMuted ? Icons.volume_off : Icons.volume_up,
              color: const Color(0xFFD4AF37),
            ),
            tooltip: SoundService.isMuted ? "Unmute Chimes" : "Mute Chimes",
            onPressed: () => setState(() => SoundService.toggleMute()),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            icon: const Icon(Icons.login, size: 16, color: Color(0xFFD4AF37)),
            label: const Text("SIGN IN", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
              color: const Color(0xFF0F172A),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        ),
                        child: const Center(child: Icon(Icons.account_balance, color: Color(0xFFD4AF37), size: 40)),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "The Digital Institution for Marriage",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "A Curated Covenant Agency & Lifelong Shepherding Home",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Color(0xFFD4AF37), fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Candidate profiles are for courtship; the permanent goal is the Family Profile. Whether you are seeking marriage or already married and seeking family mentorship, you have a home with us.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
                      ),
                      const SizedBox(height: 32),

                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
                            },
                            icon: const Icon(Icons.how_to_reg_outlined, size: 18),
                            label: const Text("SEEKING A SPOUSE (CANDIDATE ONBOARDING)"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MarriedOnboardingScreen()));
                            },
                            icon: const Icon(Icons.house_siding_rounded, size: 18, color: Color(0xFFD4AF37)),
                            label: const Text("ENROLL AS MARRIED COUPLE (FAMILY PROFILE)", style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD4AF37)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // -------------------------------------------------------------
            // EXPANDED INSTITUTIONAL FAQS (WHAT WE STAND FOR & WHY CHOOSE US)
            // -------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
              color: const Color(0xFF1E293B),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    children: [
                      const Text("WHAT WE STAND FOR & WHY CHOOSE US", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      const Text("Frequently Asked Institutional Questions", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 28),

                      _buildFaqTile(
                        question: "1. What is the core philosophy of DIM, and why are you NOT a dating app?",
                        answer: "Modern dating apps promote superficial swiping, ghosting, and consumer mindset. DIM is a curated agency where marriage is treated as an honorable lifelong covenant. No direct contact is permitted without Admin Gatekeeper screening, and every candidate is evaluated on emotional maturity, faith, and family readiness.",
                      ),
                      _buildFaqTile(
                        question: "2. Why should single adults choose DIM over secular matchmaking?",
                        answer: "We protect your time and dignity. With zero-leakage privacy, you search by character, faith, and values rather than appearance. Our relationship-tailored 12-question MBTI assessment avoids ties and maps real-life marital compatibility before you ever meet.",
                      ),
                      _buildFaqTile(
                        question: "3. Why can married couples join DIM, and what is a Family Profile?",
                        answer: "In DIM, candidate profiles are temporary; the permanent institutional unit is the Family Profile. Married couples join DIM to receive lifelong pastoral mentorship, annual covenant renewals, spousal psychometric mapping, and emergency conflict mediation.",
                      ),
                      _buildFaqTile(
                        question: "4. How does the Gatekeeper Verification Gate protect candidates?",
                        answer: "When two candidates agree to meet, the Gatekeeper conducts private, individual interviews with both parties. We verify identities, validate MBTI accuracy, review financial and family intentions, and score emotional maturity on a 10-point scorecard before unlocking contact details.",
                      ),
                      _buildFaqTile(
                        question: "5. Can I skip uploading my government ID and live photo during registration?",
                        answer: "Yes. You may explore the catalog and take the personality quiz without uploading an ID. However, to maintain absolute trust, you cannot lodge or receive introduction requests until your government ID and facial photo are attached in your profile.",
                      ),
                      _buildFaqTile(
                        question: "6. How can married couples connect with the Admin Shepherd?",
                        answer: "Married families have access to direct contact channels right on their Family Dashboard: WhatsApp messaging, direct phone calls, and email. In addition, couples can schedule Zoom or Microsoft Teams pastoral appointments directly through the platform.",
                      ),
                      _buildFaqTile(
                        question: "7. Are couples allowed to graduate and navigate independently without DIM?",
                        answer: "Yes. When a couple gets married, they have the sovereign choice: they can either retain DIM Shepherding Benefits (24/7 crisis lines, check-ins, counsel) or graduate with our blessing as an independent covenant.",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // INQUIRY FORM
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              color: const Color(0xFF0F172A),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 680),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Form(
                    key: _inquiryFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.mail_outline, color: Color(0xFFD4AF37), size: 24),
                            SizedBox(width: 10),
                            Text("Connect with an Institutional Shepherd", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text("Seeking marriage, engaged, or in need of marital crisis counsel? Our Shepherds are here for you.", style: TextStyle(color: Colors.white60, fontSize: 13)),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: "Full Name", filled: true, fillColor: Color(0xFF0F172A)),
                          validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: "Email Address", filled: true, fillColor: Color(0xFF0F172A)),
                          validator: (v) => v == null || !v.contains("@") ? "Valid email required" : null,
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(filled: true, fillColor: Color(0xFF0F172A)),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                        ),
                        const SizedBox(height: 14),

                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("This is an urgent marital crisis / emergency counsel request", style: TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold)),
                          value: _isEmergency,
                          activeColor: const Color(0xFFD4AF37),
                          onChanged: (val) => setState(() => _isEmergency = val ?? false),
                        ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _messageController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: "Your Question or Message", filled: true, fillColor: Color(0xFF0F172A)),
                          validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSendingInquiry ? null : _handleSendInquiry,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                            child: _isSendingInquiry
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF0F172A), strokeWidth: 2))
                                : const Text("SUBMIT TO INSTITUTIONAL SHEPHERD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFFD4AF37),
        collapsedIconColor: Colors.white54,
        title: Text(question, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}