import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/paywall_service.dart';
import '../../services/iap_service.dart';
import '../../core/utils/error_helper.dart';
import '../../services/user_service.dart';

enum PaywallFlowType { standard, offer }

class PaywallScreen extends StatefulWidget {
  final PaywallService paywallService;
  final PaywallFlowType flowType;

  const PaywallScreen({
    super.key,
    required this.paywallService,
    this.flowType = PaywallFlowType.standard,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Map<String, dynamic>? config;
  bool isLoading = true;
  List<ProductDetails> _products = [];
  String _selectedPlanId = 'yearly_sub';

  bool get isOffer => widget.flowType == PaywallFlowType.offer;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    _selectedPlanId = 'yearly_sub';
    _initIap();
    _loadConfigAndProducts();
    // Refresh user data in background to ensure latest premium status
    UserService.instance.getCurrentUser().catchError((_) => {});
  }

  void _initIap() {
    IapService.instance.initialize();
    IapService.instance.onPurchaseSuccess = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Premium Activated! Welcome to the Chef Club."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    };
    IapService.instance.onPurchaseError = (error) {
      _showErrorSnackBar(ErrorHelper.getFriendlyMessage(error));
    };
  }

  @override
  void dispose() {
    IapService.instance.onPurchaseSuccess = null;
    IapService.instance.onPurchaseError = null;
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _loadConfigAndProducts() async {
    try {
      final data = await widget.paywallService.getRemoteConfig(
        flow: widget.flowType == PaywallFlowType.offer ? 'OFFER' : null,
      );

      final products = await IapService.instance.getProducts({
        'monthly_sub',
        'yearly_sub',
      });

      if (mounted) {
        setState(() {
          config = data;
          _products = products;
          isLoading = false;
        });
        widget.paywallService.trackEvent(
          'paywall_view',
          data['variantKey'] ?? widget.flowType.toString(),
        );
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
    if (widget.flowType == PaywallFlowType.offer) {
      return {
        'title': 'Special comeback offer',
        'yearlyPriceLabel': '\$19.99 / year',
        'monthlyPriceLabel': '\$9.99 / month',
        'ctaText': 'Unlock Premium for \$19.99',
      };
    }
    return {
      'title': 'Unlock Cooked to keep \ncreating recipes.',
      'yearlyPriceLabel': '\$2.49 / mo',
      'monthlyPriceLabel': '\$9.99 / month',
      'ctaText': 'Unlock Premium',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
        ),
      );
    }

    final bool isOffer = widget.flowType == PaywallFlowType.offer;
    final primaryColor = const Color(0xFFC83A2D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          config!['title'] ?? '',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'SF Pro',
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF7B8190), size: 28),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  if (isOffer) ...[
                    _buildTimelineItem(
                      icon: 'crown.svg',
                      title: 'Special Offer',
                      description:
                          "Unlock all features forever with this limited discount.",
                      color: primaryColor,
                      isFirst: true,
                    ),
                    _buildTimelineItem(
                      icon: 'unlock.svg',
                      title: 'Unlimited Access',
                      description:
                          "Scan your fridge and import recipes without any limits.",
                      color: primaryColor,
                    ),
                    _buildTimelineItem(
                      icon: 'star.svg',
                      title: 'Exclusive Recipes',
                      description:
                          "Access premium recipes and themed cookbooks.",
                      color: primaryColor,
                      isLast: true,
                    ),
                  ] else ...[
                    _buildTimelineItem(
                      icon: 'unlock.svg',
                      title: 'Immediate Access',
                      description:
                          "Scan your ingredients and import recipes from any link.",
                      color: const Color(0xFFF97316),
                      isFirst: true,
                    ),
                    _buildTimelineItem(
                      icon: 'star.svg',
                      title: 'Exclusive Content',
                      description:
                          "Access premium generated recipes and themed cookbooks.",
                      color: const Color(0xFFEAB308),
                    ),
                    _buildTimelineItem(
                      icon: 'crown.svg',
                      title: 'Master Chef Status',
                      description:
                          "Enjoy a complete ad-free experience with priority AI processing.",
                      color: const Color(0xFFEAB308),
                      isLast: true,
                    ),
                  ],

                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      if (!isOffer) ...[
                        Expanded(
                          child: _buildPlanCard(
                            id: 'monthly_sub',
                            title: 'Monthly',
                            price: _getProductPrice(
                              'monthly_sub',
                              config!['monthlyPriceLabel'],
                            ),
                            isSelected: _selectedPlanId == 'monthly_sub',
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 16.w),
                      ],
                      Expanded(
                        child: _buildPlanCard(
                          id: 'yearly_sub',
                          title: 'Yearly',
                          price: _getProductPrice(
                            'yearly_sub',
                            config!['yearlyPriceLabel'],
                          ),
                          subPrice: !isOffer ? '(\$29.99 / year)' : null,
                          isSelected: _selectedPlanId == 'yearly_sub',
                          badge: isOffer ? '33% OFF' : 'BEST VALUE',
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 160.h), 
                ],
              ),
            ),
          ),

          // Sticky Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24.w, 
                10.h, 
                24.w, 
                10.h + MediaQuery.of(context).padding.bottom
              ),
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
              child: ValueListenableBuilder<Map<String, dynamic>?>(
                valueListenable: UserService.instance.currentUserNotifier,
                builder: (context, user, _) {
                  final bool isUserPremium = UserService.instance.isPremium;
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isOffer) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isUserPremium)
                              Container(
                                padding: EdgeInsets.all(2.r),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check, color: Colors.white, size: 14.sp),
                              )
                            else
                              Icon(Icons.check, color: Colors.black, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              isUserPremium 
                                  ? "You are already a Premium member!" 
                                  : "Immediate Premium Access",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: isUserPremium ? Colors.green : Colors.black,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: isUserPremium ? null : _handlePurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUserPremium ? const Color(0xFFE5E7EB) : primaryColor,
                            disabledBackgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: const Color(0xFF9CA3AF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isUserPremium ? 'Active Subscription' : (config!['ctaText'] ?? 'Subscribe now'),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ),
                      ),
                      if (!isOffer) ...[
                        SizedBox(height: 12.h),
                        Text(
                          "\$29.99 per year (\$2.49/mo)",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF7B8190),
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  );
                }
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
    required Color color,
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
                  border: Border.all(color: color, width: 1.5.w),
                  color: Colors.white,
                ),
                child: SvgPicture.asset(
                  'assets/icones/$icon',
                  width: double.infinity,
                  height: double.infinity,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 5.w, color: color.withOpacity(0.2)),
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
    String? subPrice,
    required bool isSelected,
    required Color color,
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
                color: isSelected ? color : const Color(0xFFE5E7EB),
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
                        color: isSelected
                            ? const Color(0xFF0D1B3E)
                            : const Color(0xFF7B8190),
                        fontFamily: 'SF Pro',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    Container(
                      width: 20.sp,
                      height: 20.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE5E7EB),
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
                if (subPrice != null)
                  Text(
                    subPrice,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF7B8190),
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
                  color: color,
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
    widget.paywallService.trackEvent(
      'paywall_click',
      config!['variantKey'] ?? widget.flowType.toString(),
      metadata: _selectedPlanId,
    );

    if (_products.isEmpty) {
      setState(() => isLoading = true);
      try {
        final products = await IapService.instance.getProducts({
          'monthly_sub',
          'yearly_sub',
        });
        if (mounted) {
          setState(() {
            _products = products;
            isLoading = false;
          });
        }
        if (products.isEmpty) {
          _showErrorSnackBar("Store unavailable. Please check your connection or try again later.");
          return;
        }
      } catch (e) {
        if (mounted) setState(() => isLoading = false);
        _showErrorSnackBar("Could not connect to the Store.");
        return;
      }
    }

    try {
      ProductDetails? product;
      for (var p in _products) {
        if (p.id == _selectedPlanId) {
          product = p;
          break;
        }
      }
      
      // Fallback if ID doesn't match
      product ??= _products.first;

      final success = await IapService.instance.buyProduct(product);
      if (!success) {
        _showErrorSnackBar("Could not initiate purchase with the Store.");
      }
    } catch (e) {
      _showErrorSnackBar("Purchase failed: ${e.toString()}");
    }
  }
}
