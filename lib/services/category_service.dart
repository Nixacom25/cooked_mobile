import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/services/api_service.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    // Assuming backend endpoint is /categories
    final List<dynamic> json = await ApiService.getList('/categories');
    return json.map((data) => Category.fromJson(data)).toList();
  }
}
