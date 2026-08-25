import 'revenuecat_service.dart';

class IapService {
  IapService._privateConstructor();
  static final IapService instance = IapService._privateConstructor();

  Function()? get onPurchaseSuccess => RevenueCatService.instance.onPurchaseSuccess;
  set onPurchaseSuccess(Function()? callback) {
    RevenueCatService.instance.onPurchaseSuccess = callback;
  }

  Function(String)? get onPurchaseError => RevenueCatService.instance.onPurchaseError;
  set onPurchaseError(Function(String)? callback) {
    RevenueCatService.instance.onPurchaseError = callback;
  }

  void initialize({String? userId}) {
    RevenueCatService.instance.initialize(userId: userId);
  }

  void dispose() {}

  Future<bool> restorePurchases() async {
    return await RevenueCatService.instance.restorePurchases();
  }
}
