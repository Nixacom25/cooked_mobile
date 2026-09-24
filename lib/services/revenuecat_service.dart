import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/api_config.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'error_monitoring_service.dart';

class RevenueCatService {
  RevenueCatService._privateConstructor();
  static final RevenueCatService instance = RevenueCatService._privateConstructor();

  // RevenueCat Public API Keys (Replace with your actual keys from RevenueCat Dashboard)
  static const String _appleApiKey = 'appl_KydPawFScfkuOWNyDtoJyTZHYnn';
  static const String _googleApiKey = 'goog_sutqrppuWHniyEBbZUiQmkpHkds';
  
  // Entitlement ID defined in RevenueCat Dashboard (default: 'premium')
  static const String premiumEntitlementId = 'premium';

  bool _isInitialized = false;

  Function()? onPurchaseSuccess;
  Function(String)? onPurchaseError;

  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;

    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      PurchasesConfiguration? configuration;
      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_appleApiKey);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_googleApiKey);
      }

      if (configuration != null) {
        if (userId != null && userId.isNotEmpty) {
          configuration.appUserID = userId;
        }
        await Purchases.configure(configuration);
        _isInitialized = true;
        
        // Listen to purchaser info updates
        Purchases.addCustomerInfoUpdateListener((customerInfo) {
          _updateUserPremiumStatus(customerInfo);
        });

        // Initial check
        final customerInfo = await Purchases.getCustomerInfo();
        _updateUserPremiumStatus(customerInfo);
      }
    } catch (e) {
      debugPrint("RevenueCat initialization error: $e");
    }
  }

  Future<void> logIn(String userId) async {
    if (!_isInitialized) return;
    try {
      LogInResult result = await Purchases.logIn(userId);
      _updateUserPremiumStatus(result.customerInfo);
    } catch (e) {
      debugPrint("RevenueCat logIn error: $e");
    }
  }

  Future<void> logOut() async {
    if (!_isInitialized) return;
    try {
      CustomerInfo customerInfo = await Purchases.logOut();
      _updateUserPremiumStatus(customerInfo);
    } catch (e) {
      debugPrint("RevenueCat logOut error: $e");
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint("RevenueCat getOfferings error: $e");
      return null;
    }
  }

  /// Whether this Apple/Google account is actually eligible for the
  /// product's configured free trial / intro price - not just whether the
  /// product *has* one configured. Apple only grants a subscription-group
  /// trial once per account, so a returning subscriber can have an
  /// introductoryPrice on the product while being ineligible to receive it
  /// again. Defaults to false (don't promise a trial) if this can't be
  /// determined, since promising one Apple won't honor is worse than not
  /// showing the badge.
  Future<bool> isEligibleForTrial(String productIdentifier) async {
    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
        [productIdentifier],
      );
      return result[productIdentifier]?.status ==
          IntroEligibilityStatus.introEligibilityStatusEligible;
    } catch (e) {
      debugPrint("RevenueCat checkTrialOrIntroductoryPriceEligibility error: $e");
      return false;
    }
  }

  Future<bool> buyPackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchase(PurchaseParams.package(package));
      CustomerInfo customerInfo = purchaseResult.customerInfo;
      bool isSubscribed = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;

      _updateUserPremiumStatus(customerInfo);

      if (isSubscribed) {
        onPurchaseSuccess?.call();
        return true;
      }
      // Purchase succeeded but subscription not active
      onPurchaseError?.call('Purchase completed but subscription not active');
      return false;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled - notify UI to reset loading
        onPurchaseError?.call('cancelled');
      } else {
        await ErrorMonitoringService.instance.recordPaymentFailure(
          productId: package.identifier,
          reason: e.message ?? 'Purchase error occurred',
        );
        onPurchaseError?.call(e.message ?? 'Purchase error occurred');
      }
      return false;
    } catch (e) {
      await ErrorMonitoringService.instance.recordPaymentFailure(
        productId: package.identifier,
        reason: e.toString(),
      );
      onPurchaseError?.call(e.toString());
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      bool isSubscribed = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
      
      _updateUserPremiumStatus(customerInfo);

      if (isSubscribed) {
        onPurchaseSuccess?.call();
        return true;
      } else {
        onPurchaseError?.call("No active subscriptions found to restore.");
        return false;
      }
    } catch (e) {
      onPurchaseError?.call("Restore purchases failed: ${e.toString()}");
      return false;
    }
  }

  Future<bool> isPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  void _updateUserPremiumStatus(CustomerInfo customerInfo) {
    final bool isSubscribed = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
    final entitlementInfo = customerInfo.entitlements.all[premiumEntitlementId];
    
    if (isSubscribed) {
      UserService.instance.updateLocalUserPremiumStatus(true);
      
      // Sync subscription details with backend
      _syncSubscriptionWithBackend(customerInfo, entitlementInfo);
    } else {
      UserService.instance.updateLocalUserPremiumStatus(false);
      
      // Check if subscription expired and sync with backend
      if (entitlementInfo != null && entitlementInfo.expirationDate != null) {
        _syncSubscriptionWithBackend(customerInfo, entitlementInfo);
      }
    }
  }

  Future<void> _syncSubscriptionWithBackend(CustomerInfo customerInfo, EntitlementInfo? entitlementInfo) async {
    try {
      final user = UserService.instance.currentUserNotifier.value;
      if (user == null || user['id'] == null) return;

      final Map<String, dynamic> subscriptionData = {
        'isActive': entitlementInfo?.isActive ?? false,
        'expirationDate': entitlementInfo?.expirationDate ?? '',
        'productId': entitlementInfo?.productIdentifier,
        'latestPurchaseDate': entitlementInfo?.latestPurchaseDate ?? '',
        'willRenew': entitlementInfo?.willRenew,
        'periodType': entitlementInfo?.periodType.toString(),
        'revenueCatCustomerId': customerInfo.originalAppUserId,
      };

      // Send subscription data to backend
      final authToken = await AuthService.instance.getToken();
      if (authToken == null || authToken.isEmpty) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/sync-subscription'),
        headers: ApiConfig.authHeaders(authToken),
        body: jsonEncode(subscriptionData),
      );

      if (response.statusCode == 200) {
        debugPrint('Subscription synced with backend successfully');
      }
    } catch (e) {
      debugPrint('Failed to sync subscription with backend: $e');
    }
  }
}
