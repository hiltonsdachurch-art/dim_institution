import 'package:flutter/material.dart';

class LegalPolicyModal {
  static void showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.gavel, color: Color(0xFFD4AF37), size: 22),
            SizedBox(width: 10),
            Text("Terms of Covenant Membership", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("DIGITAL INSTITUTION FOR MARRIAGE (DIM) • COVENANT CONTRACT", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                  "1. Solemn Marital Intent (Strict 18+):\n"
                  "DIM is strictly restricted to adults aged 18 and older who possess bona fide, honorable intentions of entering holy matrimony. Casual dating, hookup behavior, and misrepresentation of marital status are grounds for permanent expulsion.\n\n"
                  "2. Non-Circumvention & Anti-Leak Fortress:\n"
                  "All candidate communication must remain within institutional channels until formal Gatekeeper approval. Attempting to bypass the Gatekeeper, exchanging phone numbers, sharing social handles, or distributing confidential dossiers constitutes a material breach of contract.\n\n"
                  "3. Sovereign Gatekeeper Authority:\n"
                  "The Admin Gatekeeper holds sole discretion to approve, conditionally endorse, or decline any introduction based on psychometric evaluation, background checks, and individual interview scorecards.\n\n"
                  "4. Limitation of Matrimonial Liability:\n"
                  "DIM provides vetting, compatibility science, and lifelong pastoral shepherding. The ultimate decision to marry belongs to the couple. DIM and its directors shall not be held liable for personal matrimonial decisions or disputes.\n\n"
                  "5. Covenant Deregistration:\n"
                  "Members may request account removal at any time. Case files will be archived in accordance with statutory privacy obligations.",
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
            child: const Text("I UNDERSTAND"),
          ),
        ],
      ),
    );
  }

  static void showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.privacy_tip_outlined, color: Color(0xFFD4AF37), size: 22),
            SizedBox(width: 10),
            Text("Privacy & POPIA Vault Policy", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("POPIA & INTERNATIONAL PRIVACY VAULT STANDARDS", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                  "1. Segregated PII Architecture:\n"
                  "In accordance with the Protection of Personal Information Act (POPIA) and international standards, your real legal identity, government ID, and live facial portrait reside in a restricted, encrypted vault. They are never published in public search.\n\n"
                  "2. Anonymized Public Discovery:\n"
                  "Other candidates only see your archetypal alias, age bracket, and 5-dimension MBTI compatibility breakdown. No real names or contact details are queryable without dual mutual consent and Gatekeeper verification.\n\n"
                  "3. Biometric & Identity Verification:\n"
                  "Your uploaded government ID and facial photo are processed solely to verify that you are a real, living adult (18+). They are never shared, sold, or used for commercial advertising.\n\n"
                  "4. Forensic Watermark Protection:\n"
                  "All sensitive screens render a forensic dynamic watermark containing viewer credentials to deter and legally trace external photography.",
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
            child: const Text("I UNDERSTAND"),
          ),
        ],
      ),
    );
  }
}