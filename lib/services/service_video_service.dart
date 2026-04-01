import 'package:app_ecommerce/models/service_video.dart';
import 'package:app_ecommerce/services/api_service.dart';

class ServiceVideoService {
  static const String _endpoint = '/services';

  // Get all videos (filtered by optional type like TECHNICIAN, PRODUCT_USAGE, VLOG)
  static Future<List<ServiceVideo>> getVideos({String? type}) async {
    try {
      String url = _endpoint;
      if (type != null && type.isNotEmpty) {
        url += '?type=$type';
      }
      final response = await ApiService.getList(url);
      return response.map((json) => ServiceVideo.fromJson(json)).toList();
    } catch (e) {
      print('Error getting service videos: $e');
      return [];
    }
  }

  // Get single video by ID
  static Future<ServiceVideo?> getVideoById(String id) async {
    try {
      final response = await ApiService.get('$_endpoint/$id');
      return ServiceVideo.fromJson(response);
    } catch (e) {
      print('Error getting video: $e');
      return null;
    }
  }

  // Increment video views
  static Future<void> incrementViews(String id) async {
    try {
      await ApiService.put('$_endpoint/$id/view', {});
    } catch (e) {
      print('Error incrementing video views: $e');
    }
  }

  // Get comments for a video
  static Future<List<ServiceVideoComment>> getComments(String id) async {
    try {
      final response = await ApiService.getList('$_endpoint/$id/comments');
      return response
          .map((json) => ServiceVideoComment.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // Add comment to a video
  static Future<ServiceVideoComment?> addComment(
    String id,
    String content, {
    String clientId = "client123",
  }) async {
    try {
      final response = await ApiService.post('$_endpoint/$id/comments', {
        'client_id': clientId,
        'content': content,
      });
      return ServiceVideoComment.fromJson(response);
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }
}
