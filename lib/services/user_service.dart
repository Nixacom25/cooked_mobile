import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'package:flutter/foundation.dart';
import '../models/activity_log.dart';
import 'auth_service.dart';

class UserService {
  // Singleton pattern
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  /// Reactive state for the currently logged-in user.
  final ValueNotifier<Map<String, dynamic>?> currentUserNotifier =
      ValueNotifier(null);

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/me');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentUserNotifier.value = data;
      return data;
    } else {
      throw Exception(
        _extractErrorMessage(response.body, 'Unable to load profile.'),
      );
    }
  }

  Future<Map<String, dynamic>> updateCurrentUser({
    required String firstname,
    required String lastname,
    required String phone,
    String? discoverySource,
    String? otherDiscoverySource,
    String? language,
    String? country,
    String? alternativeRegion,
    String? measurementSystem,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/me');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
        'discoverySource': discoverySource,
        'otherDiscoverySource': otherDiscoverySource,
        'language': language,
        'country': country,
        'alternativeRegion': alternativeRegion,
        'measurementSystem': measurementSystem,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentUserNotifier.value = data;
      return data;
    } else {
      throw Exception(
        _extractErrorMessage(response.body, 'Unable to update profile.'),
      );
    }
  }

  Future<void> updatePreferences({
    required List<String> dietaryPreferences,
    required List<String> allergies,
    required List<String> foodDislikes,
    required Map<String, int> flavorDna,
    required String spiceLevel,
    required String cookingSkill,
    required String cookingTimePreference,
    required String cookingFrequency,
    required String cookingTarget,
    required List<String> favoriteCuisines,
    required List<String> kitchenAppliances,
    required String mealPlanningStyle,
    required List<String> notificationPreferences,
    required List<String> onboardingGoals,
    int? onboardingRating,
    String? onboardingFeedback,
    String? language,
    String? country,
    String? alternativeRegion,
    String? measurementSystem,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/me/preferences');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'dietaryPreferences': dietaryPreferences,
        'allergies': allergies,
        'foodDislikes': foodDislikes,
        'flavorDna': flavorDna,
        'spiceLevel': spiceLevel,
        'cookingSkill': cookingSkill,
        'cookingTimePreference': cookingTimePreference,
        'cookingFrequency': cookingFrequency,
        'cookingTarget': cookingTarget,
        'favoriteCuisines': favoriteCuisines,
        'kitchenAppliances': kitchenAppliances,
        'mealPlanningStyle': mealPlanningStyle,
        'notificationPreferences': notificationPreferences,
        'onboardingGoals': onboardingGoals,
        'onboardingRating': onboardingRating,
        'onboardingFeedback': onboardingFeedback,
        'language': language,
        'country': country,
        'alternativeRegion': alternativeRegion,
        'measurementSystem': measurementSystem,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response.body, 'Unable to save your preferences.'),
      );
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/password-reset');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response.body, 'Unable to change password.'),
      );
    }
  }

  Future<void> uploadProfilePhoto(List<int> imageBytes, String filename) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/profile-photo');
    final request = http.MultipartRequest('POST', url);
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Unable to upload profile picture.',
        ),
      );
    }

    // Refresh user data so the entire app sees the new Cloudinary URL instantly
    await getCurrentUser();
  }

  Future<List<ActivityLog>> getActivities({int page = 0, int size = 20}) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/activities?page=$page&size=$size',
    );
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List content = data['content'] ?? [];
      return content.map((e) => ActivityLog.fromJson(e)).toList();
    } else {
      throw Exception('Unable to load activity history.');
    }
  }

  String _extractErrorMessage(String responseBody, String defaultMessage) {
    try {
      final decoded = jsonDecode(responseBody);
      final backendError = decoded['message'] ?? decoded['error'];
      if (backendError != null) {
        return backendError;
      }
    } catch (_) {
      developer.log(
        'API Error parsing response: $responseBody',
        name: 'UserService',
      );
    }
    return defaultMessage;
  }

  void clearData() {
    currentUserNotifier.value = null;
  }
}
