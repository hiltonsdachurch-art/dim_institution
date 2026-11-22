import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Family requests an appointment
  Future<void> bookAppointment({
    required String familyId,
    required String familyName,
    required String contactEmail,
    required MeetingPlatform platform,
    required DateTime proposedDateTime,
    required String agendaTopic,
  }) async {
    final docRef = _db.collection('appointments').doc();
    final appointment = AppointmentBooking(
      id: docRef.id,
      familyId: familyId,
      familyName: familyName,
      contactEmail: contactEmail,
      platform: platform,
      proposedDateTime: proposedDateTime,
      agendaTopic: agendaTopic,
      status: AppointmentStatus.pendingAdminAcceptance,
      createdAt: DateTime.now(),
    );

    await docRef.set(appointment.toMap());
  }

  // 2. Admin accepts & confirms appointment with link
  Future<void> confirmAppointment({
    required String appointmentId,
    required String meetingUrl,
    String? adminNotes,
  }) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.confirmed.name,
      'meetingUrl': meetingUrl,
      'adminNotes': adminNotes,
    });
  }

  // 3. Admin suggests an alternative date/time
  Future<void> proposeAlternativeTime({
    required String appointmentId,
    required DateTime newDateTime,
    String? adminNotes,
  }) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': AppointmentStatus.rescheduleProposedByAdmin.name,
      'adminSuggestedDateTime': newDateTime.toIso8601String(),
      'adminNotes': adminNotes,
    });
  }

  // 4. Family accepts Admin's proposed alternative time
  Future<void> familyAcceptReschedule({
    required String appointmentId,
    required DateTime agreedDateTime,
  }) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'proposedDateTime': agreedDateTime.toIso8601String(),
      'status': AppointmentStatus.confirmed.name,
      'adminSuggestedDateTime': null,
    });
  }

  // Stream appointments for a single family
  Stream<List<AppointmentBooking>> getFamilyAppointmentsStream(String familyId) {
    return _db
        .collection('appointments')
        .where('familyId', isEqualTo: familyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => AppointmentBooking.fromMap(d.data(), d.id))
          .toList();
    });
  }

  // Stream all pending/active appointments for Admin Cockpit
  Stream<List<AppointmentBooking>> getAllAppointmentsStream() {
    return _db.collection('appointments').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((d) => AppointmentBooking.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}