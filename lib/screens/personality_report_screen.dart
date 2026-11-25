import 'package:flutter/material.dart';
import '../services/personality_report_service.dart';

class PersonalityReportScreen extends StatelessWidget {
  final String personName;
  final String fullCode; // e.g. "INFJ-A"
  final Map<String, dynamic>? scorePercentages;

  const PersonalityReportScreen({
    super.key,
    required this.personName,
    required this.fullCode,
    this.scorePercentages,
  });

  @override
  Widget build(BuildContext context) {
    final dossier = PersonalityReportService.getDossier(fullCode);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            "$personName • $fullCode REPORT",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Color(0xFFD4AF37),
            labelColor: Color(0xFFD4AF37),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: "1. Overview"),
              Tab(text: "2. Strengths"),
              Tab(text: "3. Romance"),
              Tab(text: "4. Parenthood"),
              Tab(text: "5. Home & Friends"),
              Tab(text: "6. Pastoral Advice"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context, dossier),
            _buildStrengthsTab(dossier),
            _buildTextTab("Romantic Relationships & Marriage", Icons.favorite, dossier.romanticRelationships),
            _buildTextTab("Parenthood & Raising Children", Icons.family_restroom, dossier.parenthood),
            _buildTextTab("Household Harmony & Social Life", Icons.house, dossier.friendshipsAndHome),
            _buildTextTab("Gatekeeper Pastoral Shepherding Advice", Icons.volunteer_activism, dossier.gatekeeperPastoralConclusion),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, PersonalityFullDossier dossier) {
    final pcts = scorePercentages ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crest
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Text(
                        fullCode,
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 1.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(dossier.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Introduction
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                child: Text(dossier.introduction, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
              ),
              const SizedBox(height: 24),

              // 5 Dimension Bars
              const Text("5-DIMENSION PSYCHOMETRIC SPECTRUM", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 14),
              _buildSpectrumBar("Mind", "Extraverted (E)", "Introverted (I)", (pcts['mindExtraversionPct'] as num?)?.toInt() ?? 50),
              _buildSpectrumBar("Energy", "Intuitive (N)", "Observant (S)", (pcts['energyIntuitionPct'] as num?)?.toInt() ?? 50),
              _buildSpectrumBar("Nature", "Feeling (F)", "Thinking (T)", (pcts['natureFeelingPct'] as num?)?.toInt() ?? 50),
              _buildSpectrumBar("Tactics", "Judging (J)", "Prospecting (P)", (pcts['tacticsJudgingPct'] as num?)?.toInt() ?? 50),
              _buildSpectrumBar("Identity", "Assertive (-A)", "Turbulent (-T)", (pcts['identityAssertivePct'] as num?)?.toInt() ?? 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpectrumBar(String dimension, String leftTrait, String rightTrait, int leftPct) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$leftTrait: $leftPct%", style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
              Text("$rightTrait: ${100 - leftPct}%", style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: leftPct / 100.0,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsTab(PersonalityFullDossier dossier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("COVENANT STRENGTHS", style: TextStyle(color: Color(0xFF34D399), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              ...dossier.strengths.map((s) => _buildBullet(s, const Color(0xFF34D399))),
              const SizedBox(height: 28),

              const Text("RELATIONAL BLINDSPOTS & WEAKNESSES", style: TextStyle(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              ...dossier.weaknesses.map((w) => _buildBullet(w, const Color(0xFFFBBF24))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildTextTab(String title, IconData icon, String body) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFFD4AF37), size: 24),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}