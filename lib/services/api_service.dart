import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL logic for Android Emulator vs Real Device/iOS
  static String get baseUrl {
    if (kIsWeb)
      return 'http://192.168.1.69:8082/api/v1';
    else if (Platform.isAndroid) {
      return 'http://192.168.1.69:8082/api/v1';
      // return 'https://bawane.onrender.com/api/v1';
    }
    return 'http://localhost:8082/api/v1';
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<dynamic>> getList(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('GET request to: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Decode specifically as UTF-8 to handle special characters correctly
        return json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      } else {
        throw _handleError(null, response);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw _handleError(e);
    }
  }

  static dynamic _handleError(dynamic e, [http.Response? response]) {
    if (response != null) {
      try {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (body is Map && body.containsKey('message')) {
          return body['message'];
        }
        if (body is Map && body.containsKey('error')) {
          return body['error'];
        }
      } catch (_) {}

      switch (response.statusCode) {
        case 400:
          return "Requête invalide";
        case 401:
          return "Non autorisé";
        case 403:
          return "Accès refusé";
        case 404:
          return "Ressource non trouvée";
        case 500:
          return "Erreur serveur";
        default:
          return "Erreur ${response.statusCode}";
      }
    }

    if (e is SocketException) {
      return "Connexion perdue ou serveur injoignable";
    }
    if (e is HttpException) {
      return "Erreur HTTP";
    }
    if (e is FormatException) {
      return "Erreur de format de réponse";
    }

    String msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring(11);
    }
    return msg;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('GET request to: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        throw _handleError(null, response);
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      throw _handleError(e);
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('POST request to: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw _handleError(null, response);
      }
    } catch (e) {
      debugPrint('Error posting data: $e');
      throw _handleError(e);
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('PUT request to: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) return {};
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw _handleError(null, response);
      }
    } catch (e) {
      debugPrint('Error putting data: $e');
      throw _handleError(e);
    }
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('PATCH request to: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw _handleError(null, response);
      }
    } catch (e) {
      debugPrint('Error patching data: $e');
      throw _handleError(e);
    }
  }

  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    Map<String, File>? files,
    String? jsonPartName,
    Map<String, dynamic>? jsonData,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    debugPrint('POST Multipart request to: $url');

    try {
      final request = http.MultipartRequest('POST', url);

      // Add Authorization header
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add simple fields
      request.fields.addAll(fields);

      // Add JSON part as a file with application/json content type if specified
      // This is often needed for Spring Boot's @RequestPart
      if (jsonPartName != null && jsonData != null) {
        request.files.add(
          http.MultipartFile.fromString(
            jsonPartName,
            json.encode(jsonData),
            contentType: MediaType('application', 'json'),
          ),
        );
      }

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }
      }

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw _handleError(null, response);
      }
    } catch (e) {
      debugPrint('Error posting multipart data: $e');
      throw _handleError(e);
    }
  }
}
