import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/api_service.dart';

class ProductService {
  static Future<List<Product>> getProducts({String? clientId}) async {
    String url = '/products';
    if (clientId != null && clientId.isNotEmpty) {
      url += '?clientId=$clientId';
    }
    final List<dynamic> json = await ApiService.getList(url);
    return json.map((data) => Product.fromJson(data)).toList();
  }

  static Future<List<Product>> getProductsByCategory(
    String categoryId, {
    String? clientId,
  }) async {
    String url = '/products/category/$categoryId';
    if (clientId != null && clientId.isNotEmpty) {
      url += '?clientId=$clientId';
    }
    final List<dynamic> json = await ApiService.getList(url);
    return json.map((data) => Product.fromJson(data)).toList();
  }

  static Future<List<ProductComment>> getComments(
    String productId, {
    String? clientId,
  }) async {
    try {
      String url = '/products/$productId/comments';
      if (clientId != null && clientId.isNotEmpty) {
        url += '?clientId=$clientId';
      }
      final response = await ApiService.getList(url);
      return response.map((json) => ProductComment.fromJson(json)).toList();
    } catch (e) {
      print('Error getting product comments: $e');
      return [];
    }
  }

  static Future<ProductComment?> addComment(
    String productId,
    String content, {
    String clientId = "client123",
  }) async {
    try {
      final response = await ApiService.post('/products/$productId/comments', {
        'client_id': clientId,
        'content': content,
      });
      return ProductComment.fromJson(response);
    } catch (e) {
      print('Error adding product comment: $e');
      return null;
    }
  }

  static Future<void> incrementMediaView(String productId, String url) async {
    try {
      await ApiService.post('/products/$productId/media/view?url=$url', {});
    } catch (e) {
      print('Error incrementing media view: $e');
    }
  }

  static Future<void> incrementShareCount(String productId) async {
    try {
      await ApiService.post('/products/$productId/share', {});
    } catch (e) {
      print('Error incrementing share count: $e');
    }
  }
}
