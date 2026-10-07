import 'package:flutter/foundation.dart';
class ApiConfig {
  static String get baseUrl {
    // return 'http://192.168.1.69:8099';
    return 'https://api.cookedapp.com';
  }

  static const String googleClientId =
      '560042995570-molk9k24g8i61vdpsov86fnmcogm73d7.apps.googleusercontent.com';

  /// OS reported to the backend (login sessions → admin "Platform" filters).
  static String get clientPlatform => switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        TargetPlatform.android => 'android',
        _ => 'other',
      };

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Platform': clientPlatform,
      };

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Client-Platform': clientPlatform,
    };
  }
}
