import 'dart:convert';
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
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/support/submit'),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'source': 'MOBILE',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to send feedback (${response.statusCode})');
    }
  }
}
