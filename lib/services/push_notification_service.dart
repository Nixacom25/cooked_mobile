import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';
import 'notification_service.dart';

/// Must be a top-level (or static) function: FCM runs it in a separate
/// isolate when a data message arrives while the app is backgrounded or
/// terminated. Notification-type messages are shown by the OS automatically
/// in that state, so there's nothing to do here beyond logging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message received: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._privateConstructor();
  static final PushNotificationService instance = PushNotificationService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Set by a tap on a push notification (foreground, background, or a cold
  /// start), so main.dart can navigate based on the message's data payload -
  /// mirrors how SharingService.sharedTextNotifier drives deep-link routing.
  final ValueNotifier<Map<String, dynamic>?> tappedNotificationDataNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapped);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationTapped(initialMessage);
    }

    _messaging.onTokenRefresh.listen(_registerToken);

    await registerCurrentToken();
  }

  /// Re-sends the current device token to the backend. Call this again right
  /// after login, since the token may have been fetched before the user was
  /// authenticated (registration is a no-op while logged out).
  Future<void> registerCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      await _registerToken(token);
    } catch (e) {
      debugPrint('Could not fetch FCM token: $e');
    }
  }

  Future<void> _registerToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (!AuthService.instance.isLoggedIn) return;

    try {
      final authToken = await AuthService.instance.getToken();
      if (authToken == null || authToken.isEmpty) return;

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/fcm-token'),
        headers: ApiConfig.authHeaders(authToken),
        body: jsonEncode({'fcmToken': token}),
      );
    } catch (e) {
      debugPrint('Could not register FCM token: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    NotificationService.instance.showRemoteNotification(
      title: notification.title ?? 'Cooked',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTapped(RemoteMessage message) {
    tappedNotificationDataNotifier.value = message.data;
  }
}
