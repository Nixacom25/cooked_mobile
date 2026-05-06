class ApiConfig {
  static String get baseUrl {
    // return 'http://192.168.1.69:8099';
    return 'https://cooked-backend-latest.onrender.com';
  }

  static const String googleClientId =
      '560042995570-molk9k24g8i61vdpsov86fnmcogm73d7.apps.googleusercontent.com';

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
