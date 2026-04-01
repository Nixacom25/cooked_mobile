import 'package:app_ecommerce/models/order.dart';
import 'package:app_ecommerce/services/api_service.dart';

class OrderService {
  static Future<List<Order>> getOrdersByClient(String clientId) async {
    try {
      final List<dynamic> response = await ApiService.getList(
        '/orders/client/$clientId',
      );
      return response.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  static Future<Order?> getOrderById(String orderId) async {
    try {
      final Map<String, dynamic> response = await ApiService.get(
        '/orders/$orderId',
      );
      return Order.fromJson(response);
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }
}
