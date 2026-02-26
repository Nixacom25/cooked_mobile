import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Base URL logic for Android Emulator vs Real Device/iOS
  static String get baseUrl {
    if (kIsWeb)
      return 'http://192.168.1.69:8082/api/v1';
      // return 'https://bawane-api.up.railway.app/api/v1';
    else if (Platform.isAndroid) {
      return 'http://192.168.1.69:8082/api/v1';
    }
    return 'http://localhost:8082/api/v1';
  }

  static Future<List<dynamic>> getList(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('GET request to: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode specifically as UTF-8 to handle special characters correctly
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Error fetching data: $e');
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('GET request to: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw Exception('Error fetching data: $e');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('POST request to: $url');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        debugPrint('Post error body: $errorBody');
        throw Exception(
          'Failed to post data: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      debugPrint('Error posting data: $e');
      throw Exception('Error posting data: $e');
    }
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('PATCH request to: $url');

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        debugPrint('Patch error body: $errorBody');
        throw Exception(
          'Failed to patch data: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      debugPrint('Error patching data: $e');
      throw Exception('Error patching data: $e');
    }
  }

  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, dynamic> body, {
    File? audioFile,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('POST Multipart request to: $url');

    try {
      final request = http.MultipartRequest('POST', url);

      // Add order data as a 'order' part (JSON string)
      request.fields['order'] = json.encode(body);

      // Add audio file if present
      if (audioFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio', // Part name expected by backend
            audioFile.path,
          ),
        );
      }

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        debugPrint('Post error body: $errorBody');
        throw Exception(
          'Failed to post data: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      debugPrint('Error posting multipart data: $e');
      throw Exception('Error posting multipart data: $e');
    }
  }
}
