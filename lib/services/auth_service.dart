import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/device_session.dart';

class AuthService {
  // Singleton pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  static const String _tokenKey = 'auth_token';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: ApiConfig.googleClientId,
  );

  // Helper method to retrieve token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Helper method to save token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Helper method to delete token
  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? discoverySource,
    String? otherDiscoverySource,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? foodDislikes,
    Map<String, int>? flavorDna,
    String? spiceLevel,
    String? cookingSkill,
    String? cookingTimePreference,
    String? cookingFrequency,
    String? cookingTarget,
    List<String>? favoriteCuisines,
    List<String>? kitchenAppliances,
    String? mealPlanningStyle,
    List<String>? notificationPreferences,
    List<String>? onboardingGoals,
    int? onboardingRating,
    String? onboardingFeedback,
    String? language,
    String? country,
    String? alternativeRegion,
    String? measurementSystem,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    
    developer.log(
      'Attempting Register: $url',
      name: 'AuthService',
    );
    
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'phone': phone ?? '',
        'provider': 'LOCAL',
        'discoverySource': discoverySource,
        'otherDiscoverySource': otherDiscoverySource,
        'language': language,
        'country': country,
        'alternativeRegion': alternativeRegion,
        'measurementSystem': measurementSystem,
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
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return {};
    } else {
      developer.log(
        'Register error [${response.statusCode}]: ${response.body}',
        name: 'AuthService',
      );
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Inscription échouée. Veuillez vérifier vos informations.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier, // email or phone
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    
    developer.log(
      'Attempting Login: $url',
      name: 'AuthService',
    );
    
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
        'provider': 'LOCAL',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      return data;
    } else {
      developer.log(
        'Login error [${response.statusCode}]: ${response.body}',
        name: 'AuthService',
      );
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Identifiants incorrects ou erreur de connexion.',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Missing ID Token from Google');

      // Send ID Token to backend for verification
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'identifier': googleUser.email,
          'password': idToken, // We pass idToken as password for social providers
          'provider': 'GOOGLE',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('Google Login SUCCESS: ${response.body}', name: 'AuthService');
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return data;
      } else {
        developer.log('Google Login FAILED [${response.statusCode}]: ${response.body}', name: 'AuthService');
        throw Exception(_extractErrorMessage(response.body, 'Google Login failed'));
      }
    } catch (e, stack) {
      developer.log('Google Sign-In Error: $e', name: 'AuthService', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null) throw Exception('Missing ID Token from Apple');

      // Prepare backend call (currently backend restricted as requested)
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'identifier': credential.email ?? 'apple_user',
          'password': identityToken,
          'provider': 'APPLE',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return data;
      } else {
        throw Exception(_extractErrorMessage(response.body, 'Apple Login failed'));
      }
    } catch (e) {
      developer.log('Apple Sign-In Error: $e', name: 'AuthService');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String identifier,
    required String otpCode,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/verify-email');
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'identifier': identifier, 'otpCode': otpCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Code de vérification invalide ou expiré.',
        ),
      );
    }
  }

  Future<void> resendCode(String identifier) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/resend-code');
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'identifier': identifier}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Unable to resend the code. Please try again.',
        ),
      );
    }
  }

  Future<void> forgotPassword(String identifier) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password');
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'identifier': identifier}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Unable to initiate password reset.',
        ),
      );
    }
  }

  Future<void> verifyResetCode({
    required String identifier,
    required String code,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/verify-reset-code');
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'identifier': identifier, 'otpCode': code}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Code de réinitialisation invalide ou expiré.',
        ),
      );
    }
  }

  Future<void> resetPassword({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/reset-password');
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'identifier': identifier, 'newPassword': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response.body,
          'Unable to reset password. Please try again.',
        ),
      );
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
      await http.post(url, headers: ApiConfig.authHeaders(token));
    }
    await _deleteToken();
  }

  Future<List<DeviceSession>> getSessions() async {
    final token = await getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiConfig.baseUrl}/sessions');
    final response = await http.get(url, headers: ApiConfig.authHeaders(token));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DeviceSession.fromJson(e)).toList();
    } else {
      throw Exception('Unable to load active sessions.');
    }
  }

  Future<void> revokeSession(String sessionId) async {
    final token = await getToken();
    if (token == null) return;

    final url = Uri.parse('${ApiConfig.baseUrl}/sessions/$sessionId');
    final response = await http.delete(
      url,
      headers: ApiConfig.authHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to revoke session.');
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
        name: 'AuthService',
      );
    }
    return defaultMessage;
  }
}
