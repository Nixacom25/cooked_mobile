import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/subscription_payment.dart';
import 'auth_service.dart';

class SubscriptionService {
  SubscriptionService._privateConstructor();
  static final SubscriptionService instance =
      SubscriptionService._privateConstructor();

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getPlan() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/plan');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subscription plan');
    }
  }

  Future<Map<String, dynamic>> getMySubscription() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/me');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load subscription status');
    }
  }

  Future<void> paySubscription({
    required bool isYearly,
    required String stripeToken,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/pay');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({'isYearly': isYearly, 'stripeToken': stripeToken}),
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Payment failed');
    }
  }

  Future<void> verifyReceipt({
    required String productId,
    required String purchaseToken,
    required String platform,
    String? packageName,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/verify-receipt');
    final body = jsonEncode({
      'productId': productId,
      'purchaseToken': purchaseToken,
      'platform': platform,
      'packageName': packageName ?? 'com.cookedapp.app', // Fallback or use package_info
    });

    developer.log('Verifying IAP Receipt: $url with body: $body',
        name: 'SubscriptionService');

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      developer.log('IAP Verification SUCCESS: ${response.body}',
          name: 'SubscriptionService');
    } else {
      developer.log(
          'IAP Verification FAILED [${response.statusCode}]: ${response.body}',
          name: 'SubscriptionService');
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Verification failed');
    }
  }

  Future<List<SubscriptionPayment>> getPaymentHistory() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/subscriptions/history');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => SubscriptionPayment.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load payment history');
    }
  }
}
