import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
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
          _showErrorSnackBar("Purchase error");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _completePurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Welcome to Cooked Premium!")),
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
            config = _getDefaultConfig();
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
        setState(() {
          isLoading = false;
          config = _getDefaultConfig();
        });
      }
    }
  }

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'title': 'Start your 3-day FREE\ntrial to continue.',
      'subtitle': 'Unlock all Cooked features',
      'variantKey': 'default',
      'yearlyPriceLabel': '\$29.99',
      'monthlyPriceLabel': '\$9.99',
      'ctaText': 'Start My 3-Day Free Trial'
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC83A2D))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF7B8190)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    config!['title'] ?? 'Start your 3-day FREE\ntrial to continue.',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'SF Pro',
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 28.h),

                  _buildTimelineItem(
                    icon: 'unlock.svg',
                    title: 'Today',
                    description: "Unlock all features: Unlimited AI Scan, exclusive recipes, and more.",
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    icon: 'bell-part.svg',
                    title: 'In 2 Days - Reminder',
                    description: "We'll send you a reminder before your trial ends.",
                  ),
                  _buildTimelineItem(
                    icon: 'crown.svg',
                    title: 'In 3 Days - Billing Starts',
                    description: "Your subscription starts on ${DateFormat('MMM d, yyyy').format(DateTime.now().add(const Duration(days: 3)))} (Cancel anytime).",
                    isLast: true,
                  ),

                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildPlanCard(
                          id: 'monthly_sub',
                          title: 'Monthly',
                          price: _getProductPrice('monthly_sub', config!['monthlyPriceLabel']),
                          isSelected: _selectedPlanId == 'monthly_sub',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildPlanCard(
                          id: 'yearly_sub',
                          title: 'Yearly',
                          price: _getProductPrice('yearly_sub', config!['yearlyPriceLabel']),
                          isSelected: _selectedPlanId == 'yearly_sub',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),

          // Sticky Bottom Button with SafeArea
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC83A2D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Subscribe now',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProductPrice(String id, String defaultPrice) {
    if (_products.isEmpty) return defaultPrice;
    try {
      return _products.firstWhere((p) => p.id == id).price;
    } catch (_) {
      return defaultPrice;
    }
  }

  Widget _buildTimelineItem({
    required String icon,
    required String title,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC83A2D),
                    width: 1.5.w,
                  ),
                  color: Colors.white,
                ),
                child: SvgPicture.asset(
                  'assets/icones/$icon',
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 4.w,
                    color: const Color(0xFFC83A2D).withOpacity(0.2),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D1B3E),
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF7B8190),
                    fontFamily: 'SF Pro',
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required bool isSelected,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = id),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                width: isSelected ? 2.w : 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected ? const Color(0xFF0D1B3E) : const Color(0xFF7B8190),
                        fontFamily: 'SF Pro',
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    Container(
                      width: 20.sp,
                      height: 20.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                          width: isSelected ? 6.sp : 1.sp,
                        ),
                        color: isSelected ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0D1B3E),
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC83A2D),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SF Pro',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    widget.paywallService.trackEvent('paywall_click', config!['variantKey'] ?? 'default', metadata: _selectedPlanId);
    
    if (_products.isEmpty) {
      _showErrorSnackBar("Payment services unavailable.");
      return;
    }

    try {
      final product = _products.firstWhere((p) => p.id == _selectedPlanId);
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _showErrorSnackBar("Purchase failed.");
    }
  }
}
