import 'package:flutter/material.dart';
import 'package:app_ecommerce/models/notification.dart';
import 'package:app_ecommerce/services/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<List<NotificationModel>> notifications =
      ValueNotifier<List<NotificationModel>>([]);

  bool _isInitialized = false;

  Future<void> fetchNotifications({bool force = false}) async {
    if (_isInitialized && !force) return;
    try {
      final List<dynamic> json = await ApiService.getList('/notifications');
      notifications.value = json
          .map((data) => NotificationModel.fromJson(data))
          .toList();
      _isInitialized = true;
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  int get unreadCount => notifications.value.where((n) => !n.isRead).length;

  Future<void> markAsRead(String id) async {
    try {
      await ApiService.put('/notifications/$id/read', {});
      final list = List<NotificationModel>.from(notifications.value);
      final index = list.indexWhere((n) => n.id == id);
      if (index != -1) {
        list[index].isRead = true;
        notifications.value = list;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.put('/notifications/read-all', {});
      final list = notifications.value.map((n) {
        n.isRead = true;
        return n;
      }).toList();
      notifications.value = list;
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void addNotification(NotificationModel notification) {
    final list = List<NotificationModel>.from(notifications.value);
    list.insert(0, notification);
    notifications.value = list;
  }
}
