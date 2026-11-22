import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class DlpSecurityViolationException implements Exception {
  final String message;
  DlpSecurityViolationException(this.message);

  @override
  String toString() => message;
}

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time DLP (Data Loss Prevention) Sanitizer
  void enforceAntiLeakDlp(String text) {
    final lower = text.toLowerCase();

    // 1. Phone Number Detection (Digits with dashes, spaces, brackets, or international formats)
    final phoneRegex = RegExp(
      r'(\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\b\d{7,12}\b',
    );
    if (phoneRegex.hasMatch(text.replaceAll(RegExp(r'\s+'), ''))) {
      throw DlpSecurityViolationException(
        "ANTI-LEAK SHIELD: Sharing telephone numbers is strictly prohibited prior to Gatekeeper Endorsement.",
      );
    }

    // 2. Email Address Detection
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    if (emailRegex.hasMatch(text)) {
      throw DlpSecurityViolationException(
        "ANTI-LEAK SHIELD: Sharing private email addresses is blocked by Institutional Security.",
      );
    }

    // 3. Social Media & Off-Platform Keywords
    final socialKeywords = [
      'whatsapp',
      'telegram',
      'instagram',
      'insta',
      'snapchat',
      'facebook',
      'tiktok',
      'signal',
      'dm me',
      'call me',
      'text me',
      'my number',
      'my handle',
    ];

    for (final keyword in socialKeywords) {
      if (lower.contains(keyword)) {
        throw DlpSecurityViolationException(
          "ANTI-LEAK SHIELD: External platform reference detected ('$keyword'). Communication must remain within the institution.",
        );
      }
    }

    // 4. Handle Mentions (@username)
    final handleRegex = RegExp(r'@[a-zA-Z0-9_]{3,}');
    if (handleRegex.hasMatch(text)) {
      throw DlpSecurityViolationException(
        "ANTI-LEAK SHIELD: Social handles (@) are blocked. You must converse via character and values only.",
      );
    }
  }

  // Stream messages for a specific introduction pair
  Stream<List<ChatMessage>> getMessagesStream(String introId) {
    return _db
        .collection('introductions')
        .doc(introId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Send message with DLP guard
  Future<void> sendMessage({
    required String introId,
    required String senderUid,
    required String senderAlias,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Run Data Loss Prevention inspection
    enforceAntiLeakDlp(trimmed);

    final docRef = _db
        .collection('introductions')
        .doc(introId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: docRef.id,
      senderUid: senderUid,
      senderAlias: senderAlias,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    await docRef.set(message.toMap());
  }
}