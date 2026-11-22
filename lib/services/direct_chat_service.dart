import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/direct_chat_model.dart';
import 'chat_service.dart';

class DirectChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ChatService _dlpService = ChatService();

  // Deterministic chat ID so two users always share the exact same thread
  static String getDirectChatId(String uidA, String uidB) {
    final list = [uidA, uidB]..sort();
    return "${list[0]}_${list[1]}";
  }

  // Retrieve or create direct chat thread
  Future<DirectChatThread> getOrCreateDirectThread({
    required String currentUid,
    required String currentAlias,
    required String targetUid,
    required String targetAlias,
  }) async {
    final chatId = getDirectChatId(currentUid, targetUid);
    final docRef = _db.collection('direct_chats').doc(chatId);
    final doc = await docRef.get();

    if (doc.exists) {
      return DirectChatThread.fromMap(doc.data()!, doc.id);
    }

    final newThread = DirectChatThread(
      id: chatId,
      participants: [currentUid, targetUid],
      participantAliases: {
        currentUid: currentAlias,
        targetUid: targetAlias,
      },
      lastMessage: 'Conversation opened.',
      lastTimestamp: DateTime.now(),
    );

    await docRef.set(newThread.toMap());
    return newThread;
  }

  // Send 1-on-1 message with DLP check
  Future<void> sendDirectMessage({
    required String chatId,
    required String senderUid,
    required String senderAlias,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // 1. Intercept phone numbers, emails, and social handles
    _dlpService.enforceAntiLeakDlp(trimmed);

    // 2. Add message to direct_chats/{chatId}/messages
    final msgRef = _db
        .collection('direct_chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgRef.id,
      senderUid: senderUid,
      senderAlias: senderAlias,
      text: trimmed,
      timestamp: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(msgRef, message.toMap());

    // Update parent thread summary
    final threadRef = _db.collection('direct_chats').doc(chatId);
    batch.update(threadRef, {
      'lastMessage': trimmed,
      'lastTimestamp': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  // Stream messages for a specific direct chat
  Stream<List<ChatMessage>> getDirectMessagesStream(String chatId) {
    return _db
        .collection('direct_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => ChatMessage.fromMap(d.data(), d.id))
          .toList();
    });
  }

  // Stream all direct threads for a candidate
  Stream<List<DirectChatThread>> getUserDirectThreadsStream(String currentUid) {
    return _db
        .collection('direct_chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((d) => DirectChatThread.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));
      return list;
    });
  }
}