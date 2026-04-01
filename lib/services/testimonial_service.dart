import 'dart:io';
import 'package:app_ecommerce/models/testimonial.dart';
import 'package:app_ecommerce/services/api_service.dart';

class TestimonialService {
  static Future<List<Testimonial>> getTestimonials() async {
    final List<dynamic> json = await ApiService.getList('/testimonials');
    return json.map((data) => Testimonial.fromJson(data)).toList();
  }

  static Future<Testimonial> incrementViews(String id) async {
    final json = await ApiService.post('/testimonials/$id/view', {});
    return Testimonial.fromJson(json);
  }

  static Future<Testimonial> incrementLikes(String id) async {
    final json = await ApiService.post('/testimonials/$id/like', {});
    return Testimonial.fromJson(json);
  }

  static Future<Testimonial> createTestimonial(
    Map<String, dynamic> data,
    File? file,
  ) async {
    final response = await ApiService.postMultipart(
      '/testimonials',
      {},
      files: file != null ? {'file': file} : null,
      jsonPartName: 'data',
      jsonData: data,
    );
    return Testimonial.fromJson(response);
  }
}
