import 'dart:convert';
import 'package:http/http.dart' as http;

class PaywallService {
  final String baseUrl;
  final String authToken;

  PaywallService({required this.baseUrl, required this.authToken});

  // Récupère la configuration dynamique (A/B Testing)
  Future<Map<String, dynamic>> getRemoteConfig({String? flow}) async {
    final queryParams = flow != null ? '?flow=$flow' : '';
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/paywall-config$queryParams'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load paywall config');
  }

  // Envoie un événement analytics
  Future<void> trackEvent(String eventName, String variantKey, {String? metadata}) async {
    await http.post(
      Uri.parse('$baseUrl/api/analytics/track'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'eventName': eventName,
        'variantKey': variantKey,
        'metadata': metadata,
      }),
    );
  }
}
