import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/paywall_service.dart';

class PaywallScreen extends StatefulWidget {
  final PaywallService paywallService;

  const PaywallScreen({super.key, required this.paywallService});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Map<String, dynamic>? config;
  bool isLoading = true;
  List<ProductDetails> _products = [];
  String _selectedPlanId = 'yearly_sub';
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // Handle error here.
    });
    _loadConfigAndProducts();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _showErrorSnackBar("Erreur lors de l'achat");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Deliver product and complete purchase
          _completePurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    // Propose notification and close
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Achat réussi ! Bienvenue dans Cooked Premium.")),
      );
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _loadConfigAndProducts() async {
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        if (mounted) {
          setState(() {
            isLoading = false;
            // Provide a minimal local config if backend fails or store unavailable
            config = {
              'title': 'Passez au Premium',
              'subtitle': 'Débloquez toutes les fonctionnalités de Cooked',
              'variantKey': 'default',
              'featuresJson': '["Recettes illimitées", "Scan intelligent", "Planification de repas", "Sans publicité"]',
              'yearlyPriceLabel': '29.99€ / an',
              'monthlyPriceLabel': '9.99€ / mois',
              'ctaText': 'S\'abonner maintenant'
            };
          });
        }
        return;
      }

      final data = await widget.paywallService.getRemoteConfig();
      final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails({
        'monthly_sub',
        'yearly_sub',
      });

      if (mounted) {
        setState(() {
          config = data;
          _products = response.productDetails;
          isLoading = false;
        });
        widget.paywallService.trackEvent('paywall_view', data['variantKey']);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar("Erreur lors du chargement du paywall");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Color(0xFF0F0F0F), body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))));
    }

    if (config == null) {
      return const Scaffold(backgroundColor: Color(0xFF0F0F0F), body: Center(child: Text("Indisponible", style: TextStyle(color: Colors.white))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    config!['title'] ?? 'Passez au Premium',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    config!['subtitle'] ?? 'Débloquez toutes les fonctionnalités',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 30.h),
                  
                  ..._buildFeatures(),
                  
                  const Spacer(),

                  _buildPlanCard('yearly_sub', config!['yearlyPriceLabel'] ?? '29.99€ / an', "ÉCONOMISEZ 50%"),
                  SizedBox(height: 12.h),
                  _buildPlanCard('monthly_sub', config!['monthlyPriceLabel'] ?? '9.99€ / mois', ""),

                  SizedBox(height: 30.h),

                  Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _handlePurchase(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        (config!['ctaText'] ?? 'S\'abonner').toUpperCase(),
                        style: TextStyle(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String id, String price, String badge) {
    bool isSelected = _selectedPlanId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = id),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.white10, width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFFFFD700) : Colors.white30),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id == 'yearly_sub' ? "Plan Annuel" : "Plan Mensuel", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(price, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              ],
            ),
            const Spacer(),
            if (badge.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(4)),
                child: Text(badge, style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatures() {
    try {
      final List<dynamic> features = List<dynamic>.from(jsonDecode(config!['featuresJson'] ?? '[]'));
      return features.map((f) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 20),
            SizedBox(width: 12.w),
            Expanded(child: Text(f, style: TextStyle(color: Colors.white, fontSize: 14.sp))),
          ],
        ),
      )).toList();
    } catch (e) {
      return [const Text("Fonctionnalités Premium débloquées", style: TextStyle(color: Colors.white))];
    }
  }

  Future<void> _handlePurchase() async {
    widget.paywallService.trackEvent('paywall_click', config!['variantKey'] ?? 'default', metadata: _selectedPlanId);
    
    if (_products.isEmpty) {
      _showErrorSnackBar("Produits du store indisponibles. Réessayez plus tard.");
      return;
    }

    try {
      final product = _products.firstWhere((p) => p.id == _selectedPlanId);
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _showErrorSnackBar("L'achat n'a pas pu être initié.");
    }
  }
}
