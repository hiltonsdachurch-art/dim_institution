enum AppointmentStatus {
  pendingAdminAcceptance,
  confirmed,
  rescheduleProposedByAdmin,
  completed,
  canceled,
}

enum MeetingPlatform {
  microsoftTeams,
  zoom,
}

class AppointmentBooking {
  final String id;
  final String familyId;
  final String familyName;
  final String contactEmail;
  final MeetingPlatform platform;
  final DateTime proposedDateTime;
  final DateTime? adminSuggestedDateTime;
  final String agendaTopic;
  final AppointmentStatus status;
  final String? meetingUrl;
  final String? adminNotes;
  final DateTime createdAt;

  AppointmentBooking({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.contactEmail,
    required this.platform,
    required this.proposedDateTime,
    this.adminSuggestedDateTime,
    required this.agendaTopic,
    required this.status,
    this.meetingUrl,
    this.adminNotes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'familyId': familyId,
      'familyName': familyName,
      'contactEmail': contactEmail,
      'platform': platform.name,
      'proposedDateTime': proposedDateTime.toIso8601String(),
      'adminSuggestedDateTime': adminSuggestedDateTime?.toIso8601String(),
      'agendaTopic': agendaTopic,
      'status': status.name,
      'meetingUrl': meetingUrl,
      'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentBooking.fromMap(Map<String, dynamic> map, String docId) {
    return AppointmentBooking(
      id: docId,
      familyId: map['familyId'] ?? '',
      familyName: map['familyName'] ?? 'Family',
      contactEmail: map['contactEmail'] ?? '',
      platform: MeetingPlatform.values.firstWhere(
        (e) => e.name == map['platform'],
        orElse: () => MeetingPlatform.zoom,
      ),
      proposedDateTime: DateTime.tryParse(map['proposedDateTime'] ?? '') ?? DateTime.now(),
      adminSuggestedDateTime: map['adminSuggestedDateTime'] != null
          ? DateTime.tryParse(map['adminSuggestedDateTime'])
          : null,
      agendaTopic: map['agendaTopic'] ?? 'General Pastoral Advisory',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pendingAdminAcceptance,
      ),
      meetingUrl: map['meetingUrl'],
      adminNotes: map['adminNotes'],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}