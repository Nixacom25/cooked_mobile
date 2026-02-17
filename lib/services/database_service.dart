import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_ecommerce/models/order.dart';

/// Simple local database service using SharedPreferences
/// For production, replace with Firebase, Supabase, or SQLite
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _ordersKey = 'orders';

  /// Save an order to local storage
  Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing orders
    final orders = await getAllOrders();

    // Add new order
    orders.add(order);

    // Save back to storage
    final ordersJson = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(ordersJson));
  }

  /// Get all orders from local storage
  Future<List<Order>> getAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString(_ordersKey);

    if (ordersString == null) {
      return [];
    }

    final ordersList = jsonDecode(ordersString) as List;
    return ordersList.map((json) => Order.fromJson(json)).toList();
  }

  /// Get order by ID
  Future<Order?> getOrderById(String id) async {
    final orders = await getAllOrders();
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final orders = await getAllOrders();
    final index = orders.indexWhere((order) => order.id == orderId);

    if (index != -1) {
      // Create updated order
      final oldOrder = orders[index];
      final updatedOrder = Order(
        id: oldOrder.id,
        firstName: oldOrder.firstName,
        lastName: oldOrder.lastName,
        primaryPhone: oldOrder.primaryPhone,
        secondaryPhone: oldOrder.secondaryPhone,
        googleMapsLink: oldOrder.googleMapsLink,
        deliveryDate: oldOrder.deliveryDate,
        deliveryTime: oldOrder.deliveryTime,
        comments: oldOrder.comments,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        createdAt: oldOrder.createdAt,
        status: status,
      );

      orders[index] = updatedOrder;

      // Save back
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = orders.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, jsonEncode(ordersJson));
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String orderId) async {
    final orders = await getAllOrders();
    orders.removeWhere((order) => order.id == orderId);

    final prefs = await SharedPreferences.getInstance();
    final ordersJson = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_ordersKey, jsonEncode(ordersJson));
  }

  /// Clear all orders (for testing)
  Future<void> clearAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }

  /// Generate unique order ID
  String generateOrderId() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }
}
