import 'package:cloud_firestore/cloud_firestore.dart';

class InstitutionalInquiry {
  final String id;
  final String senderName;
  final String senderEmail;
  final String inquiryCategory; // 'Emergency Marital Counsel', 'General Question', 'Pre-Marital Inquiry'
  final String message;
  final bool isEmergency;
  final DateTime submittedAt;

  InstitutionalInquiry({
    required this.id,
    required this.senderName,
    required this.senderEmail,
    required this.inquiryCategory,
    required this.message,
    required this.isEmergency,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderName': senderName,
      'senderEmail': senderEmail,
      'inquiryCategory': inquiryCategory,
      'message': message,
      'isEmergency': isEmergency,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}

class InquiryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitInquiry({
    required String name,
    required String email,
    required String category,
    required String message,
    bool isEmergency = false,
  }) async {
    final docRef = _db.collection('institutional_inquiries').doc();
    final inquiry = InstitutionalInquiry(
      id: docRef.id,
      senderName: name.trim(),
      senderEmail: email.trim(),
      inquiryCategory: category,
      message: message.trim(),
      isEmergency: isEmergency,
      submittedAt: DateTime.now(),
    );

    await docRef.set(inquiry.toMap());
  }
}