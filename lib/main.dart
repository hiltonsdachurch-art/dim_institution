import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/notification_service.dart';
import 'screens/institutional_home_screen.dart';
import 'screens/gatekeeper_cockpit_screen.dart';
import 'screens/admin_case_file_screen.dart';
import 'screens/admin_candidate_directory_screen.dart';
import 'screens/admin_appointments_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Native Android Push Notifications & Channels
    await NotificationService.initialize();
  } catch (e) {
    debugPrint("Firebase/Notification initialization notice: $e");
  }

  runApp(const DimInstitutionApp());
}

class DimInstitutionApp extends StatelessWidget {
  const DimInstitutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Institution for Marriage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1E293B),
        ),
        useMaterial3: true,
      ),
      home: const InstitutionalHomeScreen(),
    );
  }
}

class AdminMasterDashboardScreen extends StatelessWidget {
  const AdminMasterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37)),
            SizedBox(width: 10),
            Text(
              "GATEKEEPER COMMAND CENTER",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: "Sign Out",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const InstitutionalHomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Gatekeeper Institutional Cockpit",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Manage enrolled candidates, review spousal psychometrics, schedule Zoom/Teams appointments, and guide couples.",
                  style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
                ),
                const SizedBox(height: 24),

                // Button 1: Candidate Directory
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminCandidateDirectoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.people_outline, size: 20),
                    label: const Text(
                      "MASTER CANDIDATE DIRECTORY & IDENTITY VAULT",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Button 2: Pastoral Appointments Desk
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminAppointmentsScreen()),
                      );
                    },
                    icon: const Icon(Icons.video_camera_front_outlined, size: 20),
                    label: const Text(
                      "PASTORAL APPOINTMENTS DESK (TEAMS & ZOOM)",
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Button 3: Matchmaking Scorecards
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GatekeeperCockpitScreen()),
                      );
                    },
                    icon: const Icon(Icons.rate_review_outlined, size: 18, color: Color(0xFFD4AF37)),
                    label: const Text(
                      "INTERVIEW COCKPIT & SCORECARDS",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Button 4: Case Files
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminCaseFileScreen()),
                      );
                    },
                    icon: const Icon(Icons.psychology_outlined, size: 18, color: Color(0xFFD4AF37)),
                    label: const Text(
                      "LONGITUDINAL CASE FILES & SHEPHERD LOGS",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}