import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/paywall_service.dart';
import '../../services/iap_service.dart';
import '../../core/theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    IapService.instance.onPurchaseSuccess = () {
      if (mounted) {
        setState(() => isLoading = false);
        _completePurchase();
      }
    };
    IapService.instance.onPurchaseError = (error) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar("Erreur: $error");
      }
    };
    _loadConfigAndProducts();
  }

  @override
  void dispose() {
    IapService.instance.onPurchaseSuccess = null;
    IapService.instance.onPurchaseError = null;
    super.dispose();
  }

  Future<void> _completePurchase() async {
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
            config = {
              'title': 'Go Premium',
              'subtitle': 'Unlock all Cooked features',
              'variantKey': 'default',
              'featuresJson': '["Unlimited Recipes", "Smart Scan", "Meal Planning", "No Ads"]',
              'yearlyPriceLabel': '29.99€ / year',
              'monthlyPriceLabel': '9.99€ / month',
              'ctaText': 'Subscribe Now'
            };
          });
        }
        return;
      }

      final data = await widget.paywallService.getRemoteConfig();
      final List<ProductDetails> products = await IapService.instance.getProducts({
        'monthly_sub',
        'yearly_sub',
      });

      if (mounted) {
        setState(() {
          config = data;
          _products = products;
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
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
      );
    }

    if (config == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text("Unavailable", style: TextStyle(color: AppColors.textDark))),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.05),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          SizedBox(height: 5.h),
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.star_rounded, color: AppColors.primary, size: 32.sp),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            config!['title'] ?? 'Go Premium',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            config!['subtitle'] ?? 'Unlock all features',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13.sp),
                          ),
                          SizedBox(height: 25.h),
                          ..._buildFeatures(),
                          SizedBox(height: 25.h),
                          _buildPlanCard('yearly_sub', config!['yearlyPriceLabel'] ?? '29.99€ / an', "ÉCONOMISEZ 50%"),
                          SizedBox(height: 12.h),
                          _buildPlanCard('monthly_sub', config!['monthlyPriceLabel'] ?? '9.99€ / mois', ""),
                          SizedBox(height: 25.h),
                          Container(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: () => _handlePurchase(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              ),
                              child: Text(
                                (config!['ctaText'] ?? 'Subscribe').toUpperCase(),
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          if (Platform.isIOS)
                            TextButton(
                              onPressed: () {
                                setState(() => isLoading = true);
                                IapService.instance.restorePurchases();
                              },
                              child: Text(
                                "Restore Purchases",
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                              ),
                            ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.textMuted.withOpacity(0.5),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id == 'yearly_sub' ? "Yearly Plan" : "Monthly Plan",
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
                ),
              ],
            ),
            const Spacer(),
            if (badge.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatures() {
    try {
      final List<dynamic> features = List<dynamic>.from(jsonDecode(config!['featuresJson'] ?? '[]'));
      return features
          .map((f) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(color: AppColors.textDark, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ))
          .toList();
    } catch (e) {
      return [const Text("Premium Features Unlocked", style: TextStyle(color: AppColors.textDark))];
    }
  }

  Future<void> _handlePurchase() async {
    widget.paywallService.trackEvent('paywall_click', config!['variantKey'] ?? 'default', metadata: _selectedPlanId);
    if (_products.isEmpty) {
      _showErrorSnackBar("Store products unavailable. Try again later.");
      return;
    }
    try {
      final product = _products.firstWhere((p) => p.id == _selectedPlanId);
      setState(() => isLoading = true);
      await IapService.instance.buyProduct(product);
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("Purchase could not be initiated.");
    }
  }
}
