import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../services/iap_service.dart';

extension DateTimeExtension on DateTime {
  DateTime plusDays(int days) => add(Duration(days: days));
}

class TrialStep extends StatefulWidget {
  final Function(String plan) onPlanSelected;
  final VoidCallback onSkip;
  final bool showTrialBadge;

  const TrialStep({
    super.key,
    required this.onPlanSelected,
    required this.onSkip,
    this.showTrialBadge = true,
  });

  @override
  State<TrialStep> createState() => _TrialStepState();
}

class _TrialStepState extends State<TrialStep> {
  String _selectedPlan = 'yearly';
  String _monthlyPrice = '\$9.99';
  String _yearlyPrice = '\$29.99';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  void _loadPrices() async {
    final products = await IapService.instance.getProducts({
      'monthly_sub',
      'yearly_sub',
    });
    if (mounted) {
      setState(() {
        for (var p in products) {
          if (p.id == 'monthly_sub') _monthlyPrice = p.price;
          if (p.id == 'yearly_sub') _yearlyPrice = p.price;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Start your 3-day FREE\ntrial to continue.',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 28.h),

          // Timeline
          _buildTimelineItem(
            icon: 'unlock.svg',
            title: 'Today',
            description:
                "Unlock all the app's features like AI calorie scanning and more.",
            isFirst: true,
          ),
          _buildTimelineItem(
            icon: 'bell-part.svg',
            title: 'In 2 Days - Reminder',
            description:
                "We'll send you a reminder that your trial is ending soon.",
          ),
          _buildTimelineItem(
            icon: 'crown.svg',
            title: 'In 3 Days - Billing Starts',
            description:
                "You'll be charged on ${DateFormat('MMM d, yyyy').format(DateTime.now().plusDays(3))} unless you cancel anytime before.",
            isLast: true,
          ),

          SizedBox(height: 32.h),

          // Subscription Options
          Row(
            children: [
              Expanded(
                child: _buildPlanCard(
                  id: 'monthly',
                  title: 'Monthly',
                  price: _monthlyPrice,
                  isSelected: _selectedPlan == 'monthly',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildPlanCard(
                  id: 'yearly',
                  title: 'Yearly',
                  price: _yearlyPrice,
                  isSelected: _selectedPlan == 'yearly',
                  badge: widget.showTrialBadge ? '3 days free' : null,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // No Payment Due
          GestureDetector(
            onTap: widget.onSkip,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: const Color(0xFF0D1B3E), size: 16.sp),
                SizedBox(width: 8.w),
                Text(
                  'No Payment Due Now',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D1B3E),
                    fontFamily: 'SF Pro',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 120.h), // Space for bottom button
        ],
      ),
    );
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
                    width: 5.w,
                    color: const Color(0xFFC83A2D).withOpacity(0.3),
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
      onTap: () {
        setState(() => _selectedPlan = id);
        widget.onPlanSelected(id);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC83A2D)
                    : const Color(0xFFE5E7EB),
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
                      ),
                    ),
                    Container(
                      width: 20.sp,
                      height: 20.sp,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFC83A2D)
                              : const Color(0xFFE5E7EB),
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
              top: -12.h,
              right: 40.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC83A2D),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 12.sp,
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
}
