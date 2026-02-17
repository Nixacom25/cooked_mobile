import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/api_service.dart';

class ProductService {
  static Future<List<Product>> getProducts() async {
    final List<dynamic> json = await ApiService.getList('/products');
    return json.map((data) => Product.fromJson(data)).toList();
  }

  static Future<List<Product>> getProductsByCategory(String categoryId) async {
    final products = await getProducts();
    return products.where((p) => p.category == categoryId).toList();
  }
}
