import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'user_service.dart';

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

  Future<bool> buyPackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      bool isSubscribed = customerInfo.entitlements.all[premiumEntitlementId]?.isActive ?? false;
      
      _updateUserPremiumStatus(customerInfo);

      if (isSubscribed) {
        onPurchaseSuccess?.call();
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        onPurchaseError?.call(e.message ?? 'Purchase error occurred');
      }
      return false;
    } catch (e) {
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
    if (isSubscribed) {
      UserService.instance.updateLocalUserPremiumStatus(true);
    }
  }
}
