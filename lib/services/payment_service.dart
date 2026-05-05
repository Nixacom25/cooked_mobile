import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  final String backendUrl;
  final String authToken;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  PaymentService({required this.backendUrl, required this.authToken}) {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // Gérer l'erreur de flux
    });
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Afficher loader
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Gérer erreur (Tracking analytics purchase_failed)
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          // VALIDATION SERVEUR (OBLIGATOIRE)
          bool valid = await _verifyPurchaseOnServer(purchaseDetails);
          
          if (valid) {
            if (purchaseDetails.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchaseDetails);
            }
          }
        }
      }
    }
  }

  Future<bool> _verifyPurchaseOnServer(PurchaseDetails purchase) async {
    final response = await http.post(
      Uri.parse('$backendUrl/api/subscription/verify-receipt'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'transactionId': purchase.purchaseID,
        'verificationData': purchase.verificationData.serverVerificationData,
        'source': Platform.isAndroid ? 'google_play' : 'app_store',
        'plan': purchase.productID.contains('monthly') ? 'monthly' : 'yearly',
      }),
    );

    return response.statusCode == 200;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    if (product.id.contains('sub')) {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    }
  }
}
