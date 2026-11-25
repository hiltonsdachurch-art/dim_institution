import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/inquiry_service.dart';
import '../services/sound_service.dart';
import 'onboarding_screen.dart';
import 'married_onboarding_screen.dart';
import 'login_screen.dart';

class InstitutionalHomeScreen extends StatefulWidget {
  const InstitutionalHomeScreen({super.key});

  @override
  State<InstitutionalHomeScreen> createState() =>
      _InstitutionalHomeScreenState();
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
    'Emergency Marital Advisory & Mediation',
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline,
                  color: Color(0xFF34D399), size: 26),
              SizedBox(width: 10),
              Text("Inquiry Lodged with Gatekeeper",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            _isEmergency
                ? "Emergency Request Received: An Institutional Shepherd has been alerted for priority pastoral response."
                : "Thank you for reaching out to DIM. A marriage shepherd will respond to your registered email shortly.",
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F172A)),
              child: const Text("CLOSE"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error submitting message: $e"),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSendingInquiry = false);
    }
  }

  void _openEmergencyShepherdDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.volunteer_activism, color: Color(0xFFD4AF37), size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text("Emergency Shepherd Line",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "DIM is a lifelong family institution. Whether you are in your first year or your fiftieth, no covenant household walks alone.",
              style:
                  TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 14),
            Text("Priority Shepherd Hotline:",
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            SizedBox(height: 2),
            Text("+27 (76) 554-3855",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text("Emergency Crisis Email:",
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            SizedBox(height: 2),
            Text("shepherd.crisis@dim.institution",
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0F172A)),
            child: const Text("UNDERSTOOD"),
          ),
        ],
      ),
    );
  }

  void _launchVideoStory(
      String videoUrl, String coupleName, String description) async {
    final uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Documentary: $coupleName",
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: Text(description,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.4)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0F172A)),
              child: const Text("CLOSE"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.shield_outlined,
                color: Color(0xFFD4AF37), size: 22),
            const SizedBox(width: 8),
            Text(
              isMobile ? 'DIM COVENANT' : 'DIGITAL INSTITUTION FOR MARRIAGE',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              SoundService.isMuted ? Icons.volume_off : Icons.volume_up,
              color: const Color(0xFFD4AF37),
              size: 20,
            ),
            tooltip: SoundService.isMuted ? "Unmute Chimes" : "Mute Chimes",
            onPressed: () => setState(() => SoundService.toggleMute()),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            icon: const Icon(Icons.login, size: 15, color: Color(0xFFD4AF37)),
            label: const Text("SIGN IN",
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =============================================================
            // 1. HERO SANCTUARY & COVENANT VISION
            // =============================================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 60),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    children: [
                      Container(
                        width: isMobile ? 70 : 86,
                        height: isMobile ? 70 : 86,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 3),
                          ],
                        ),
                        child: Center(
                          child: Icon(Icons.account_balance,
                              color: const Color(0xFFD4AF37),
                              size: isMobile ? 36 : 44),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "The Digital Institution for Marriage",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "A Curated Covenant Agency & Lifelong Shepherding Sanctuary",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 16,
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "This is not a dating app. Candidate profiles are temporary vehicles for courtship; the permanent destination is the Family Profile. From your first introduction to your 50th anniversary, DIM walks with you as your gatekeeper, verifier, and lifelong family friend.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.white70,
                            height: 1.6),
                      ),
                      const SizedBox(height: 28),

                      // Action Buttons
                      if (isMobile) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const OnboardingScreen()));
                            },
                            icon:
                                const Icon(Icons.how_to_reg_outlined, size: 16),
                            label: const Text(
                                "SEEKING A SPOUSE (CANDIDATE APPLY)",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MarriedOnboardingScreen()));
                            },
                            icon: const Icon(Icons.house_siding_rounded,
                                size: 16, color: Color(0xFFD4AF37)),
                            label: const Text(
                                "ENROLL MARRIED COUPLE (FAMILY PROFILE)",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFD4AF37)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _openEmergencyShepherdDialog,
                          icon: const Icon(Icons.volunteer_activism_outlined,
                              size: 16, color: Color(0xFF34D399)),
                          label: const Text("24/7 PASTORAL CRISIS HOTLINE",
                              style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      ] else ...[
                        Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const OnboardingScreen()));
                              },
                              icon: const Icon(Icons.how_to_reg_outlined,
                                  size: 18),
                              label: const Text(
                                  "SEEKING A SPOUSE (CANDIDATE ONBOARDING)"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MarriedOnboardingScreen()));
                              },
                              icon: const Icon(Icons.house_siding_rounded,
                                  size: 18, color: Color(0xFFD4AF37)),
                              label: const Text(
                                  "ENROLL MARRIED COUPLE (FAMILY PROFILE)",
                                  style: TextStyle(color: Colors.white)),
                              style: OutlinedButton.styleFrom(
                                side:
                                    const BorderSide(color: Color(0xFFD4AF37)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openEmergencyShepherdDialog,
                              icon: const Icon(
                                  Icons.volunteer_activism_outlined,
                                  size: 16,
                                  color: Color(0xFF34D399)),
                              label: const Text("24/7 PASTORAL CRISIS HOTLINE",
                                  style: TextStyle(
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // =============================================================
            // 2. THE 4 SACRED PILLARS OF DIM
            // =============================================================
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 56),
              color: const Color(0xFF1E293B),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    children: [
                      const Text("OUR FOUR COVENANT PILLARS",
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text("Why We Are Different",
                          style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildPillarCard(
                            isMobile: isMobile,
                            icon: Icons.shield_outlined,
                            title: "1. Zero-Leakage Privacy",
                            description:
                                "No names, numbers, or photos in search. Candidates evaluate each other by worldview, faith, and character first.",
                          ),
                          _buildPillarCard(
                            isMobile: isMobile,
                            icon: Icons.psychology_outlined,
                            title: "2. 7-Point Likert Psychometrics",
                            description:
                                "Our 5-dimension assessment evaluates conflict style, finances, stress, and identity without artificial ties.",
                          ),
                          _buildPillarCard(
                            isMobile: isMobile,
                            icon: Icons.verified_user_outlined,
                            title: "3. The Verification Gate",
                            description:
                                "No direct contact until private interviews are held. The Gatekeeper verifies emotional maturity on a 10-point scorecard.",
                          ),
                          _buildPillarCard(
                            isMobile: isMobile,
                            icon: Icons.handshake_outlined,
                            title: "4. Lifelong Family Shepherding",
                            description:
                                "When couples wed, profiles merge into a permanent Family Profile with lifelong advisory, video appointments, and crisis care.",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =============================================================
            // 3. THE WEDDING VISUAL GALLERY & DOCUMENTARIES
            // =============================================================
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 56),
              color: const Color(0xFF0F172A),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Column(
                    children: [
                      const Text("VISUAL COVENANT SANCTUARY",
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text("From Discovery to Holy Matrimony",
                          style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        "Every photo and video below represents a real couple that walked through our Gatekeeper Verification Gate and now lives under a blessed covenant.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: isMobile ? 12 : 13,
                            height: 1.5),
                      ),
                      const SizedBox(height: 28),

                      // Curated Pexels High-Speed CDN Wedding Images (Guaranteed open mobile loading)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildWeddingPhotoCard(
                            isMobile: isMobile,
                            imageUrl:
                                "https://images.pexels.com/photos/1024993/pexels-photo-1024993.jpeg?auto=compress&cs=tinysrgb&w=800",
                            coupleName: "Marcus & Abigail Vance",
                            anniversaryNote:
                                "Married 3 Years • INTJ & ENFJ Covenant",
                          ),
                          _buildWeddingPhotoCard(
                            isMobile: isMobile,
                            imageUrl:
                                "https://images.pexels.com/photos/1444442/pexels-photo-1444442.jpeg?auto=compress&cs=tinysrgb&w=800",
                            coupleName: "Ravi & Sayuri Mokoena",
                            anniversaryNote:
                                "Married 2 Years • INFJ & ENTP Covenant",
                          ),
                          _buildWeddingPhotoCard(
                            isMobile: isMobile,
                            imageUrl:
                                "https://images.pexels.com/photos/1045541/pexels-photo-1045541.jpeg?auto=compress&cs=tinysrgb&w=800",
                            coupleName: "David & Sarah Jenkins",
                            anniversaryNote:
                                "Married 18 Months • ISFJ & ENTJ Covenant",
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Video Documentary Showcase
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.videocam_outlined,
                                    color: Color(0xFFD4AF37), size: 20),
                                SizedBox(width: 8),
                                Text("COVENANT JOURNEY DOCUMENTARIES",
                                    style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.8)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Watch couples share how the Chaperoned Lounge and Gatekeeper interviews guided their steps to marriage.",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: [
                                _buildVideoCard(
                                  isMobile: isMobile,
                                  title: "The Vance Family Story",
                                  subtitle:
                                      "Resolving financial and spiritual vision with our Shepherd before meeting.",
                                  duration: "7 mins",
                                  onPlay: () => _launchVideoStory(
                                    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                                    "Marcus & Abigail Vance",
                                    "Marcus (INTJ) and Abigail (ENFJ) describe how the Gatekeeper scorecard validated their compatibility, and how their Shepherd remains their closest family advisor.",
                                  ),
                                ),
                                _buildVideoCard(
                                  isMobile: isMobile,
                                  title: "Crisis Mediation in Year Two",
                                  subtitle:
                                      "Using our 24/7 Shepherd Hotline during an unexpected family disruption.",
                                  duration: "9 mins",
                                  onPlay: () => _launchVideoStory(
                                    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                                    "Ravi & Sayuri Mokoena",
                                    "Ravi and Sayuri recount their second year of marriage when business hardship created marital tension, and how weekly video advisory restored peace.",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =============================================================
            // 4. THE HALL OF COVENANTS (DETAILED TESTIMONIES)
            // =============================================================
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 56),
              color: const Color(0xFF1E293B),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    children: [
                      const Text("TESTIMONIES OF FAITHFUL HOMES",
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text("Couples Who Walked This Journey",
                          style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildTestimonyCard(
                            isMobile: isMobile,
                            coupleNames: "Marcus & Abigail Vance",
                            yearsMarried:
                                "Married 3 Years • INTJ & ENFJ Covenant",
                            story:
                                "“In DIM, we didn't waste months playing games. The Gatekeeper interviewed us individually, made sure our financial and spiritual priorities aligned, and guided us into marriage. Three years later, we still reach out to our Shepherd for annual advisory.”",
                          ),
                          _buildTestimonyCard(
                            isMobile: isMobile,
                            coupleNames: "Ravi & Sayuri Mokoena",
                            yearsMarried:
                                "Married 2 Years • INFJ & ENTP Covenant",
                            story:
                                "“The Chaperoned Lounge was revolutionary. Knowing there was an Anti-Leak Shield forced us to communicate about character, vision, and prayer instead of superficial chatter. DIM gave us a sanctuary.”",
                          ),
                          _buildTestimonyCard(
                            isMobile: isMobile,
                            coupleNames: "David & Sarah Jenkins",
                            yearsMarried:
                                "Married 18 Months • ISFJ & ENTJ Covenant",
                            story:
                                "“When our first baby arrived and financial stress hit our home, our DIM Marriage Shepherd was our first call. Having a dedicated mentor who knows our personalities saved our marriage from early distress.”",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =============================================================
            // 5. EXPANDED FAQS (ALL 7 RESTORED WITH HIGH FIDELITY)
            // =============================================================
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 56),
              color: const Color(0xFF0F172A),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    children: [
                      const Text("FREQUENTLY ASKED INSTITUTIONAL QUESTIONS",
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text("What We Stand For & Why Choose DIM",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 24),
                      _buildFaqTile(
                        question:
                            "1. What is the core philosophy of DIM, and why are you NOT a dating app?",
                        answer:
                            "Modern dating apps promote superficial swiping, ghosting, and consumer mindset. DIM is a curated agency where marriage is treated as an honorable lifelong covenant. No direct contact is permitted without Admin Gatekeeper screening, and every candidate is evaluated on emotional maturity, faith, and family readiness.",
                      ),
                      _buildFaqTile(
                        question:
                            "2. Why should single adults choose DIM over secular matchmaking?",
                        answer:
                            "We protect your time, heart, and dignity. With zero-leakage privacy, you search by character, faith, and values rather than appearance. Our relationship-tailored 7-point Likert assessment avoids ties and maps real-life marital compatibility before you ever meet.",
                      ),
                      _buildFaqTile(
                        question:
                            "3. Why can married couples join DIM, and what is a Family Profile?",
                        answer:
                            "In DIM, candidate profiles are temporary; the permanent institutional unit is the Family Profile. Married couples join DIM to receive lifelong pastoral mentorship, annual covenant renewals, spousal psychometric mapping, and emergency conflict mediation.",
                      ),
                      _buildFaqTile(
                        question:
                            "4. How does the Gatekeeper Verification Gate protect candidates?",
                        answer:
                            "When two candidates agree to meet, the Gatekeeper conducts private, individual interviews with both parties. We verify identities, validate MBTI accuracy, review financial and family intentions, and score emotional maturity on a 10-point scorecard before unlocking contact details.",
                      ),
                      _buildFaqTile(
                        question:
                            "5. Can I skip uploading my government ID and live photo during registration?",
                        answer:
                            "Yes. You may explore the catalog and take the personality quiz without uploading an ID. However, to maintain absolute trust, you cannot lodge or receive introduction requests until your government ID and facial photo are attached in your profile.",
                      ),
                      _buildFaqTile(
                        question:
                            "6. How can married couples connect with the Admin Shepherd?",
                        answer:
                            "Married families have access to direct contact channels right on their Family Dashboard: WhatsApp messaging, direct phone calls, and email. In addition, couples can schedule Zoom or Microsoft Teams pastoral appointments directly through the platform.",
                      ),
                      _buildFaqTile(
                        question:
                            "7. Are couples allowed to graduate and navigate independently without DIM?",
                        answer:
                            "Yes. When a couple gets married, they have the sovereign choice: they can either retain DIM Shepherding Benefits (24/7 crisis lines, check-ins, advisory) or graduate with our blessing as an independent covenant.",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =============================================================
            // 6. INTERACTIVE INQUIRY & CONTACT SANCTUARY
            // =============================================================
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 36 : 56),
              color: const Color(0xFF1E293B),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.35)),
                  ),
                  child: Form(
                    key: _inquiryFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.mail_outline,
                                color: Color(0xFFD4AF37), size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  "Connect with an Institutional Shepherd",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Seeking marriage, engaged, or in need of marital crisis advisory? Our Shepherds are on standby to serve your household.",
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              labelText: "Full Name",
                              filled: true,
                              fillColor: Color(0xFF1E293B)),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              labelText: "Email Address",
                              filled: true,
                              fillColor: Color(0xFF1E293B)),
                          validator: (v) => v == null || !v.contains("@")
                              ? "Valid email required"
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                              filled: true, fillColor: Color(0xFF1E293B)),
                          items: _categories
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                              "This is an urgent marital crisis / emergency advisory request",
                              style: TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                          value: _isEmergency,
                          activeColor: const Color(0xFFD4AF37),
                          onChanged: (val) =>
                              setState(() => _isEmergency = val ?? false),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText:
                                "Your Question or Message for the Shepherd",
                            hintText:
                                "How can the institution serve your household?",
                            filled: true,
                            fillColor: Color(0xFF1E293B),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? "Required" : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                _isSendingInquiry ? null : _handleSendInquiry,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: const Color(0xFF0F172A)),
                            child: _isSendingInquiry
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF0F172A),
                                        strokeWidth: 2))
                                : const Text("DISPATCH INQUIRY TO SHEPHERD",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // =============================================================
            // 7. RESPONSIVE INSTITUTIONAL FOOTER (NO TEXT OVERLAPPING)
            // =============================================================
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 36, vertical: 40),
              color: const Color(0xFF0A0F1D),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: isMobile
                      ? _buildMobileFooter(context)
                      : _buildDesktopFooter(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MOBILE FOOTER (CLEAN VERTICAL STACK) ---
  Widget _buildMobileFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 20),
            SizedBox(width: 8),
            Text("DIM COVENANT AGENCY",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "The Digital Institution for Marriage is a curated agency dedicated to cultivating honorable, enduring covenant households through gatekeeper discernment and lifelong mentorship.",
          style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.white12),
        const SizedBox(height: 14),
        const Text("PATHWAYS",
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        _buildFooterLink(
            "Candidate Application",
            () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const OnboardingScreen()))),
        _buildFooterLink(
            "Married Family Enrollment",
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => const MarriedOnboardingScreen()))),
        _buildFooterLink(
            "Sign In to Account",
            () => Navigator.push(context,
                MaterialPageRoute(builder: (c) => const LoginScreen()))),
        const SizedBox(height: 16),
        const Text("PASTORAL CARE & HOTLINE",
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1)),
        const SizedBox(height: 6),
        const Text(
            "24/7 Priority Pastoral Line: +27 (76) 554-3855\nAdvisory Email: shepherd@dim.institution",
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
        const SizedBox(height: 16),
        const Text("INSTITUTIONAL STANDARDS",
            style: TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1)),
        const SizedBox(height: 6),
        const Text(
            "• Zero-Leakage Privacy\n• 18+ Government ID Gated\n• Anti-Leak Screen Shield\n• Lifelong Covenant Mentorship",
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
        const SizedBox(height: 24),
        const Divider(color: Colors.white12),
        const SizedBox(height: 12),
        const Center(
          child: Text(
              "© 2026 The Digital Institution for Marriage\nAll Rights Reserved Worldwide",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white38, fontSize: 10, height: 1.4)),
        ),
      ],
    );
  }

  // --- DESKTOP FOOTER (4-COLUMN ROW) ---
  Widget _buildDesktopFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield_outlined,
                          color: Color(0xFFD4AF37), size: 20),
                      SizedBox(width: 8),
                      Text("DIM COVENANT AGENCY",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "The Digital Institution for Marriage is a high-trust agency dedicated to cultivating honorable, enduring covenant households through gatekeeper discernment and lifelong mentorship.",
                    style: TextStyle(
                        color: Colors.white54, fontSize: 11, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PATHWAYS",
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  _buildFooterLink(
                      "Candidate Application",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const OnboardingScreen()))),
                  _buildFooterLink(
                      "Married Family Enrollment",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) =>
                                  const MarriedOnboardingScreen()))),
                  _buildFooterLink(
                      "Sign In Portal",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const LoginScreen()))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PASTORAL CARE",
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  const Text("24/7 Crisis Hotline:\n+27 (76) 554-3855",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.4)),
                  const SizedBox(height: 6),
                  const Text("Advisory Email:\nshepherd@dim.institution",
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("STANDARDS",
                      style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  const Text(
                      "• Zero-Leakage Privacy\n• 18+ Government ID Gated\n• Anti-Leak Screen Shield\n• Lifelong Covenant Care",
                      style: TextStyle(
                          color: Colors.white54, fontSize: 11, height: 1.6)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
                "© 2026 The Digital Institution for Marriage • All Rights Reserved",
                style: TextStyle(color: Colors.white38, fontSize: 10)),
            Text("A Sanctuary for Covenant Families Worldwide",
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildPillarCard(
      {required bool isMobile,
      required IconData icon,
      required String title,
      required String description}) {
    return Container(
      width: isMobile ? double.infinity : 450,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1E293B),
            radius: 20,
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeddingPhotoCard({
    required bool isMobile,
    required String imageUrl,
    required String coupleName,
    required String anniversaryNote,
  }) {
    return Container(
      width: isMobile ? double.infinity : 310,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: isMobile ? 200 : 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: isMobile ? 200 : 220,
                  color: const Color(0xFF0F172A),
                  child: const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37), strokeWidth: 2)),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                height: isMobile ? 200 : 220,
                color: const Color(0xFF0F172A),
                child: const Center(
                  child:
                      Icon(Icons.favorite, color: Color(0xFFD4AF37), size: 48),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(coupleName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(anniversaryNote,
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard({
    required bool isMobile,
    required String title,
    required String subtitle,
    required String duration,
    required VoidCallback onPlay,
  }) {
    return Container(
      width: isMobile ? double.infinity : 460,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onPlay,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Color(0xFF0F172A), size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(duration,
                          style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonyCard(
      {required bool isMobile,
      required String coupleNames,
      required String yearsMarried,
      required String story}) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
              Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
              Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
              Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
              Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Text(story,
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.4)),
          const SizedBox(height: 14),
          Text(coupleNames,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          const SizedBox(height: 2),
          Text(yearsMarried,
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFaqTile({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFFD4AF37),
        collapsedIconColor: Colors.white54,
        title: Text(question,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(answer,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: onTap,
        child: Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ),
    );
  }
}
