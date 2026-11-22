import 'package:flutter/material.dart';
import '../models/case_file_model.dart';
import '../services/case_file_service.dart';

class AdminCaseFileScreen extends StatelessWidget {
  const AdminCaseFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CaseFileService caseFileService = CaseFileService();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "CASE FILE INTELLIGENCE & SHEPHERD PORTAL",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: StreamBuilder<List<UserCaseFile>>(
        stream: caseFileService.getAllCaseFilesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          final caseFiles = snapshot.data ?? [];

          if (caseFiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.psychology_outlined, size: 54, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    "No Case Files Initialized Yet",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Complete a Post-Meeting Outcome Survey to seed the intelligence engine.",
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: caseFiles.length,
            itemBuilder: (context, index) {
              final file = caseFiles[index];
              return _buildCaseFileDossier(context, file, caseFileService);
            },
          );
        },
      ),
    );
  }

  Widget _buildCaseFileDossier(
    BuildContext context,
    UserCaseFile file,
    CaseFileService service,
  ) {
    final bool hasAlerts = file.activeAlerts.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAlerts
              ? Colors.redAccent.withOpacity(0.5)
              : const Color(0xFFD4AF37).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Alias & Shepherd Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_shared_outlined, color: Color(0xFFD4AF37), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "Case File: ${file.alias}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              _buildShepherdBadge(file.shepherdStatus),
            ],
          ),
          const SizedBox(height: 16),

          // Longitudinal Metrics Matrix
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricCol("Total Intros", "${file.totalIntroductions}"),
                _buildMetricCol("Interviews Passed", "${file.totalInterviewsPassed}"),
                _buildMetricCol("Failed Outcomes", "${file.totalFailedOutcomes}", isNegative: file.totalFailedOutcomes > 1),
                _buildMetricCol("Matches Covenanted", "${file.totalSuccessfulMatches}", isPositive: file.totalSuccessfulMatches > 0),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Heuristic Pattern Alerts
          if (hasAlerts) ...[
            const Text(
              "AUTOMATED BEHAVIORAL PATTERN ALERTS",
              style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),
            ...file.activeAlerts.map((alert) => _buildAlertCard(alert)),
            const SizedBox(height: 18),
          ],

          // Marriage Shepherd Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showShepherdCheckInDialog(context, file, service);
                  },
                  icon: const Icon(Icons.volunteer_activism_outlined, size: 16),
                  label: const Text(
                    "RECORD SHEPHERD LOG",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          // Historical Shepherd Notes
          if (file.shepherdCheckInNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              "Shepherd Mentorship Logs:",
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...file.shepherdCheckInNotes.map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(color: Color(0xFFD4AF37))),
                    Expanded(
                      child: Text(note, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildAlertCard(BehavioralAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                "${alert.alertType} (${alert.severity})",
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            alert.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 6),
          Text(
            "Recommended Action: ${alert.coachingRecommendation}",
            style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, {bool isNegative = false, bool isPositive = false}) {
    Color col = Colors.white;
    if (isNegative) col = Colors.redAccent;
    if (isPositive) col = const Color(0xFF34D399);

    return Column(
      children: [
        Text(value, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _buildShepherdBadge(ShepherdStatus status) {
    Color bg = Colors.white12;
    Color fg = Colors.white70;

    if (status == ShepherdStatus.activePreMarital) {
      bg = Colors.blue.withOpacity(0.2);
      fg = Colors.lightBlueAccent;
    } else if (status == ShepherdStatus.marriageCovenant) {
      bg = const Color(0xFF10B981).withOpacity(0.2);
      fg = const Color(0xFF34D399);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        "SHEPHERD: ${status.name.toUpperCase()}",
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showShepherdCheckInDialog(BuildContext context, UserCaseFile file, CaseFileService service) {
    final noteController = TextEditingController();
    ShepherdStatus status = file.shepherdStatus;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Shepherd Journal: ${file.alias}", style: const TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mentorship Covenant Stage:", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              DropdownButton<ShepherdStatus>(
                value: status,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: ShepherdStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => status = val!),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: "Mentorship Session Notes",
                  labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                if (noteController.text.trim().isNotEmpty) {
                  await service.updateShepherdStatus(
                    userId: file.userId,
                    status: status,
                    checkInNote: "${DateTime.now().toIso8601String().substring(0, 10)}: ${noteController.text.trim()}",
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF0F172A)),
              child: const Text("SAVE ENTRY"),
            ),
          ],
        ),
      ),
    );
  }
}