import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/subscription_service.dart';
import '../../models/subscription_payment.dart';
import '../../core/widgets/ios_toast.dart';
import '../../services/auth_service.dart';
import '../../services/paywall_service.dart';
import '../premium/paywall_screen.dart';
import '../../core/api_config.dart';
import '../../services/user_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }



  @override
  void dispose() {
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
                  
                  ValueListenableBuilder<Map<String, dynamic>?>(
                    valueListenable: UserService.instance.currentUserNotifier,
                    builder: (context, user, _) {
                      final bool isPremium = _subscription?['status'] == 'ACTIVE' || _subscription?['status'] == 'TRIAL';
                      
                      return Column(
                        children: [
                          if (isPremium) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check, color: Colors.white, size: 14.sp),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  "You are already a Premium member!",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              onPressed: isPremium ? null : _showRenewalScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC83A2D),
                                disabledBackgroundColor: const Color(0xFFE5E7EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              child: Text(
                                isPremium ? 'Active Subscription' : 'Renew or Upgrade',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                      color: const Color(0xFFC83A2D).withOpacity(0.05),
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
                          color: const Color(0xFF0D1B36),
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                        ),
                      ),
                      Text(
                        _formatDate(payment.createdAt.toIso8601String()),
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
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
          Divider(color: const Color(0xFFF3F4F6), height: 1),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount',
                style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13.sp),
              ),
              Text(
                '\$${payment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: const Color(0xFF0D1B36),
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
