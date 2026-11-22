class MarriagePersonalityInsight {
  final String archetypeTitle;
  final String covenantPhilosophy;
  final List<String> maritalStrengths;
  final List<String> relationalGrowthAreas;
  final String communicationStyle;

  const MarriagePersonalityInsight({
    required this.archetypeTitle,
    required this.covenantPhilosophy,
    required this.maritalStrengths,
    required this.relationalGrowthAreas,
    required this.communicationStyle,
  });
}

class MbtiKnowledgeService {
  static MarriagePersonalityInsight getInsight(String mbti) {
    switch (mbti.toUpperCase()) {
      case 'INTJ':
        return const MarriagePersonalityInsight(
          archetypeTitle: "The Mastermind Covenant Builder",
          covenantPhilosophy: "Approaches marriage with unwavering loyalty, strategic family vision, and deep private devotion.",
          maritalStrengths: [
            "Fiercely committed; views marriage vows as an unbreakable covenant",
            "Exceptional long-term financial and family planning",
            "Solves marital problems with objective, calm clarity"
          ],
          relationalGrowthAreas: [
            "May analyze emotions logically instead of offering immediate empathetic warmth",
            "Needs dedicated periods of quiet decompression to recharge"
          ],
          communicationStyle: "Direct, concise, honest, and solution-focused.",
        );
      case 'INFJ':
        return const MarriagePersonalityInsight(
          archetypeTitle: "The Devoted Soul Anchor",
          covenantPhilosophy: "Seeks profound spiritual and emotional oneness, serving the marriage with quiet selflessness.",
          maritalStrengths: [
            "Deeply attuned to their partner's unspoken emotional needs",
            "Creates a peaceful, sanctuary-like atmosphere in the home",
            "Enduring dedication to mutual character growth"
          ],
          relationalGrowthAreas: [
            "Prone to keeping emotional grievances inside until overwhelmed",
            "May set perfectionist standards for marital harmony"
          ],
          communicationStyle: "Gentle, deeply empathetic, poetic, and reflective.",
        );
      case 'ENFJ':
        return const MarriagePersonalityInsight(
          archetypeTitle: "The Compassionate Guardian",
          covenantPhilosophy: "Marriage is a joyful partnership of encouragement, hospitality, and lifting each other up.",
          maritalStrengths: [
            "Inspires their spouse through constant affirmation and vocal appreciation",
            "Natural peacemaker and hospitable home host",
            "Generous with warmth, affection, and active service"
          ],
          relationalGrowthAreas: [
            "Can overextend themselves serving others at the expense of marital rest",
            "Sensitive to perceived emotional coldness or conflict"
          ],
          communicationStyle: "Warm, highly expressive, affirming, and inspiring.",
        );
      case 'ENTJ':
        return const MarriagePersonalityInsight(
          archetypeTitle: "The Sovereign Enterprise Partner",
          covenantPhilosophy: "Views marriage as the ultimate team covenant—building generational legacy, wealth, and honor.",
          maritalStrengths: [
            "Protective, decisive, and ambitious provider",
            "Faces adversity with relentless courage and resilience",
            "Pushes the entire household toward excellence"
          ],
          relationalGrowthAreas: [
            "Needs to balance high ambition with unhurried tenderness at home",
            "May inadvertently take command of shared household decisions"
          ],
          communicationStyle: "Assertive, visionary, clear, and direct.",
        );
      case 'ISFJ':
        return const MarriagePersonalityInsight(
          archetypeTitle: "The Steadfast Hearth Protector",
          covenantPhilosophy: "Finds sacred joy in practical daily devotion, unwavering fidelity, and creating a stable sanctuary.",
          maritalStrengths: [
            "Unrivaled loyalty and attentiveness to household harmony",
            "Remembers every small detail that makes their spouse feel cherished",
            "Dependable, calm, and deeply family-oriented"
          ],
          relationalGrowthAreas: [
            "May avoid necessary conflict to preserve superficial peace",
            "Can neglect personal boundaries out of sacrificial devotion"
          ],
          communicationStyle: "Supportive, thoughtful, practical, and considerate.",
        );
      default:
        return MarriagePersonalityInsight(
          archetypeTitle: "The Intentional Covenant Partner ($mbti)",
          covenantPhilosophy: "Committed to building an honorable home grounded in shared values, mutual respect, and intentionality.",
          maritalStrengths: [
            "Dedication to mutual character growth and fidelity",
            "Desire to honor their spouse in daily routines and life milestones",
            "Committed to open dialogue and spiritual alignment"
          ],
          relationalGrowthAreas: [
            "Balancing personal preferences with sacrificial love",
            "Maintaining proactive communication under external pressures"
          ],
          communicationStyle: "Authentic, respectful, and values-centered.",
        );
    }
  }
}