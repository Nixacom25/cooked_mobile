import 'dart:ui' show PlatformDispatcher;
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

  /// "1.0.5+107", set once at startup (see main.dart) for the admin Version filters.
  static String? appVersion;

  /// Device region (ISO country), for the admin Country filters.
  static String? get clientCountry => PlatformDispatcher.instance.locale.countryCode;

  /// Headers describing the client, sent with every request.
  static Map<String, String> get clientHeaders => {
        'X-Client-Platform': clientPlatform,
        if (appVersion != null) 'X-App-Version': appVersion!,
        if (clientCountry != null && clientCountry!.length == 2) 'X-Client-Country': clientCountry!,
      };

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...clientHeaders,
      };

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      ...clientHeaders,
    };
  }
}
