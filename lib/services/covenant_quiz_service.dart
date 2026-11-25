enum PersonalityDimension {
  mind,     // E vs I (Extraverted vs Introverted)
  energy,   // S vs N (Observant vs Intuitive)
  nature,   // T vs F (Thinking vs Feeling)
  tactics,  // J vs P (Judging vs Prospecting)
  identity, // A vs T (Assertive vs Turbulent)
}

class LikertQuestion {
  final int id;
  final String text;
  final PersonalityDimension dimension;
  final bool positivePointsToFirstTrait; // true = positive score gives first trait (e.g. E, S, T, J, A)

  const LikertQuestion({
    required this.id,
    required this.text,
    required this.dimension,
    required this.positivePointsToFirstTrait,
  });
}

class PersonalityCalculationResult {
  final String fullCode; // e.g. "INFJ-A"
  final String fourLetterType; // e.g. "INFJ"
  final String identityTrait; // e.g. "Assertive (A)" or "Turbulent (T)"
  final int mindExtraversionPct; // 0 to 100
  final int energyIntuitionPct;
  final int natureFeelingPct;
  final int tacticsJudgingPct;
  final int identityAssertivePct;

  PersonalityCalculationResult({
    required this.fullCode,
    required this.fourLetterType,
    required this.identityTrait,
    required this.mindExtraversionPct,
    required this.energyIntuitionPct,
    required this.natureFeelingPct,
    required this.tacticsJudgingPct,
    required this.identityAssertivePct,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullCode': fullCode,
      'fourLetterType': fourLetterType,
      'identityTrait': identityTrait,
      'mindExtraversionPct': mindExtraversionPct,
      'energyIntuitionPct': energyIntuitionPct,
      'natureFeelingPct': natureFeelingPct,
      'tacticsJudgingPct': tacticsJudgingPct,
      'identityAssertivePct': identityAssertivePct,
    };
  }
}

class CovenantQuizService {
  static const List<LikertQuestion> questions = [
    // --- MIND: Extraversion (E) vs Introversion (I) ---
    LikertQuestion(id: 1, text: "You regularly initiate conversations with people when attending community gatherings.", dimension: PersonalityDimension.mind, positivePointsToFirstTrait: true),
    LikertQuestion(id: 2, text: "After a demanding week, you need complete solitude to feel emotionally renewed.", dimension: PersonalityDimension.mind, positivePointsToFirstTrait: false),
    LikertQuestion(id: 3, text: "You feel comfortable speaking your thoughts openly in a group of unfamiliar people.", dimension: PersonalityDimension.mind, positivePointsToFirstTrait: true),
    LikertQuestion(id: 4, text: "You prefer spending a quiet evening at home with a book or partner over a lively party.", dimension: PersonalityDimension.mind, positivePointsToFirstTrait: false),

    // --- ENERGY: Observant (S) vs Intuitive (N) ---
    LikertQuestion(id: 5, text: "You frequently ponder the deeper philosophical meaning and future possibilities of life.", dimension: PersonalityDimension.energy, positivePointsToFirstTrait: false),
    LikertQuestion(id: 6, text: "You rely heavily on concrete facts, past experiences, and proven routines to feel secure.", dimension: PersonalityDimension.energy, positivePointsToFirstTrait: true),
    LikertQuestion(id: 7, text: "You are fascinated by 'what-if' scenarios, abstract theories, and visionary concepts.", dimension: PersonalityDimension.energy, positivePointsToFirstTrait: false),
    LikertQuestion(id: 8, text: "You prioritize practical day-to-day details over grand, unproven long-term dreams.", dimension: PersonalityDimension.energy, positivePointsToFirstTrait: true),

    // --- NATURE: Thinking (T) vs Feeling (F) ---
    LikertQuestion(id: 9, text: "In any conflict, truth, justice, and logical fairness should matter more than protecting feelings.", dimension: PersonalityDimension.nature, positivePointsToFirstTrait: true),
    LikertQuestion(id: 10, text: "You instinctively tune into how people around you are feeling and prioritize emotional harmony.", dimension: PersonalityDimension.nature, positivePointsToFirstTrait: false),
    LikertQuestion(id: 11, text: "You make important life decisions using objective pros and cons rather than personal sentiments.", dimension: PersonalityDimension.nature, positivePointsToFirstTrait: true),
    LikertQuestion(id: 12, text: "You find it difficult to deliver necessary criticism if you know it might hurt someone's heart.", dimension: PersonalityDimension.nature, positivePointsToFirstTrait: false),

    // --- TACTICS: Judging (J) vs Prospecting (P) ---
    LikertQuestion(id: 13, text: "You feel most peaceful when your schedule, budget, and commitments are clearly planned in advance.", dimension: PersonalityDimension.tactics, positivePointsToFirstTrait: true),
    LikertQuestion(id: 14, text: "You thrive on spontaneity and prefer keeping your options open rather than sticking to a rigid plan.", dimension: PersonalityDimension.tactics, positivePointsToFirstTrait: false),
    LikertQuestion(id: 15, text: "You rarely leave important tasks until the last minute and finish commitments early.", dimension: PersonalityDimension.tactics, positivePointsToFirstTrait: true),
    LikertQuestion(id: 16, text: "You easily adapt when unexpected disruptions suddenly derail your plans for the day.", dimension: PersonalityDimension.tactics, positivePointsToFirstTrait: false),

    // --- IDENTITY: Assertive (-A) vs Turbulent (-T) ---
    LikertQuestion(id: 17, text: "You rarely second-guess your past choices and remain calm under intense marital or family pressure.", dimension: PersonalityDimension.identity, positivePointsToFirstTrait: true),
    LikertQuestion(id: 18, text: "You frequently worry about whether you are doing enough and can be overly self-critical.", dimension: PersonalityDimension.identity, positivePointsToFirstTrait: false),
    LikertQuestion(id: 19, text: "You bounce back very quickly after experiencing emotional distress, rejection, or disappointment.", dimension: PersonalityDimension.identity, positivePointsToFirstTrait: true),
    LikertQuestion(id: 20, text: "You are deeply sensitive to criticism from people you love and replay mistakes in your mind.", dimension: PersonalityDimension.identity, positivePointsToFirstTrait: false),
  ];

  static PersonalityCalculationResult calculate(Map<int, int> userAnswers) {
    int mindScore = 0;
    int energyScore = 0;
    int natureScore = 0;
    int tacticsScore = 0;
    int identityScore = 0;

    int mindMax = 0, energyMax = 0, natureMax = 0, tacticsMax = 0, identityMax = 0;

    for (final q in questions) {
      final score = userAnswers[q.id] ?? 0; // -3 to +3
      final directionalScore = q.positivePointsToFirstTrait ? score : -score;

      switch (q.dimension) {
        case PersonalityDimension.mind:
          mindScore += directionalScore;
          mindMax += 3;
          break;
        case PersonalityDimension.energy:
          energyScore += directionalScore;
          energyMax += 3;
          break;
        case PersonalityDimension.nature:
          natureScore += directionalScore;
          natureMax += 3;
          break;
        case PersonalityDimension.tactics:
          tacticsScore += directionalScore;
          tacticsMax += 3;
          break;
        case PersonalityDimension.identity:
          identityScore += directionalScore;
          identityMax += 3;
          break;
      }
    }

    // Convert -Max..+Max scale to 0..100 percentage
    int toPct(int score, int max) => (((score + max) / (2 * max)) * 100).round().clamp(0, 100);

    final int extraversionPct = toPct(mindScore, mindMax);
    final int sensingPct = toPct(energyScore, energyMax);
    final int thinkingPct = toPct(natureScore, natureMax);
    final int judgingPct = toPct(tacticsScore, tacticsMax);
    final int assertivePct = toPct(identityScore, identityMax);

    final String letter1 = extraversionPct >= 50 ? 'E' : 'I';
    final String letter2 = sensingPct >= 50 ? 'S' : 'N';
    final String letter3 = thinkingPct >= 50 ? 'T' : 'F';
    final String letter4 = judgingPct >= 50 ? 'J' : 'P';
    final String letter5 = assertivePct >= 50 ? 'A' : 'T';

    final String fourLetter = "$letter1$letter2$letter3$letter4";
    final String fullCode = "$fourLetter-$letter5";

    return PersonalityCalculationResult(
      fullCode: fullCode,
      fourLetterType: fourLetter,
      identityTrait: letter5 == 'A' ? 'Assertive' : 'Turbulent',
      mindExtraversionPct: extraversionPct,
      energyIntuitionPct: 100 - sensingPct, // Intuition percentage
      natureFeelingPct: 100 - thinkingPct,   // Feeling percentage
      tacticsJudgingPct: judgingPct,
      identityAssertivePct: assertivePct,
    );
  }
}