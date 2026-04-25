import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/device_session.dart';
import 'recipe_service.dart';
import 'cookbook_service.dart';
import 'user_service.dart';
import 'history_service.dart';

class AuthService {
  // Singleton pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  static const String _tokenKey = 'auth_token';

  void _clearAllServiceData() {
    RecipeService.instance.clearData();
    CookbookService.instance.clearData();
    UserService.instance.clearData();
    HistoryService.instance.clearData();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: ApiConfig.googleClientId,
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

  Future<Map<String, dynamic>> register({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? provider,
    String? discoverySource,
    String? otherDiscoverySource,
    List<String>? dietaryPreferences,
    List<String>? allergies,
    List<String>? foodDislikes,
    Map<String, dynamic>? flavorDna,
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

    // Clear any previous session data before starting fresh
    _clearAllServiceData();
    
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'phone': phone,
        'provider': provider ?? 'LOCAL',
        'discoverySource': discoverySource,
        'otherDiscoverySource': otherDiscoverySource,
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['token'] != null) {
          await _saveToken(data['token']);
        }
        return data is Map<String, dynamic> ? data : {};
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
          'Registration failed. Please check your information.',
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
          'Invalid credentials, please try again',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle({
    bool isSignup = false,
    bool isManualBackendCall = true, // If false, just return token + user info
    String? firstname,
    String? lastname,
    String? phone,
  }) async {
    try {
      // 1. Google Sign-In attempt
      print('DEBUG: Starting Google Sign-In process (isSignup: $isSignup)...');
      
      // Force account selection by signing out first
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('DEBUG: Google Sign-In CANCELLED by user');
        throw Exception('Google sign in cancelled');
      }
      
      print('DEBUG: Google account selected: ${googleUser.email}');

      // 2. Obtain Authentication Details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print('DEBUG: ID Token is NULL');
        throw Exception('Missing ID Token from Google');
      }

      print('DEBUG: Google Sign-In SUCCESS locally.');

      if (!isManualBackendCall) {
        return {
          'success': true,
          'email': googleUser.email,
          'idToken': idToken,
          'firstname': googleUser.displayName?.split(' ').first ?? '',
          'lastname': googleUser.displayName?.split(' ').last ?? '',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
      final requestBody = {
        'identifier': googleUser.email,
        'password': idToken,
        'provider': 'GOOGLE',
        'isSignup': isSignup,
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
      };
      
      print('DEBUG: Sending request to Backend: $url');
      // Clear any previous session data before starting fresh
      _clearAllServiceData();
      
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      print('DEBUG: Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return data;
      } else {
        throw Exception(_extractErrorMessage(response.body, 'Incorrect credentials, please try again'));
      }
    } catch (e) {
      print('DEBUG: Google Sign-In ERROR: $e');
      throw Exception(_extractErrorMessage(e.toString(), 'Incorrect credentials, please try again'));
    }
  }

  // Support for min function
  int min(int a, int b) => a < b ? a : b;

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
    
    // Clear any previous session data before starting fresh
    _clearAllServiceData();

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
        throw Exception(_extractErrorMessage(response.body, 'Incorrect credentials, please try again'));
      }
    } catch (e) {
      developer.log('Apple Sign-In Error: $e', name: 'AuthService');
      throw Exception(_extractErrorMessage(e.toString(), 'Incorrect credentials, please try again'));
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
          'Invalid or expired verification code, please try again',
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
          'Invalid or expired reset code, please try again',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/reset-password');
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({'identifier': identifier, 'newPassword': password}),
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
          'Unable to reset password. Please try again.',
        ),
      );
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
      try {
        await http.post(url, headers: ApiConfig.authHeaders(token)).timeout(const Duration(seconds: 5));
      await _googleSignIn.signOut();
    
    // Global reset of all local services data
    _clearAllServiceData();
    
    developer.log('Logged out successfully', name: 'AuthService');
      } catch (e) {
        developer.log('Backend logout failed: $e', name: 'AuthService');
      }
    }
    
    // Deep cleanup: Delete all local data to avoid leaks
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    developer.log('All local data cleared on logout', name: 'AuthService');
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
