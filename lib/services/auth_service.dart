import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_ecommerce/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  final ValueNotifier<Map<String, dynamic>?> currentUser =
      ValueNotifier<Map<String, dynamic>?>(null);
  final ValueNotifier<bool> isBannerVisible = ValueNotifier<bool>(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        await fetchCurrentUser();
      } catch (e) {
        // Token might be expired
        await logout();
      }
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);

        await fetchCurrentUser();
      } else {
        throw Exception('Identifiants incorrects');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await ApiService.post('/auth/register', userData);
      // After registration, user needs to login
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await ApiService.get('/users/me');
      currentUser.value = user;
      isLoggedIn.value = true;
      isBannerVisible.value = false;
    } catch (e) {
      debugPrint('Fetch user error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    isLoggedIn.value = false;
    currentUser.value = null;
    isBannerVisible.value = true;
  }

  Future<void> updateProfile(Map<String, dynamic> userData) async {
    try {
      await ApiService.put('/users/profile', userData);
      await fetchCurrentUser(); // Refresh local state
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmationPassword,
  ) async {
    try {
      await ApiService.post('/users/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmationPassword': confirmationPassword,
      });
    } catch (e) {
      debugPrint('Change password error: $e');
      rethrow;
    }
  }

  void dismissBanner() {
    isBannerVisible.value = false;
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Impossible de récupérer le jeton Firebase');
      }

      final response = await ApiService.post('/auth/social-login', {
        'provider': 'google',
        'idToken': firebaseIdToken,
        'firstName': userCredential.user?.displayName?.split(' ').first,
        'lastName': userCredential.user?.displayName?.split(' ').last,
      });

      if (response != null && response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await fetchCurrentUser();
      } else {
        throw Exception('Erreur lors de la connexion sociale');
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Impossible de récupérer le jeton Firebase');
      }

      final response = await ApiService.post('/auth/social-login', {
        'provider': 'apple',
        'idToken': firebaseIdToken,
        'firstName': userCredential.user?.displayName?.split(' ').first,
        'lastName': userCredential.user?.displayName?.split(' ').last,
      });

      if (response != null && response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await fetchCurrentUser();
      } else {
        throw Exception('Erreur lors de la connexion sociale');
      }
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      rethrow;
    }
  }
}
