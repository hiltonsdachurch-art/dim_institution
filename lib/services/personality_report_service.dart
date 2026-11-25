class PersonalityFullDossier {
  final String typeCode;
  final String title;
  final String introduction;
  final List<String> strengths;
  final List<String> weaknesses;
  final String romanticRelationships;
  final String parenthood;
  final String friendshipsAndHome;
  final String gatekeeperPastoralConclusion;

  const PersonalityFullDossier({
    required this.typeCode,
    required this.title,
    required this.introduction,
    required this.strengths,
    required this.weaknesses,
    required this.romanticRelationships,
    required this.parenthood,
    required this.friendshipsAndHome,
    required this.gatekeeperPastoralConclusion,
  });
}

class PersonalityReportService {
  static PersonalityFullDossier getDossier(String rawCode) {
    final cleanType = rawCode.split('-').first.toUpperCase();

    switch (cleanType) {
      case 'INFJ':
        return const PersonalityFullDossier(
          typeCode: "INFJ",
          title: "The Advocate Covenant Builder",
          introduction:
              "INFJs are guided by deeply felt convictions, quiet integrity, and an intense desire for profound marital intimacy. They do not view marriage as a pragmatic contract, but as a sacred covenant of two souls walking together.",
          strengths: [
            "Deep emotional attunement to their spouse's unspoken needs",
            "Uncompromising moral integrity and marital fidelity",
            "Creates a peaceful, sanctuary-like atmosphere in the household",
            "Passionate dedication to long-term family growth and character"
          ],
          weaknesses: [
            "Prone to bottling up marital hurts until reaching an emotional breaking point",
            "Can hold an idealized perfectionist standard for their spouse",
            "Requires extensive quiet solitude to recharge under stress",
            "Vulnerable to burnout when overburdened with emotional problems"
          ],
          romanticRelationships:
              "In romance, INFJs seek unwavering loyalty and authentic vulnerability. They do not engage in casual games. When in conflict, they need reassurance of unconditional love before they can calmly resolve practical disagreements.",
          parenthood:
              "As parents, INFJs are deeply devoted, nurturing, and intentional. They care intensely about raising children who possess strong character, compassion, and independent critical thinking. They must guard against being overly protective.",
          friendshipsAndHome:
              "Their home is a private sanctuary. While warm and hospitable to a few cherished friends, they prioritize their spouse above all social circles and avoid chaotic, superficial gatherings.",
          gatekeeperPastoralConclusion:
              "Counsel for Spouse: Never mock their intuition or dismiss their quiet sensitivity. Speak gently during disagreements and give them space to process their thoughts before expecting an immediate answer.",
        );

      case 'INTJ':
        return const PersonalityFullDossier(
          typeCode: "INTJ",
          title: "The Mastermind Strategist",
          introduction:
              "INTJs approach life and marriage with intellectual depth, strategic order, and unshakable loyalty. They take marital covenants with the utmost seriousness, providing long-term security, financial discipline, and calm leadership.",
          strengths: [
            "Exceptional long-term financial, household, and generational planning",
            "Calm, rational problem-solving during marital crises",
            "Unflinching loyalty once their covenant is made",
            "Empowers their spouse to achieve their highest personal and professional potential"
          ],
          weaknesses: [
            "May analyze feelings logically instead of offering empathetic validation",
            "Can come across as emotionally detached or overly critical under pressure",
            "Needs predictable order and struggles with sudden household disruptions",
            "Reluctant to share emotional vulnerability until complete safety is proven"
          ],
          romanticRelationships:
              "INTJs express love through dedicated action, steadfast support, and solving life's difficulties for their partner. They need a spouse who values honesty, communicates clearly without passive-aggressive games, and respects their need for quiet focus.",
          parenthood:
              "As parents, INTJs foster self-reliance, intellectual curiosity, and discipline in their children. They encourage children to think for themselves, though they must remember to balance high standards with warm, verbal affection.",
          friendshipsAndHome:
              "Their home is run with efficiency and peace. They maintain a very small, carefully chosen circle of friends and value deep, substantive conversations over small talk.",
          gatekeeperPastoralConclusion:
              "Counsel for Spouse: Do not mistake their quietness for a lack of affection. Be direct with your emotional needs rather than expecting them to guess, and praise their diligent care for the household.",
        );

      case 'ENFJ':
        return const PersonalityFullDossier(
          typeCode: "ENFJ",
          title: "The Inspiring Shepherd",
          introduction:
              "ENFJs are natural encouragers, radiant partners, and generous peacemakers. They view marriage as a partnership of uplifting their spouse, fostering hospitality, and creating a family that serves the community.",
          strengths: [
            "Abundant verbal affirmation, emotional warmth, and affection",
            "Natural peacemaker skilled at de-escalating marital friction",
            "Creates a welcoming, vibrant, hospitable home environment",
            "Relentless advocate for their partner's dreams and well-being"
          ],
          weaknesses: [
            "Can neglect their own physical and emotional health to please their spouse",
            "Extremely sensitive to perceived coldness, distance, or sharp criticism",
            "May over-manage family schedules in their desire for harmony",
            "Vulnerable to taking on emotional burdens that are not theirs to carry"
          ],
          romanticRelationships:
              "ENFJs pour their entire heart into their marriage. They need verbal appreciation and mutual emotional investment. A marriage where communication is silent or cold will cause them deep distress.",
          parenthood:
              "As parents, ENFJs create a home filled with laughter, encouragement, and clear moral values. They are their children's greatest cheerleaders and teach their household to love and serve others.",
          friendshipsAndHome:
              "Their home is an open door of warmth and hospitality. They naturally cultivate deep community ties, but they must ensure social commitments never rob their spouse of intimate, quiet evenings together.",
          gatekeeperPastoralConclusion:
              "Counsel for Spouse: Express spoken gratitude often. Notice the small sacrifices they make daily, and gently protect them from taking on too many external responsibilities.",
        );

      default:
        return PersonalityFullDossier(
          typeCode: cleanType,
          title: "The Intentional Covenant Partner ($cleanType)",
          introduction:
              "Candidates of the $cleanType archetype possess unique relational strengths designed to build an honorable, enduring home. They approach marital vows with intentionality, seeking mutual respect and character growth.",
          strengths: [
            "Dedication to mutual respect and covenant fidelity",
            "Eager to support their spouse through life's trials and milestones",
            "Committed to open dialogue and practical problem-solving",
            "Brings unique cognitive perspective to family leadership"
          ],
          weaknesses: [
            "Requires intentional self-awareness during emotional disagreements",
            "Must guard against personal blindspots under financial and marital stress",
            "Needs patience when communicating with contrasting personality types",
            "Balancing personal independence with marital interdependence"
          ],
          romanticRelationships:
              "In marriage, they seek a faithful partner who honors their core values. Open, honest communication and shared spiritual foundations allow their relationship to flourish.",
          parenthood:
              "Dedicated to providing stability, character mentorship, and unconditional love to children within a secure household.",
          friendshipsAndHome:
              "Builds a home grounded in integrity, welcoming trusted friends while prioritizing the marital union above all outside influences.",
          gatekeeperPastoralConclusion:
              "Counsel for Spouse: Invest time into understanding their unique cognitive gifts and give them grace as you grow together into one covenant household.",
        );
    }
  }
}