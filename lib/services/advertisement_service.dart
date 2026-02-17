import 'package:app_ecommerce/services/api_service.dart';
import 'package:app_ecommerce/models/advertisement.dart';
import 'package:flutter/foundation.dart';

class AdvertisementService {
  static const String _endpoint = '/advertisements'; // Fixed: removed /api/v1

  static Future<List<Advertisement>> getAdvertisements() async {
    try {
      final List<dynamic> data = await ApiService.getList(_endpoint);
      return data.map((json) => Advertisement.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching advertisements: $e');
      return [];
    }
  }

  static Future<void> incrementListeners(int id) async {
    try {
      await ApiService.post('$_endpoint/$id/listen', {});
    } catch (e) {
      debugPrint('Error incrementing listeners for ad $id: $e');
    }
  }
}
