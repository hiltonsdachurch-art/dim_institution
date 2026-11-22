class ChatMessage {
  final String id;
  final String senderUid;
  final String senderAlias;
  final String text;
  final DateTime timestamp;
  final bool isSystemNotice;

  ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderAlias,
    required this.text,
    required this.timestamp,
    this.isSystemNotice = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderUid': senderUid,
      'senderAlias': senderAlias,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSystemNotice': isSystemNotice,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessage(
      id: docId,
      senderUid: map['senderUid'] ?? '',
      senderAlias: map['senderAlias'] ?? 'Anonymous Candidate',
      text: map['text'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isSystemNotice: map['isSystemNotice'] ?? false,
    );
  }
}