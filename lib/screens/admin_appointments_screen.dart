import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/sound_service.dart';

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  void _showConfirmDialog(BuildContext context, AppointmentBooking apt, AppointmentService service) {
    final linkController = TextEditingController(text: "https://zoom.us/j/dim-pastoral-room");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Confirm & Provide Meeting Link", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: linkController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(labelText: "Zoom or Teams Meeting URL", filled: true, fillColor: Color(0xFF0F172A)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              await service.confirmAppointment(
                appointmentId: apt.id,
                meetingUrl: linkController.text.trim(),
                adminNotes: "Meeting confirmed by Admin Gatekeeper.",
              );
              await SoundService.playCelebrationChime();
              if (!context.mounted) return;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
            child: const Text("CONFIRM SESSION"),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, AppointmentBooking apt, AppointmentService service) async {
    DateTime selectedDate = apt.proposedDateTime.add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 16, minute: 0);

    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (d == null || !context.mounted) return;

    final t = await showTimePicker(context: context, initialTime: selectedTime);
    if (t == null) return;

    final newDt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    await service.proposeAlternativeTime(
      appointmentId: apt.id,
      newDateTime: newDt,
      adminNotes: "Admin suggested alternative time due to prior screening commitments.",
    );
    await SoundService.playNotificationChime();
  }

  @override
  Widget build(BuildContext context) {
    final service = AppointmentService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("PASTORAL APPOINTMENTS DESK", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
      body: StreamBuilder<List<AppointmentBooking>>(
        stream: service.getAllAppointmentsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          final appointments = snapshot.data!;
          if (appointments.isEmpty) {
            return const Center(child: Text("No counsel appointments requested.", style: TextStyle(color: Colors.white38)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final apt = appointments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(apt.familyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(apt.status.name.toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text("Requested Time: ${apt.proposedDateTime.toIso8601String().substring(0, 16).replaceAll('T', ' ')} (${apt.platform.name})", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Agenda: ${apt.agendaTopic}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showConfirmDialog(context, apt, service),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
                            child: const Text("ACCEPT & CONFIRM", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showRescheduleDialog(context, apt, service),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orangeAccent)),
                            child: const Text("SUGGEST NEW TIME", style: TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}