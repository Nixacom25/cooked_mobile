import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:cooked/services/user_service.dart';
import 'package:cooked/core/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ErrorMonitoringService {
  ErrorMonitoringService._privateConstructor();
  static final ErrorMonitoringService instance = ErrorMonitoringService._privateConstructor();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    // Set user identifier for better error tracking
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null && user['id'] != null) {
      await _crashlytics.setUserIdentifier(user['id'].toString());
    }
  }

  Future<void> updateUser() async {
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null && user['id'] != null) {
      await _crashlytics.setUserIdentifier(user['id'].toString());
      await _crashlytics.setCustomKey('user_email', user['email']?.toString() ?? 'unknown');
      await _crashlytics.setCustomKey('user_role', user['role']?.toString() ?? 'unknown');
    }
  }

  Future<void> recordError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
    bool isCritical = false,
  }) async {
    try {
      // Record to Firebase Crashlytics
      await _crashlytics.recordError(
        Exception(errorMessage),
        stackTrace != null ? StackTrace.fromString(stackTrace) : StackTrace.current,
        fatal: isCritical,
        information: [
          'Error Type: $errorType',
          'Error Message: $errorMessage',
          if (context != null) ...context.entries.map((e) => '${e.key}: ${e.value}'),
        ],
      );

      // Set custom keys for better filtering
      await _crashlytics.setCustomKey('error_type', errorType);
      await _crashlytics.setCustomKey('is_critical', isCritical.toString());
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Send critical errors to backend for admin visibility and email alerts
      if (isCritical) {
        await _sendCriticalErrorToBackend(
          errorType: errorType,
          errorMessage: errorMessage,
          stackTrace: stackTrace,
          context: context,
        );
      }

      debugPrint('🚨 [ErrorMonitoring] $errorType: $errorMessage (Critical: $isCritical)');
    } catch (e) {
      debugPrint('❌ [ErrorMonitoring] Failed to record error: $e');
    }
  }

  Future<void> _sendCriticalErrorToBackend({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      final user = UserService.instance.currentUserNotifier.value;
      final userId = user?['id']?.toString();
      final userEmail = user?['email']?.toString();

      final deviceInfo = {
        'platform': Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web',
        'os_version': Platform.operatingSystemVersion,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/errors/critical'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'errorType': errorType,
          'errorMessage': errorMessage,
          'stackTrace': stackTrace,
          'userId': userId,
          'userEmail': userEmail,
          'platform': deviceInfo['platform'],
          'osVersion': deviceInfo['os_version'],
          'appVersion': '1.0.2', // Should be synchronized with support_service.dart
          'context': context,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [ErrorMonitoring] Critical error sent to backend successfully');
      } else {
        debugPrint('⚠️ [ErrorMonitoring] Failed to send critical error to backend: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [ErrorMonitoring] Exception sending critical error to backend: $e');
    }
  }

  // Specific error recording methods for common scenarios

  Future<void> recordApiFailure({
    required String endpoint,
    required String errorMessage,
    int? statusCode,
    String? requestId,
  }) async {
    await recordError(
      errorType: 'API_FAILURE',
      errorMessage: errorMessage,
      context: {
        'endpoint': endpoint,
        'status_code': statusCode?.toString() ?? 'unknown',
        'request_id': requestId ?? 'unknown',
      },
      isCritical: statusCode != null && statusCode >= 500,
    );
  }

  Future<void> recordScanFailure({
    required String reason,
    String? scanType,
  }) async {
    await recordError(
      errorType: 'SCAN_FAILURE',
      errorMessage: reason,
      context: {
        'scan_type': scanType ?? 'unknown',
      },
      isCritical: true,
    );
  }

  Future<void> recordIngredientDetectionFailure({
    required String reason,
  }) async {
    await recordError(
      errorType: 'INGREDIENT_DETECTION_FAILURE',
      errorMessage: reason,
      isCritical: true,
    );
  }

  Future<void> recordRecipeGenerationFailure({
    required String reason,
  }) async {
    await recordError(
      errorType: 'RECIPE_GENERATION_FAILURE',
      errorMessage: reason,
      isCritical: true,
    );
  }

  Future<void> recordImportFailure({
    required String url,
    required String reason,
  }) async {
    await recordError(
      errorType: 'IMPORT_FAILURE',
      errorMessage: reason,
      context: {
        'import_url': url,
      },
      isCritical: false,
    );
  }

  Future<void> recordPaymentFailure({
    required String productId,
    required String reason,
  }) async {
    await recordError(
      errorType: 'PAYMENT_FAILURE',
      errorMessage: reason,
      context: {
        'product_id': productId,
      },
      isCritical: true,
    );
  }

  Future<void> recordAuthFailure({
    required String reason,
    String? authMethod,
  }) async {
    await recordError(
      errorType: 'AUTH_FAILURE',
      errorMessage: reason,
      context: {
        'auth_method': authMethod ?? 'unknown',
      },
      isCritical: true,
    );
  }

  Future<void> recordRiveAnimationFailure({
    required String animationName,
    required String reason,
  }) async {
    await recordError(
      errorType: 'RIVE_ANIMATION_FAILURE',
      errorMessage: reason,
      context: {
        'animation_name': animationName,
      },
      isCritical: false,
    );
  }

  Future<void> recordScreenError({
    required String screenName,
    required String errorMessage,
  }) async {
    await recordError(
      errorType: 'SCREEN_ERROR',
      errorMessage: errorMessage,
      context: {
        'screen_name': screenName,
      },
      isCritical: false,
    );
  }
}