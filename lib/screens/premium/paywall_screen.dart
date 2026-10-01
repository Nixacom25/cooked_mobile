import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/paywall_service.dart';
import '../../services/iap_service.dart';
import '../../services/revenuecat_service.dart';
import '../../core/utils/error_helper.dart';
import '../../services/user_service.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_button.dart';
import '../../widgets/skeleton_loader.dart';
import '../../core/widgets/legal_content_modal.dart';
import '../../core/widgets/terms_validation_modal.dart' show dummyTerms, dummyPrivacy;
import '../../core/theme/app_theme.dart';
import '../../core/l10n/l10n.dart';

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
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _selectedPackage;
  String _selectedPlanId = 'yearly_sub';
  // Whether *this* customer is actually eligible for the yearly plan's free
  // trial (per StoreKit/Play Billing), not just whether the product has one
  // configured - starts false so the paywall never promises a trial before
  // eligibility is confirmed.
  bool _yearlyTrialEligible = false;

  bool get isOffer => widget.flowType == PaywallFlowType.offer;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    _selectedPlanId = 'yearly_sub';
    
    // Check if user is creator, admin, editor or has INFINITE subscription - they should not see paywall
    final user = UserService.instance.currentUserNotifier.value;
    if (user != null && (user['role'] == 'CREATOR' || user['role'] == 'ADMIN' || user['role'] == 'EDITOR' || user['subscriptionStatus'] == 'INFINITE')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
      return;
    }
    
    _initIap();
    _loadConfigAndProducts();
    // Refresh user data in background to ensure latest premium status
    UserService.instance.getCurrentUser().catchError((_) => <String, dynamic>{});
  }

  void _initIap() {
    IapService.instance.initialize();
    // The actual purchase on this screen goes through RevenueCatService
    // (see _handlePurchase() below), not IapService, so its callbacks -
    // not IapService's - are the ones that actually fire on success/error.
    RevenueCatService.instance.onPurchaseSuccess = () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.payActivated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    };
    RevenueCatService.instance.onPurchaseError = (error) {
      _showErrorSnackBar(ErrorHelper.getFriendlyMessage(error));
    };
  }

  @override
  void dispose() {
    RevenueCatService.instance.onPurchaseSuccess = null;
    RevenueCatService.instance.onPurchaseError = null;
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

      final offerings = await RevenueCatService.instance.getOfferings();

      final yearlyProductId =
          offerings?.current?.annual?.storeProduct.identifier ?? 'yearly_sub';
      final trialEligible =
          await RevenueCatService.instance.isEligibleForTrial(yearlyProductId);

      if (mounted) {
        setState(() {
          config = data;
          _offerings = offerings;
          _yearlyTrialEligible = trialEligible;
          if (offerings != null && offerings.current != null) {
            // Prefer annual package, fallback to first available
            _selectedPackage = offerings.current?.annual ?? offerings.current?.availablePackages.firstOrNull;
          }
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
        'title': context.l10n.paySpecialComeback,
        'ctaText': context.l10n.payUnlockPremium,
      };
    }
    // Prices are never hardcoded here: they come from the store (see
    // _monthlyLabel / _yearlyLabels).
    return {
      'title': context.l10n.payUnlockToKeep,
      'ctaText': context.l10n.payUnlockPremium,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: context.colors.pageBackground,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(height: 30, width: 200),
                SizedBox(height: 28.h),
                const SkeletonLoader(height: 100, width: double.infinity),
                SizedBox(height: 16.h),
                const SkeletonLoader(height: 100, width: double.infinity),
                SizedBox(height: 16.h),
                const SkeletonLoader(height: 100, width: double.infinity),
                const Spacer(),
                const SkeletonLoader(height: 50, width: double.infinity),
              ],
            ),
          ),
        ),
      );
    }

    final bool isOffer = widget.flowType == PaywallFlowType.offer;
    final primaryColor = context.colors.accent;

    return Scaffold(
      backgroundColor: context.colors.pageBackground,
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
                            color: context.colors.textPrimary,
                            fontFamily: 'SF Pro',
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      GlassIconButton(
                        onTap: () => Navigator.pop(context, false),
                        size: 40.r,
                        child: Icon(Icons.close_rounded, color: context.colors.textMuted, size: 22.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.h),

                  if (isOffer) ...[
                    _buildTimelineItem(
                      icon: 'crown.svg',
                      title: context.l10n.paySpecialOffer,
                      description:
                          context.l10n.paySpecialOfferDesc,
                      color: primaryColor,
                      isFirst: true,
                    ),
                    _buildTimelineItem(
                      icon: 'unlock.svg',
                      title: context.l10n.payUnlimitedAccess,
                      description:
                          context.l10n.payUnlimitedAccessDesc,
                      color: primaryColor,
                    ),
                    _buildTimelineItem(
                      icon: 'star.svg',
                      title: context.l10n.payExclusiveRecipes,
                      description:
                          context.l10n.payExclusiveRecipesDesc,
                      color: primaryColor,
                      isLast: true,
                    ),
                  ] else ...[
                    _buildTimelineItem(
                      icon: 'unlock.svg',
                      title: context.l10n.payImmediateAccess,
                      description:
                          context.l10n.payImmediateAccessDesc,
                      color: const Color(0xFFF97316),
                      isFirst: true,
                    ),
                    _buildTimelineItem(
                      icon: 'star.svg',
                      title: context.l10n.payExclusiveContent,
                      description:
                          context.l10n.payExclusiveContentDesc,
                      color: const Color(0xFFEAB308),
                    ),
                    _buildTimelineItem(
                      icon: 'crown.svg',
                      title: context.l10n.payMasterChef,
                      description:
                          context.l10n.payMasterChefDesc,
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
                            title: context.l10n.planMonthly,
                            price: _monthlyLabel(),
                            isSelected: _selectedPlanId == 'monthly_sub',
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 16.w),
                      ],
                      Expanded(
                        child: _buildPlanCard(
                          id: 'yearly_sub',
                          title: context.l10n.planYearly,
                          price: isOffer ? _yearlyTotalLabel() : _yearlyPerMonthLabel(),
                          subPrice: !isOffer ? '(${_yearlyTotalLabel()})' : null,
                          isSelected: _selectedPlanId == 'yearly_sub',
                          badge: isOffer ? context.l10n.payPercentOff : (_getTrialPeriod('yearly_sub').isNotEmpty ? _getTrialPeriod('yearly_sub') : context.l10n.payBestValue),
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
                color: context.colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                                  ? context.l10n.subAlreadyPremium 
                                  : context.l10n.payImmediatePremium,
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
                      RedButton(
                        label: isUserPremium ? context.l10n.subActive : (config!['ctaText'] ?? context.l10n.paySubscribeNow),
                        loadingLabel: context.l10n.commonProcessing,
                        isLoading: _isPurchasing,
                        isDisabled: isUserPremium,
                        onTap: _handlePurchase,
                        height: 50.h,
                        fontSize: 15.sp,
                      ),
                      if (!isOffer) ...[
                        SizedBox(height: 12.h),
                        Text(
                          _getBottomPriceLine(),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.colors.textMuted,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _handleRestore,
                            child: Text(
                              context.l10n.subRestorePurchases,
                              style: TextStyle(fontSize: 12.sp, color: context.colors.textMuted, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                          Text('  •  ', style: TextStyle(fontSize: 12.sp, color: context.colors.textMuted)),
                          GestureDetector(
                            onTap: () => LegalContentModal.show(context, title: context.l10n.commonTermsOfUse, content: dummyTerms),
                            child: Text(
                              context.l10n.commonTermsOfUse,
                              style: TextStyle(fontSize: 12.sp, color: context.colors.textMuted, decoration: TextDecoration.underline),
                            ),
                          ),
                          Text('  •  ', style: TextStyle(fontSize: 12.sp, color: context.colors.textMuted)),
                          GestureDetector(
                            onTap: () => LegalContentModal.show(context, title: context.l10n.commonPrivacyPolicy, content: dummyPrivacy),
                            child: Text(
                              context.l10n.commonPrivacyPolicy,
                              style: TextStyle(fontSize: 12.sp, color: context.colors.textMuted, decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
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

  // ── Store prices (App Store / Play Store via RevenueCat), localized ──
  StoreProduct? _product(String id) {
    final current = _offerings?.current;
    if (current == null) return null;
    for (final package in current.availablePackages) {
      if (package.storeProduct.identifier.split(':').first == id) return package.storeProduct;
    }
    if (id == 'yearly_sub') return current.annual?.storeProduct;
    if (id == 'monthly_sub') return current.monthly?.storeProduct;
    return null;
  }

  String _monthlyLabel() {
    final p = _product('monthly_sub');
    return p != null ? context.l10n.pricePerMonthLong(p.priceString) : '—';
  }

  String _yearlyTotalLabel() {
    final p = _product('yearly_sub');
    return p != null ? context.l10n.pricePerYearLong(p.priceString) : '—';
  }

  String _yearlyPerMonthLabel() {
    final p = _product('yearly_sub');
    if (p == null) return '—';
    return p.pricePerMonthString != null ? context.l10n.pricePerMonthShort(p.pricePerMonthString!) : context.l10n.pricePerYearLong(p.priceString);
  }

  String _getTrialPeriod(String id) {
    // Never claim a free trial for an account that isn't actually eligible
    // for it - Apple/Google grant the intro offer once per account, not
    // once per product, so a returning subscriber can hit this.
    if (!_yearlyTrialEligible) return '';
    if (_offerings == null || _offerings!.current == null) return '';
    try {
      final current = _offerings!.current!;

      // Try to find the package by product identifier
      for (var package in current.availablePackages) {
        if (package.storeProduct.identifier == id) {
          final introPrice = package.storeProduct.introductoryPrice;
          if (introPrice != null && introPrice.period.isNotEmpty) {
            final periodValue = int.tryParse(introPrice.period);
            if (periodValue != null && periodValue > 0) {
              return context.l10n.payDaysFree(introPrice.period);
            }
          }
        }
      }

      // Fallback to annual/monthly if direct match fails
      if (id == 'yearly_sub' && current.annual != null) {
        final introPrice = current.annual!.storeProduct.introductoryPrice;
        if (introPrice != null && introPrice.period.isNotEmpty) {
          final periodValue = int.tryParse(introPrice.period);
          if (periodValue != null && periodValue > 0) {
            return context.l10n.payDaysFree(introPrice.period);
          }
        }
      }
    } catch (_) {}
    return '';
  }

  /// Text shown right above "Restore Purchases" - must never promise a free
  /// trial the account isn't actually eligible for (see _yearlyTrialEligible).
  String _getBottomPriceLine() {
    if (_selectedPlanId == 'yearly_sub') {
      if (_yearlyTrialEligible) return context.l10n.payNoPaymentToday;
      final p = _product('yearly_sub');
      return p != null ? context.l10n.pricePerYearSentence(p.priceString) : context.l10n.priceBilledYearly;
    }
    final p = _product('monthly_sub');
    return p != null ? context.l10n.pricePerMonthSentence(p.priceString) : context.l10n.priceBilledMonthlyLower;
  }

  String _getProductPeriod(String id) {
    if (_offerings == null || _offerings!.current == null) return '';
    try {
      final current = _offerings!.current!;
      
      // Try to find the package by product identifier
      for (var package in current.availablePackages) {
        if (package.storeProduct.identifier == id) {
          return package.packageType.toString().split('.').last.toUpperCase();
        }
      }
      
      // Fallback to annual/monthly if direct match fails
      if (id == 'yearly_sub' && current.annual != null) {
        return current.annual!.packageType.toString().split('.').last.toUpperCase();
      }
      if (id == 'monthly_sub' && current.monthly != null) {
        return current.monthly!.packageType.toString().split('.').last.toUpperCase();
      }
    } catch (_) {}
    return '';
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
                  placeholderBuilder: (context) => const SizedBox.shrink(),
                  width: double.infinity,
                  height: double.infinity,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 5.w, color: color.withValues(alpha: 0.2)),
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
                    color: context.colors.textPrimary,
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.colors.textMuted,
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
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? color : context.colors.divider,
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
                            ? context.colors.textPrimary
                            : context.colors.textMuted,
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
                          color: isSelected ? color : context.colors.divider,
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
                    color: context.colors.textPrimary,
                    fontFamily: 'SF Pro',
                  ),
                ),
                if (subPrice != null)
                  Text(
                    subPrice,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: context.colors.textMuted,
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

    try {
      setState(() => _isPurchasing = true);
      Package? packageToBuy = _selectedPackage;
      
      if (packageToBuy == null && _offerings?.current != null) {
        final current = _offerings!.current!;
        
        // Find package by product identifier
        for (var package in current.availablePackages) {
          if (package.storeProduct.identifier == _selectedPlanId) {
            packageToBuy = package;
            break;
          }
        }
        
        // Fallback to annual/monthly if direct match fails
        if (packageToBuy == null) {
          if (_selectedPlanId == 'yearly_sub') {
            packageToBuy = current.annual ?? current.availablePackages.firstOrNull;
          } else {
            packageToBuy = current.monthly ?? current.availablePackages.lastOrNull;
          }
        }
      }

      if (packageToBuy != null) {
        await RevenueCatService.instance.buyPackage(packageToBuy);
      } else {
        _showErrorSnackBar(context.l10n.paySubscriptionsUnavailable);
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(context.l10n.payPurchaseFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    try {
      await RevenueCatService.instance.restorePurchases();
    } catch (e) {
      if (mounted) _showErrorSnackBar(context.l10n.payRestoreFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }
}
