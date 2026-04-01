import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app_ecommerce/main.dart';
import 'package:app_ecommerce/services/notification_service.dart';
import 'package:app_ecommerce/models/notification.dart';
import 'package:app_ecommerce/screens/review_form_screen.dart';
import 'package:app_ecommerce/screens/invoices_screen.dart';
import 'package:app_ecommerce/services/api_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Client granted notification permissions');
    }

    // Subscribe to products topic for global notifications
    await _messaging.subscribeToTopic('products');

    String? token = await _messaging.getToken();
    if (token != null) {
      _sendTokenToBackend(token);
    }

    _messaging.onTokenRefresh.listen(_sendTokenToBackend);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message (Client): ${message.notification?.title}');
      _addNotificationToList(message);
      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    _messaging.getInitialMessage().then((RemoteMessage? initialMessage) {
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage.data);
      }
    });

    _initialized = true;
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await ApiService.post('/notifications/token', {'token': token});
    } catch (e) {
      debugPrint('Error sending FCM token (Client): $e');
    }
  }

  void _addNotificationToList(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final typeStr = message.data['type']?.toString().toLowerCase();
    NotificationType type = NotificationType.order;
    if (typeStr == 'product')
      type = NotificationType.product;
    else if (typeStr == 'payment')
      type = NotificationType.payment;
    else if (typeStr == 'review_request')
      type = NotificationType.review;

    final newNotif = NotificationModel(
      id: message.messageId ?? DateTime.now().toString(),
      type: type,
      title: notification.title ?? 'Alerte',
      message: notification.body ?? '',
      timestamp: DateTime.now(),
      data: message.data,
    );

    NotificationService().addNotification(newNotif);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final context = navigatorKey.currentContext;

    if (notification != null && context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title ?? 'Dépèche',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                notification.body ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E2832),
          action: SnackBarAction(
            label: 'VOIR',
            textColor: Colors.orange[800],
            onPressed: () => _handleNotificationClick(message.data),
          ),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final String? type = data['type']?.toString().toUpperCase();
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (type == 'PRODUCT') {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else if (type == 'ORDER') {
      final orderId = data['orderId']?.toString();
      if (orderId != null) {
        // Since detailed data might be missing from mock, we use a skeleton or go to Orders list
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        // Note: Real implementation would navigate to OrderDetailsScreen(order: fetchedOrder)
      }
    } else if (type == 'REVIEW_REQUEST') {
      final orderId = data['orderId']?.toString();
      if (orderId != null) {
        // Create a skeleton order map for the review form
        final mockOrder = {
          'id': orderId,
          'date': 'Aujourd\'hui',
          'items': 'Commande récente',
        };
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReviewFormScreen(order: mockOrder),
          ),
        );
      }
    } else if (type == 'PAYMENT') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const InvoicesScreen()));
    }
  }
}
