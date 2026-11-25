import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/family_model.dart';
import '../models/appointment_model.dart';
import '../models/payment_model.dart';
import '../services/family_service.dart';
import '../services/appointment_service.dart';
import '../services/sound_service.dart';
import 'institutional_home_screen.dart';
import 'personality_report_screen.dart';
import 'payment_checkout_screen.dart';

class FamilyDashboardScreen extends StatefulWidget {
  final String familyId;

  const FamilyDashboardScreen({super.key, required this.familyId});

  @override
  State<FamilyDashboardScreen> createState() => _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState extends State<FamilyDashboardScreen> {
  final FamilyService _familyService = FamilyService();
  final AppointmentService _appointmentService = AppointmentService();

  final String _adminWhatsAppNumber = "+27820000000";
  final String _adminPhoneNumber = "+27820000000";
  final String _adminEmail = "shepherd@dim.institution";

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse("https://wa.me/${_adminWhatsAppNumber.replaceAll('+', '')}?text=Hello%20DIM%20Shepherd,%20this%20is%20from%20our%20Family%20Covenant%20Profile.");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall() async {
    final uri = Uri.parse("tel:$_adminPhoneNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse("mailto:$_adminEmail?subject=DIM%20Family%20Covenant%20Consultation");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openTier3RenewalModal(FamilyProfile family) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentCheckoutScreen(
        tier: PaymentTier.tier3ShepherdMonthly,
        referenceId: family.id,
        payerUid: FirebaseAuth.instance.currentUser?.uid ?? 'family_uid',
        payerAlias: family.familyName,
        onPaymentSuccessful: () => setState(() {}),
      ),
    );
  }

  void _showBookAppointmentDialog(FamilyProfile family) {
    MeetingPlatform platform = MeetingPlatform.zoom;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = const TimeOfDay(hour: 15, minute: 0);
    final agendaController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.video_camera_front_outlined, color: Color(0xFFD4AF37), size: 24),
              SizedBox(width: 10),
              Text("Schedule Shepherd Advisory", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Platform Selection:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setModalState(() => platform = MeetingPlatform.zoom),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: platform == MeetingPlatform.zoom ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: platform == MeetingPlatform.zoom ? const Color(0xFFD4AF37) : Colors.white24),
                          ),
                          child: Center(child: Text("Zoom Meeting", style: TextStyle(color: platform == MeetingPlatform.zoom ? const Color(0xFFD4AF37) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setModalState(() => platform = MeetingPlatform.microsoftTeams),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: platform == MeetingPlatform.microsoftTeams ? const Color(0xFFD4AF37).withOpacity(0.2) : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: platform == MeetingPlatform.microsoftTeams ? const Color(0xFFD4AF37) : Colors.white24),
                          ),
                          child: Center(child: Text("Microsoft Teams", style: TextStyle(color: platform == MeetingPlatform.microsoftTeams ? const Color(0xFFD4AF37) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Text("Proposed Date & Time:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (d != null) {
                      final t = await showTimePicker(context: context, initialTime: selectedTime);
                      if (t != null) {
                        setModalState(() {
                          selectedDate = d;
                          selectedTime = t;
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${selectedDate.toIso8601String().substring(0, 10)} at ${selectedTime.format(context)}", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: agendaController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: "Advisory Agenda / Topic",
                    hintText: "e.g., Annual Check-in, Financial realignment, Communication mediation...",
                    filled: true,
                    fillColor: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
                await _appointmentService.bookAppointment(
                  familyId: family.id,
                  familyName: family.familyName,
                  contactEmail: FirebaseAuth.instance.currentUser?.email ?? 'family@dim.institution',
                  platform: platform,
                  proposedDateTime: dt,
                  agendaTopic: agendaController.text.trim().isNotEmpty ? agendaController.text.trim() : "General Pastoral Guidance",
                );
                await SoundService.playCelebrationChime();
                if (!context.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Appointment Requested. Awaiting Gatekeeper confirmation."), backgroundColor: Color(0xFF10B981)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
              child: const Text("REQUEST APPOINTMENT"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: const [
            Icon(Icons.shield, color: Color(0xFFD4AF37), size: 22),
            SizedBox(width: 10),
            Text("DIM COVENANT HOUSEHOLD", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            tooltip: "Sign Out",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const InstitutionalHomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<FamilyProfile?>(
        stream: _familyService.getFamilyStream(widget.familyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          final family = snapshot.data;
          if (family == null) {
            return const Center(child: Text("Family record not found.", style: TextStyle(color: Colors.white54)));
          }

          final bool isShepherded = family.membershipTier == DimMembershipTier.shepherdedFamilyMember;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Household Header Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                            ),
                            child: const Center(child: Icon(Icons.favorite, color: Color(0xFFD4AF37), size: 32)),
                          ),
                          const SizedBox(height: 14),
                          Text(family.familyName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text("Wedding Anniversary: ${family.weddingDate.toIso8601String().substring(0, 10)}", style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          Text("“${family.familyVisionStatement}”", textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // TIER 3 SHEPHERD MEMBERSHIP STATUS & R199 BILLING CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isShepherded ? const Color(0xFF10B981) : Colors.white24,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(isShepherded ? Icons.verified : Icons.lock_outline, color: isShepherded ? const Color(0xFF34D399) : Colors.white38, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    isShepherded ? "TIER 3: ACTIVE SHEPHERD MEMBERSHIP" : "INDEPENDENT COVENANT (INACTIVE TIER 3)",
                                    style: TextStyle(color: isShepherded ? const Color(0xFF34D399) : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                              Text("R199 / month", style: TextStyle(color: isShepherded ? const Color(0xFFD4AF37) : Colors.white38, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isShepherded
                                ? "Your household has 24/7 priority pastoral access: WhatsApp direct line, phone consultations, emergency dispute mediation, and annual covenant check-ins."
                                : "Your household is currently navigating independently. Subscribe to Tier 3 to unlock direct WhatsApp and video advisory.",
                            style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                          ),
                          const SizedBox(height: 12),

                          if (!isShepherded)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _openTier3RenewalModal(family),
                                icon: const Icon(Icons.star, size: 16),
                                label: const Text("ACTIVATE TIER 3 MEMBERSHIP (R199/MO)"),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // DIRECT ADMIN CONTACT HUB (Active if Tier 3 is subscribed)
                    if (isShepherded) ...[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.headset_mic_outlined, color: Color(0xFFD4AF37), size: 18),
                                SizedBox(width: 8),
                                Text("DIRECT SHEPHERD ASSISTANCE", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _openWhatsApp,
                                    icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                                    label: const Text("WhatsApp", style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _makePhoneCall,
                                    icon: const Icon(Icons.phone, size: 16, color: Color(0xFFD4AF37)),
                                    label: const Text("Direct Call", style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _sendEmail,
                                    icon: const Icon(Icons.email, size: 16, color: Colors.blueAccent),
                                    label: const Text("Email", style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // APPOINTMENT SCHEDULER SECTION
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("PASTORAL ADVISORY APPOINTMENTS", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                                  SizedBox(height: 2),
                                  Text("Zoom & Microsoft Teams Consultations", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: isShepherded ? () => _showBookAppointmentDialog(family) : () => _openTier3RenewalModal(family),
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text("BOOK SESSION", style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          StreamBuilder<List<AppointmentBooking>>(
                            stream: _appointmentService.getFamilyAppointmentsStream(family.id),
                            builder: (ctx, appSnap) {
                              final appointments = appSnap.data ?? [];
                              if (appointments.isEmpty) {
                                return const Text("No advisory appointments scheduled. Click 'Book Session' to request advisory.", style: TextStyle(color: Colors.white38, fontSize: 12));
                              }

                              return Column(
                                children: appointments.map((apt) => _buildAppointmentTile(apt)).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // SPOUSAL PSYCHOMETRICS
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("SPOUSAL RELATIONSHIP PROFILES", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("HUSBAND", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text(family.spouseAName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text("Type: ${family.spouseAMbti}", style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PersonalityReportScreen(
                                                personName: "${family.spouseAName} (Husband)",
                                                fullCode: family.spouseAMbti,
                                                scorePercentages: family.spouseAScores,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: const Color(0xFFD4AF37)),
                                        child: const Text("VIEW REPORT", style: TextStyle(fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("WIFE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text(family.spouseBName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text("Type: ${family.spouseBMbti}", style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PersonalityReportScreen(
                                                personName: "${family.spouseBName} (Wife)",
                                                fullCode: family.spouseBMbti,
                                                scorePercentages: family.spouseBScores,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: const Color(0xFFD4AF37)),
                                        child: const Text("VIEW REPORT", style: TextStyle(fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentTile(AppointmentBooking apt) {
    Color badgeColor = Colors.amber;
    String statusLabel = "AWAITING GATEKEEPER CONFIRMATION";

    if (apt.status == AppointmentStatus.confirmed) {
      badgeColor = const Color(0xFF10B981);
      statusLabel = "CONFIRMED";
    } else if (apt.status == AppointmentStatus.rescheduleProposedByAdmin) {
      badgeColor = Colors.orangeAccent;
      statusLabel = "ADMIN PROPOSED NEW DATE/TIME";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${apt.platform.name == 'microsoftTeams' ? 'Microsoft Teams' : 'Zoom'} Session",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: badgeColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text(statusLabel, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text("Requested: ${apt.proposedDateTime.toIso8601String().substring(0, 16).replaceAll('T', ' ')}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text("Agenda: ${apt.agendaTopic}", style: const TextStyle(color: Colors.white38, fontSize: 11)),

          if (apt.status == AppointmentStatus.rescheduleProposedByAdmin && apt.adminSuggestedDateTime != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin proposed alternative time:\n${apt.adminSuggestedDateTime!.toIso8601String().substring(0, 16).replaceAll('T', ' ')}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _appointmentService.familyAcceptReschedule(
                        appointmentId: apt.id,
                        agreedDateTime: apt.adminSuggestedDateTime!,
                      );
                      await SoundService.playCelebrationChime();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                    child: const Text("ACCEPT ALTERNATIVE TIME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}