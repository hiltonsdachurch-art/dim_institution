import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize Native Android Notifications
  static Future<void> initialize() async {
    if (kIsWeb) return;

    // 1. Request Permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("FCM Push Notifications Authorized");
    }

    // 2. Configure Android Notification Channel
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);

    // 3. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        showLocalBanner(
          title: notification.title ?? "DIM Covenant Alert",
          body: notification.body ?? "You have a new update in your chamber.",
        );
      }
    });
  }

  // Display native Android HUD notification banner
  static Future<void> showLocalBanner(
      {required String title, required String body}) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'dim_high_trust_channel',
      'DIM Covenant Notifications',
      channelDescription:
          'Notifications for introductions, chaperoned messages, and appointments',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Save candidate FCM token to user_profiles
  static Future<void> saveUserFcmToken(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('user_profiles')
            .doc(userId)
            .update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint("FCM Token notice: $e");
    }
  }

  // Dispatch Offline WhatsApp / SMS Notification to a Candidate or Family
  static Future<void> dispatchOfflineWhatsAppAlert({
    required String recipientPhone,
    required String recipientAlias,
    required String messageText,
  }) async {
    final cleanPhone = recipientPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMsg = Uri.encodeComponent(
      "DIM COVENANT ALERT for $recipientAlias: $messageText\n\nSign in to respond: https://institution.dim",
    );

    final uri = Uri.parse("https://wa.me/$cleanPhone?text=$encodedMsg");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("WhatsApp dispatch error: $e");
    }
  }
}
