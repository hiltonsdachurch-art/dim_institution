class DirectChatThread {
  final String id;
  final List<String> participants;
  final Map<String, String> participantAliases;
  final String lastMessage;
  final DateTime lastTimestamp;

  DirectChatThread({
    required this.id,
    required this.participants,
    required this.participantAliases,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantAliases': participantAliases,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp.toIso8601String(),
    };
  }

  factory DirectChatThread.fromMap(Map<String, dynamic> map, String docId) {
    return DirectChatThread(
      id: docId,
      participants: List<String>.from(map['participants'] ?? []),
      participantAliases: Map<String, String>.from(map['participantAliases'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastTimestamp: DateTime.tryParse(map['lastTimestamp'] ?? '') ?? DateTime.now(),
    );
  }

  String getOtherAlias(String currentUid) {
    for (final entry in participantAliases.entries) {
      if (entry.key != currentUid) return entry.value;
    }
    return 'Candidate';
  }

  String getOtherUid(String currentUid) {
    for (final uid in participants) {
      if (uid != currentUid) return uid;
    }
    return '';
  }
}