import 'package:dim_institution/screens/institutional_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'discovery_screen.dart';
import 'candidate_inbox_screen.dart';
import 'community_lounge_screen.dart';
import 'candidate_profile_screen.dart';
import '../main.dart';

class CandidatePortalScreen extends StatefulWidget {
  final String currentUid;
  final String currentAlias;

  const CandidatePortalScreen({
    super.key,
    required this.currentUid,
    required this.currentAlias,
  });

  @override
  State<CandidatePortalScreen> createState() => _CandidatePortalScreenState();
}

class _CandidatePortalScreenState extends State<CandidatePortalScreen> {
  int _currentIndex = 0;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setUserOnline(true);
  }

  @override
  void dispose() {
    _setUserOnline(false);
    super.dispose();
  }

  void _setUserOnline(bool online) {
    try {
      _db.collection('user_profiles').doc(widget.currentUid).update({
        'isOnline': online,
        'lastActive': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  void _handleSignOut() async {
    _setUserOnline(false);
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const InstitutionalHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DiscoveryScreen(
        currentCandidateUid: widget.currentUid,
        currentCandidateAlias: widget.currentAlias,
      ),
      CommunityLoungeScreen(
        currentUid: widget.currentUid,
        currentAlias: widget.currentAlias,
      ),
      CandidateInboxScreen(
        currentCandidateUid: widget.currentUid,
        currentCandidateAlias: widget.currentAlias,
      ),
      CandidateProfileScreen(
        currentUid: widget.currentUid,
        currentAlias: widget.currentAlias,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          widget.currentAlias,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54, size: 20),
            tooltip: "Sign Out",
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_outlined),
              activeIcon: Icon(Icons.person_search),
              label: "Discovery",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              activeIcon: Icon(Icons.forum),
              label: "Lounge",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mark_email_unread_outlined),
              activeIcon: Icon(Icons.mark_email_unread),
              label: "Inboxes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle),
              label: "My Profile",
            ),
          ],
        ),
      ),
    );
  }
}