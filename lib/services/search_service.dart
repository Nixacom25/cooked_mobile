import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/services/auth_service.dart';

/// Service to search products
class SearchService {
  /// Search products by query (name, category, keywords)
  static Future<List<Product>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();
    final user = AuthService().currentUser.value;
    final clientId = user != null
        ? '${user['firstName']} ${user['lastName']}'
        : 'client123';
    final allProducts = await ProductService.getProducts(clientId: clientId);

    return allProducts.where((product) {
      // Search in title
      if (product.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in category
      if (product.category.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in keywords
      if (product.keywords.any(
        (keyword) => keyword.toLowerCase().contains(lowerQuery),
      )) {
        return true;
      }

      // Search in description
      if (product.description.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Get products by category
  static Future<List<Product>> getByCategory(String category) async {
    final user = AuthService().currentUser.value;
    final clientId = user != null
        ? '${user['firstName']} ${user['lastName']}'
        : 'client123';
    final allProducts = await ProductService.getProducts(clientId: clientId);
    return allProducts
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  /// Get popular search suggestions
  static List<String> getSuggestions() {
    return ['Fashion', 'Beauty', 'Sport', 'Art', 'Promo', 'Nouveau'];
  }
}
