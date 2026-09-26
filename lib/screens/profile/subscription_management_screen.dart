import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../services/subscription_service.dart';
import '../../services/revenuecat_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/skeleton_list.dart';
import '../../models/subscription_payment.dart';
import '../../core/widgets/ios_toast.dart';
import '../../core/utils/error_helper.dart';
import '../../services/auth_service.dart';
import '../../services/paywall_service.dart';
import '../premium/paywall_screen.dart';
import '../../core/api_config.dart';
import '../../services/user_service.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  bool _isLoading = true;
  bool _isRestoring = false;
  Map<String, dynamic>? _subscription;
  List<SubscriptionPayment> _history = [];

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final sub = await SubscriptionService.instance.getMySubscription();
      final history = await SubscriptionService.instance.getPaymentHistory();
      if (!mounted) return;
      setState(() {
        _subscription = sub;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      IosToast.show(
        context,
        message: 'Failed to load subscription status',
        type: ToastType.error,
      );
    }
  }

  String _getTimeRemaining() {
    if (_subscription == null) return '';
    final endDateStr = _subscription!['endDate'];
    if (endDateStr == null) return 'No active subscription';
    final endDate = DateTime.parse(endDateStr);
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) return 'Expired';

    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return 'Expiring soon';
    }
  }

  double _getProgress() {
    if (_subscription == null) return 0;
    final startDateStr = _subscription!['startDate'];
    final endDateStr = _subscription!['endDate'];
    if (startDateStr == null || endDateStr == null) return 0;

    final startDate = DateTime.parse(startDateStr);
    final endDate = DateTime.parse(endDateStr);
    final now = DateTime.now();

    final total = endDate.difference(startDate).inSeconds;
    final elapsed = now.difference(startDate).inSeconds;

    if (total <= 0) return 0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  void _showRenewalScreen() async {
    final token = await AuthService.instance.getToken();
    if (token == null) return;

    final paywallService = PaywallService(
      baseUrl: ApiConfig.baseUrl,
      authToken: token,
    );

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          paywallService: paywallService,
          flowType: PaywallFlowType.standard,
        ),
      ),
    );

    if (result == true) {
      _loadSubscription();
    }
  }

  Future<void> _handleRestorePurchases() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);
    try {
      final restored = await RevenueCatService.instance.restorePurchases();
      if (!mounted) return;
      IosToast.show(
        context,
        message: restored
            ? 'Purchases restored!'
            : 'No active subscriptions found to restore.',
        type: restored ? ToastType.success : ToastType.warning,
      );
      if (restored) _loadSubscription();
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: ErrorHelper.getFriendlyMessage(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Red background fond_page.png ──
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GlassIconButton(
                          onTap: () => Navigator.pop(context),
                          size: 42.r,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20.sp,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Subscription',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  // ── Content ──
                  Expanded(
                    child: _isLoading
                        ? SingleChildScrollView(
                            padding: EdgeInsets.all(24.r),
                            child: Column(
                              children: [
                                const SkeletonLoader(
                                    height: 150, width: double.infinity, borderRadius: 20),
                                SizedBox(height: 32.h),
                                const SkeletonList(height: 40, itemCount: 4),
                                SizedBox(height: 32.h),
                                const SkeletonLoader(
                                    height: 56, width: double.infinity, borderRadius: 30),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatusCard(),
                                SizedBox(height: 28.h),
                                Text(
                                  'Subscription Details',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                _buildDetailRow(
                                  'Plan',
                                  _subscription?['isYearly'] == true ? 'Yearly' : 'Monthly',
                                ),
                                _buildDetailRow(
                                  'Start Date',
                                  _formatDate(_subscription?['startDate']),
                                ),
                                _buildDetailRow(
                                  'End Date',
                                  _formatDate(_subscription?['endDate']),
                                ),
                                _buildDetailRow(
                                  'Status',
                                  _subscription?['status'] ?? 'UNKNOWN',
                                ),
                                SizedBox(height: 28.h),

                                ValueListenableBuilder<Map<String, dynamic>?>(
                                  valueListenable: UserService.instance.currentUserNotifier,
                                  builder: (context, user, _) {
                                    final bool isPremium =
                                        _subscription?['status'] == 'ACTIVE' ||
                                            _subscription?['status'] == 'TRIAL' ||
                                            _subscription?['status'] == 'INFINITE' ||
                                            user?['role'] == 'CREATOR' ||
                                            user?['role'] == 'ADMIN' ||
                                            user?['role'] == 'EDITOR';

                                    return Column(
                                      children: [
                                        if (isPremium) ...[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(2.r),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF10B981),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 14.sp,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "You are already a Premium member!",
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF10B981),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16.h),
                                        ],
                                        GestureDetector(
                                          onTap: isPremium ? null : _showRenewalScreen,
                                          child: Container(
                                            width: double.infinity,
                                            height: 54.h,
                                            decoration: BoxDecoration(
                                              color: isPremium
                                                  ? context.colors.border
                                                  : context.colors.accent,
                                              borderRadius: BorderRadius.circular(27.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                isPremium ? 'Active Subscription' : 'Renew or Upgrade',
                                                style: TextStyle(
                                                  fontFamily: 'Rubik',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: isPremium
                                                      ? context.colors.textMuted
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        GestureDetector(
                                          onTap: _isRestoring ? null : _handleRestorePurchases,
                                          child: Center(
                                            child: _isRestoring
                                                ? SizedBox(
                                                    width: 18.r,
                                                    height: 18.r,
                                                    child: const AppLoadingIndicator(),
                                                  )
                                                : Text(
                                                    'Restore Purchases',
                                                    style: TextStyle(
                                                      fontFamily: 'Rubik',
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14.sp,
                                                      color: context.colors.accent,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                SizedBox(height: 36.h),
                                Text(
                                  'Payment History',
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                if (_history.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    child: Text(
                                      'No payment history found',
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        color: context.colors.textSecondary,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ..._history.map(_buildHistoryCard),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = _subscription?['status'] ?? 'NONE';
    final isTrial = status == 'TRIAL';
    final isExpired = status == 'EXPIRED';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: context.colors.pageBackground,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTrial ? 'Free Trial' : 'Premium Plan',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? (isDark ? context.colors.destructive.withValues(alpha: 0.18) : const Color(0xFFFEE2E2))
                      : (isDark ? const Color(0xFF059669).withValues(alpha: 0.18) : const Color(0xFFD1FAE5)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: isExpired ? context.colors.destructive : const Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTimeRemaining(),
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                '${(_getProgress() * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: _getProgress(),
              backgroundColor: context.colors.border,
              color: context.colors.accent,
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Rubik',
              color: context.colors.textSecondary,
              fontSize: 15.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildHistoryCard(SubscriptionPayment payment) {
    final isSuccess = payment.status == 'SUCCESS';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.colors.pageBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: context.colors.accent,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.planType,
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                      Text(
                        _formatDate(payment.createdAt.toIso8601String()),
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          color: context.colors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? (isDark ? const Color(0xFF059669).withValues(alpha: 0.18) : const Color(0xFFD1FAE5))
                      : (isDark ? context.colors.destructive.withValues(alpha: 0.18) : const Color(0xFFFEE2E2)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isSuccess ? 'RENEWAL' : 'FAILED',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    color: isSuccess ? const Color(0xFF059669) : context.colors.destructive,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: context.colors.border, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: context.colors.textSecondary,
                  fontSize: 13.sp,
                ),
              ),
              Text(
                '\$${payment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
