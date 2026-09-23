import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

class SupportService {
  SupportService._privateConstructor();
  static final SupportService instance = SupportService._privateConstructor();

  Future<void> submitFeedback({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? userId,
    String? category,
  }) async {
    String platform = 'Web';
    String appVersion = 'Unknown';
    
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        platform = 'Android';
      } else if (Platform.isIOS) {
        platform = 'iOS';
      }
      // We'll use a constant version for now since package_info_plus is not installed
      appVersion = '1.0.2';
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/support/submit'),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'source': 'MOBILE',
        'userId': userId,
        'platform': platform,
        'appVersion': appVersion,
        'category': category,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send feedback (${response.statusCode})');
    }
  }
}
