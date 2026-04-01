import 'package:app_ecommerce/models/category.dart';
import 'package:app_ecommerce/models/product.dart';
import 'package:app_ecommerce/models/testimonial.dart';
import 'package:app_ecommerce/models/advertisement.dart';
import 'package:app_ecommerce/services/category_service.dart';
import 'package:app_ecommerce/services/product_service.dart';
import 'package:app_ecommerce/services/testimonial_service.dart';
import 'package:app_ecommerce/services/advertisement_service.dart';
import 'package:app_ecommerce/services/auth_service.dart';

class DataCacheService {
  static final DataCacheService _instance = DataCacheService._internal();

  factory DataCacheService() {
    return _instance;
  }

  DataCacheService._internal();

  List<Category>? categories;
  List<Product>? products;
  List<Testimonial>? testimonials;
  List<Advertisement>? advertisements;

  Future<void> prefetchAll() async {
    try {
      final user = AuthService().currentUser.value;
      final clientId = user != null
          ? '${user['firstName']} ${user['lastName']}'
          : 'client123';

      final results = await Future.wait([
        CategoryService.getCategories(),
        ProductService.getProducts(clientId: clientId),
        TestimonialService.getTestimonials(),
        AdvertisementService.getAdvertisements(),
      ]);

      categories = results[0] as List<Category>;
      products = results[1] as List<Product>;
      testimonials = results[2] as List<Testimonial>;
      advertisements = results[3] as List<Advertisement>;
    } catch (e) {
      print("Error prefetching data: $e");
    }
  }

  bool get hasData =>
      categories != null &&
      products != null &&
      testimonials != null &&
      advertisements != null;
}
