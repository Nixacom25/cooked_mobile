import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/api_config.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'store_price_service.dart';
import 'error_monitoring_service.dart';
import '../core/l10n/l10n.dart';

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

        // Identify the RevenueCat customer with our own user id, so webhooks
        // (subscriptions, gift purchases) and server-side grants (redeemed
        // gifts) can be matched to the account instead of an anonymous id.
        UserService.instance.currentUserNotifier.addListener(_syncIdentity);
        _syncIdentity();
      }
    } catch (e) {
    }
  }

  String? _identifiedUserId;

  void _syncIdentity() {
    final id = UserService.instance.currentUserNotifier.value?['id']?.toString();
    if (id != null && id.isNotEmpty) {
      if (id != _identifiedUserId) {
        _identifiedUserId = id;
        logIn(id);
      }
    } else if (_identifiedUserId != null) {
      _identifiedUserId = null;
      logOut();
    }
  }

  /// Makes sure RevenueCat knows the signed-in user and has fresh
  /// entitlements before the app decides where to send them. The backend's
  /// copy of the subscription can lag behind (missed webhook), which made a
  /// subscribed user see "subscription required" until they relaunched.
  Future<void> identifyNow() async {
    if (!_isInitialized) return;
    final id = UserService.instance.currentUserNotifier.value?['id']?.toString();
    if (id == null || id.isEmpty) return;
    if (id != _identifiedUserId) {
      _identifiedUserId = id;
      await logIn(id);
    } else {
      await refreshCustomerInfo();
    }
  }

  // ── Gifts (consumable in-app purchases) ────────────────────────────────
  static const String giftOneYearProductId = 'gift_1_year';
  static const String giftThreeMonthsProductId = 'gift_3_months';

  Future<List<StoreProduct>> getGiftProducts() async {
    try {
      return await Purchases.getProducts(
        [giftOneYearProductId, giftThreeMonthsProductId],
        productCategory: ProductCategory.nonSubscription,
      );
    } catch (e) {
      return [];
    }
  }

  /// Buys one gift card. Returns false if the user cancelled; throws on
  /// store errors. The gift code itself is created by the backend once
  /// RevenueCat's webhook confirms the purchase.
  Future<bool> purchaseGift(StoreProduct product) async {
    try {
      await Purchases.purchase(PurchaseParams.storeProduct(product));
      return true;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      await ErrorMonitoringService.instance.recordPaymentFailure(
        productId: product.identifier,
        reason: e.message ?? 'Gift purchase error',
      );
      rethrow;
    }
  }

  /// Re-reads entitlements after the backend granted premium (redeemed gift).
  Future<void> refreshCustomerInfo() async {
    if (!_isInitialized) return;
    try {
      await Purchases.invalidateCustomerInfoCache();
      _updateUserPremiumStatus(await Purchases.getCustomerInfo());
    } catch (e) {
    }
  }

  Future<void> logIn(String userId) async {
    if (!_isInitialized) return;
    try {
      LogInResult result = await Purchases.logIn(userId);
      _updateUserPremiumStatus(result.customerInfo);
    } catch (e) {
    }
  }

  Future<void> logOut() async {
    if (!_isInitialized) return;
    try {
      CustomerInfo customerInfo = await Purchases.logOut();
      _updateUserPremiumStatus(customerInfo);
    } catch (e) {
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
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
      onPurchaseError?.call(appL10n.errPurchaseNotActive);
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
        onPurchaseError?.call(e.message ?? appL10n.errPurchase);
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
        onPurchaseError?.call(appL10n.subNothingToRestore);
        return false;
      }
    } catch (e) {
      onPurchaseError?.call(appL10n.payRestoreFailed(e.toString()));
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

      // Real localized store price of the subscribed plan (e.g.
      // "29,99 €/year") so backend reminders never use a hardcoded price.
      String? priceLabel;
      final productId = entitlementInfo?.productIdentifier;
      if (productId != null) {
        try {
          await StorePriceService.instance.load().timeout(const Duration(seconds: 5));
          priceLabel = StorePriceService.instance.prices.value.labelFor(productId);
        } catch (_) {}
      }

      final Map<String, dynamic> subscriptionData = {
        'isActive': entitlementInfo?.isActive ?? false,
        'expirationDate': entitlementInfo?.expirationDate ?? '',
        'productId': entitlementInfo?.productIdentifier,
        'latestPurchaseDate': entitlementInfo?.latestPurchaseDate ?? '',
        'willRenew': entitlementInfo?.willRenew,
        'periodType': entitlementInfo?.periodType.toString(),
        'revenueCatCustomerId': customerInfo.originalAppUserId,
        if (priceLabel != null) 'priceLabel': priceLabel,
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
      }
    } catch (e) {
    }
  }
}
