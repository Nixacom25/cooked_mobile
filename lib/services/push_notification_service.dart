import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'user_service.dart';

/// Must be a top-level (or static) function: FCM runs it in a separate
/// isolate when a data message arrives while the app is backgrounded or
/// terminated. Notification-type messages are shown by the OS automatically
/// in that state, so there's nothing to do here beyond logging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background FCM message received: ${message.messageId}');
  
  // Track notification open when app is opened from background
  if (message.data.containsKey('campaignId')) {
    await _trackNotificationOpenBackground(message.data['campaignId']);
  }
}

// Track notification open when app is opened from background (top-level function)
Future<void> _trackNotificationOpenBackground(String campaignId) async {
  try {
    final url = Uri.parse('${ApiConfig.baseUrl}/notification-campaigns/$campaignId/open');
    await http.post(url, headers: {'Content-Type': 'application/json'});
  } catch (e) {
    debugPrint('Could not track notification open (background): $e');
  }
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
    
    // Update user's last active timestamp
    await _updateLastActive();
  }

  /// Re-sends the current device token to the backend. Call this again right
  /// after login, since the token may have been fetched before the user was
  /// authenticated (registration is a no-op while logged out).
  Future<void> registerCurrentToken() async {
    try {
      // On iOS, FirebaseMessaging.getToken() bridges through APNs: it needs
      // the APNs device token first, which only exists once iOS finishes its
      // own async remote-notification registration. Calling getToken() right
      // after requestPermission() (before that round-trip completes) throws
      // or returns null on iOS - Android has no equivalent step, which is
      // why this silently "worked on Android but not iOS". Poll briefly for
      // the APNs token before asking Firebase for the FCM token.
      if (!kIsWeb && Platform.isIOS) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          debugPrint(
            'Could not register FCM token: no APNs token after waiting - '
            'check that Push Notifications is enabled for this App ID AND '
            'that the provisioning profile used to sign this build was '
            'regenerated/reinstalled after enabling it (an old profile '
            'won\'t carry the aps-environment entitlement even if the '
            'capability is now on in App Store Connect).',
          );
          return;
        }
      }

      final token = await _messaging.getToken();
      await _registerToken(token);
    } catch (e) {
      debugPrint('Could not fetch FCM token: $e');
    }
  }

  Future<String?> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return apnsToken;
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return null;
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
    
    debugPrint('Foreground message received: ${notification.title} - ${notification.body}');
    
    // Track notification open for foreground messages
    if (message.data.containsKey('campaignId')) {
      _trackNotificationOpen(message.data['campaignId']);
    }
    
    // On iOS, show local notification for foreground messages
    // On Android, FCM shows the notification automatically
    if (Platform.isIOS) {
      NotificationService.instance.showRemoteNotification(
        title: notification.title ?? 'Cooked',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onNotificationTapped(RemoteMessage message) {
    // Track notification click
    if (message.data.containsKey('campaignId')) {
      _trackNotificationClick(message.data['campaignId']);
    }
    
    // Set deep link for navigation
    tappedNotificationDataNotifier.value = message.data;
  }

  Future<void> _trackNotificationOpen(String campaignId) async {
    try {
      if (!AuthService.instance.isLoggedIn) return;
      
      final authToken = await AuthService.instance.getToken();
      if (authToken == null || authToken.isEmpty) return;

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notification-campaigns/$campaignId/open'),
        headers: ApiConfig.authHeaders(authToken),
      );
    } catch (e) {
      debugPrint('Could not track notification open: $e');
    }
  }

  Future<void> _trackNotificationClick(String campaignId) async {
    try {
      if (!AuthService.instance.isLoggedIn) return;
      
      final authToken = await AuthService.instance.getToken();
      if (authToken == null || authToken.isEmpty) return;

      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notification-campaigns/$campaignId/click'),
        headers: ApiConfig.authHeaders(authToken),
      );
    } catch (e) {
      debugPrint('Could not track notification click: $e');
    }
  }

  Future<void> _updateLastActive() async {
    try {
      if (!AuthService.instance.isLoggedIn) return;
      await UserService.instance.updateLastActive();
    } catch (e) {
      debugPrint('Could not update last active: $e');
    }
  }
}
