import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_service.dart';

class IapService {
  IapService._privateConstructor();
  static final IapService instance = IapService._privateConstructor();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  Function()? onPurchaseSuccess;
  Function(String)? onPurchaseError;

  void initialize() {
    if (_isInitialized) return;
    
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
        _isInitialized = false;
      },
      onError: (error) {
        onPurchaseError?.call(error.toString());
      },
    );
    _isInitialized = true;
  }

  void dispose() {
    // We don't want individual screens to dispose the global singleton subscription
    // If we really need to dispose, we'd need another method or check.
    // For now, let's just nullify callbacks.
    onPurchaseSuccess = null;
    onPurchaseError = null;
  }

  Future<List<ProductDetails>> getProducts(Set<String> productIds) async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      return [];
    }
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(productIds);
    return response.productDetails;
  }

  Future<bool> buyProduct(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );
    return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending status if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          onPurchaseError?.call(
            purchaseDetails.error?.message ?? 'Purchase error',
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify the purchase on the backend
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid && onPurchaseSuccess != null) {
            onPurchaseSuccess!();
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final platform = (purchaseDetails.verificationData.source == 'app_store')
          ? 'IOS'
          : 'ANDROID';
      await SubscriptionService.instance.verifyReceipt(
        productId: purchaseDetails.productID,
        purchaseToken: purchaseDetails.verificationData.serverVerificationData,
        platform: platform,
      );
      return true;
    } catch (e) {
      onPurchaseError?.call('Backend verification failed: ${e.toString()}');
      return false;
    }
  }
}
