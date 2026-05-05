import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/subscription_service.dart';
import '../../models/subscription_payment.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../services/iap_service.dart';
import '../../core/widgets/ios_toast.dart';
import '../onboarding/widgets/trial_step.dart';
import '../../core/utils/error_helper.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _subscription;
  List<SubscriptionPayment> _history = [];
  String _selectedPlanId = 'yearly';

  List<ProductDetails> _products = [];
  String _monthlyPrice = '\$9.99';
  String _yearlyPrice = '\$29.99';

  @override
  void initState() {
    super.initState();
    _loadSubscription();
    _initIap();
  }

  void _initIap() async {
    IapService.instance.initialize();
    IapService.instance.onPurchaseSuccess = () async {
      Navigator.of(context, rootNavigator: true).pop(); // if bottom sheet open
      await _loadSubscription();
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Subscription activated!',
        type: ToastType.success,
      );
    };
    IapService.instance.onPurchaseError = (error) {
      if (!mounted) return;
      IosToast.show(context, message: ErrorHelper.getFriendlyMessage(error), type: ToastType.error);
    };

    final products = await IapService.instance.getProducts({
      'monthly_sub',
      'yearly_sub',
    });
    if (mounted) {
      setState(() {
        _products = products;
        for (var p in products) {
          if (p.id == 'monthly_sub') _monthlyPrice = p.price;
          if (p.id == 'yearly_sub') _yearlyPrice = p.price;
        }
      });
    }
  }

  @override
  void dispose() {
    IapService.instance.dispose();
    super.dispose();
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

  void _showRenewalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Stack(
                children: [
                  TrialStep(
                    showTrialBadge: false,
                    onPlanSelected: (plan) {
                      setModalState(() => _selectedPlanId = plan);
                    },
                    onSkip: () {
                      Navigator.pop(context);
                    },
                  ),
                  Positioned(
                    bottom: 24.h,
                    left: 24.w,
                    right: 24.w,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () => _handlePayment(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC83A2D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          _selectedPlanId == 'yearly'
                              ? 'Renew Yearly - $_yearlyPrice'
                              : 'Renew Monthly - $_monthlyPrice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    if (_products.isEmpty) {
      IosToast.show(
        context,
        message: 'Store not available right now. Please try again later.',
        type: ToastType.error,
      );
      return;
    }

    final targetId = _selectedPlanId == 'yearly'
        ? 'yearly_sub'
        : 'monthly_sub';
    ProductDetails product = _products.first;
    for (var p in _products) {
      if (p.id == targetId) {
        product = p;
        break;
      }
    }

    try {
      print('Initiating purchase for: ${product.id}');
      final success = await IapService.instance.buyProduct(product);
      print('Purchase initiation result: $success');
      if (!success) {
         IosToast.show(context, message: 'Could not contact Google Play Store', type: ToastType.error);
      }
    } catch (e) {
      if (!mounted) return;
      IosToast.show(
        context,
        message: 'Could not initiate purchase',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Subscription',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC83A2D)),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  SizedBox(height: 32.h),
                  Text(
                    'Subscription Details',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
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
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _showRenewalSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC83A2D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                      child: Text(
                        'Renew or Upgrade',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),
                  Text(
                    'Payment History',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.h),
                  if (_history.isEmpty)
                    Text(
                      'No payment history found',
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                  ..._history.map(_buildHistoryCard),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    final status = _subscription?['status'] ?? 'NONE';
    final isTrial = status == 'TRIAL';
    final isExpired = status == 'EXPIRED';

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0D1B36),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isExpired ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTimeRemaining(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B5563),
                  fontSize: 14.sp,
                ),
              ),
              Text(
                '${(_getProgress() * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4B5563),
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
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFFC83A2D),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: const Color(0xFF6B7280), fontSize: 16.sp),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
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
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF222222)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: const Color(0xFFC83A2D),
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
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _formatDate(payment.createdAt.toIso8601String()),
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isSuccess ? 'RENEWAL' : 'FAILED',
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue',
                style: TextStyle(color: Colors.white38, fontSize: 13.sp),
              ),
              Text(
                '\$${payment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
