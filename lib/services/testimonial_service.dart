import 'package:app_ecommerce/models/testimonial.dart';
import 'package:app_ecommerce/services/api_service.dart';

class TestimonialService {
  static Future<List<Testimonial>> getTestimonials() async {
    final List<dynamic> json = await ApiService.getList('/testimonials');
    return json.map((data) => Testimonial.fromJson(data)).toList();
  }

  static Future<Testimonial> incrementViews(int id) async {
    final json = await ApiService.post('/testimonials/$id/view', {});
    return Testimonial.fromJson(json);
  }

  static Future<Testimonial> incrementLikes(int id) async {
    final json = await ApiService.post('/testimonials/$id/like', {});
    return Testimonial.fromJson(json);
  }

  static Future<Testimonial> updateStatus(int id, String status) async {
    final json = await ApiService.patch(
      '/testimonials/$id/status?status=$status',
      {},
    );
    return Testimonial.fromJson(json);
  }
}
