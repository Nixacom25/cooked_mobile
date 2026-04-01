import 'dart:convert';

enum NotificationType { product, order, invoice, review, payment }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final Map<String, dynamic>?
  data; // Extra data for navigation (e.g. productId, orderId)

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? json['read'] ?? false,
      data: _parseData(json['data']),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'product':
        return NotificationType.product;
      case 'order':
        return NotificationType.order;
      case 'invoice':
        return NotificationType.invoice;
      case 'review':
        return NotificationType.review;
      case 'payment':
        return NotificationType.payment;
      default:
        return NotificationType.product;
    }
  }

  static Map<String, dynamic>? _parseData(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return json.decode(data) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
