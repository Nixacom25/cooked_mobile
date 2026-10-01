import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'package:flutter/foundation.dart';
import '../models/activity_log.dart';
import 'auth_service.dart';
import '../core/l10n/l10n.dart';

class UserService {
  // Singleton pattern
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  /// Reactive state for the currently logged-in user.
  final ValueNotifier<Map<String, dynamic>?> currentUserNotifier =
      ValueNotifier(null);

  bool get isPremium {
    final user = currentUserNotifier.value;
    if (user == null) return false;

    final role = user['role'];
    final status = user['subscriptionStatus'];
    final expiresAtStr = user['subscriptionExpiresAt'];

    // Creators, Admins, and Editors always have infinite subscription
    if (role == 'CREATOR' || role == 'ADMIN' || role == 'EDITOR') {
      return true;
    }

    // Allow if INFINITE
    if (status == 'INFINITE') {
      return true;
    }

    // Allow if status is ACTIVE or TRIAL
    if (status == 'ACTIVE' || status == 'TRIAL') {
      if (expiresAtStr == null || expiresAtStr.isEmpty) return true;
      try {
        final expiresAt = DateTime.parse(expiresAtStr);
        return expiresAt.isAfter(DateTime.now());
      } catch (_) {
        // If we can't parse the expiration date, allow access as a fallback
        return true;
      }
    }
    
    // If subscription status is null or unknown, allow access to prevent blocking legitimate users
    if (status == null || status.isEmpty) {
      return true;
    }
    
    return false;
  }

  void updateLocalUserPremiumStatus(bool isPremium) {
    if (currentUserNotifier.value != null) {
      // RevenueCat not seeing an entitlement must not override access the
      // backend still grants (INFINITE, staff roles, or an expiry date in
      // the future - e.g. a gift or a manual grant).
      if (!isPremium && this.isPremium) {
        final user = currentUserNotifier.value!;
        final status = user['subscriptionStatus'];
        final expires = DateTime.tryParse(user['subscriptionExpiresAt']?.toString() ?? '');
        final backendStillActive = status == 'INFINITE' ||
            (expires != null && expires.isAfter(DateTime.now()));
        final staff = user['role'] == 'CREATOR' || user['role'] == 'ADMIN' || user['role'] == 'EDITOR';
        if (backendStillActive || staff) return;
      }
      final updated = Map<String, dynamic>.from(currentUserNotifier.value!);
      updated['subscriptionStatus'] = isPremium ? 'ACTIVE' : 'EXPIRED';
      if (isPremium) {
        // A re-subscribing user still carries their old, past expiry date,
        // which would make [isPremium] false right after paying. The real
        // date comes back from the backend on the next profile load.
        final expires = DateTime.tryParse(updated['subscriptionExpiresAt']?.toString() ?? '');
        if (expires != null && expires.isBefore(DateTime.now())) {
          updated['subscriptionExpiresAt'] = null;
        }
      }
      currentUserNotifier.value = updated;
    }
  }

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
        _extractErrorMessage(response.body, appL10n.errLoadProfile),
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
        'measurementSystem': measurementSystem,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentUserNotifier.value = data;
      return data;
    } else {
      throw Exception(
        _extractErrorMessage(response.body, appL10n.errUpdateProfile),
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
        'measurementSystem': measurementSystem,
      }),
    );

    if (response.statusCode == 200) {
      if (currentUserNotifier.value != null) {
        final updated = Map<String, dynamic>.from(currentUserNotifier.value!);
        updated['dietaryPreferences'] = dietaryPreferences;
        updated['allergies'] = allergies;
        updated['foodDislikes'] = foodDislikes;
        updated['flavorDna'] = flavorDna;
        updated['spiceLevel'] = spiceLevel;
        updated['cookingSkill'] = cookingSkill;
        updated['cookingTimePreference'] = cookingTimePreference;
        updated['cookingFrequency'] = cookingFrequency;
        updated['cookingTarget'] = cookingTarget;
        updated['favoriteCuisines'] = favoriteCuisines;
        updated['kitchenAppliances'] = kitchenAppliances;
        updated['mealPlanningStyle'] = mealPlanningStyle;
        updated['notificationPreferences'] = notificationPreferences;
        updated['onboardingGoals'] = onboardingGoals;
        if (language != null) updated['language'] = language;
        if (country != null) updated['country'] = country;
        if (measurementSystem != null) updated['measurementSystem'] = measurementSystem;
        currentUserNotifier.value = updated;
      }
    } else {
      throw Exception(
        _extractErrorMessage(response.body, appL10n.errSavePreferences),
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
        _extractErrorMessage(response.body, appL10n.errChangePassword),
      );
    }
  }

  /// Only the toggles that actually changed need to be passed - the backend
  /// leaves any omitted field untouched.
  Future<void> updateNotificationPreferences({
    bool? pushEnabled,
    bool? pushRemindersEnabled,
    bool? pushNewsOffersEnabled,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/notification-preferences');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (pushRemindersEnabled != null) 'pushRemindersEnabled': pushRemindersEnabled,
        if (pushNewsOffersEnabled != null) 'pushNewsOffersEnabled': pushNewsOffersEnabled,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      currentUserNotifier.value = data;
    } else {
      throw Exception(
        _extractErrorMessage(response.body, appL10n.errNotifSettings),
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
          appL10n.errUploadPhoto,
        ),
      );
    }

    // Refresh user data so the entire app sees the new Cloudinary URL instantly
    await getCurrentUser();
  }

  Future<void> deleteProfilePhoto() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/profile-photo');
      final response = await http.delete(url, headers: await _getHeaders());
      if (response.statusCode == 200 || response.statusCode == 204) {
        await getCurrentUser();
        return;
      }
    } catch (_) {}

    // Fallback: update local user state
    if (currentUserNotifier.value != null) {
      final updated = Map<String, dynamic>.from(currentUserNotifier.value!);
      updated['profilePictureUrl'] = null;
      currentUserNotifier.value = updated;
    }
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

  Future<void> sendWelcomeEmail() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/user/send-welcome-email');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response.body, 'Unable to send welcome email.'),
      );
    }
  }

  Future<void> updateLastActive() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/last-active');
      final response = await http.post(url, headers: await _getHeaders());

      if (response.statusCode != 200) {
      }
    } catch (e) {
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
    }
    return defaultMessage;
  }

  void clearData() {
    currentUserNotifier.value = null;
  }
}
