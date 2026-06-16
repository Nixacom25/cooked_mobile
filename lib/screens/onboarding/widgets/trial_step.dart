import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../services/iap_service.dart';

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

class _TrialStepState extends State<TrialStep> with SingleTickerProviderStateMixin {
  String _selectedPlan = 'yearly';
  String _monthlyPrice = '\$9.99 /mo';
  String _yearlyPrice = '\$2.49 /mo';

  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _card1Opacity;
  late Animation<double> _card1Scale;
  late Animation<double> _card2Opacity;
  late Animation<double> _card2Scale;

  @override
  void initState() {
    super.initState();
    _loadPrices();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );

    _card1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _card1Scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.elasticOut)),
    );

    _card2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6, curve: Curves.easeOut)),
    );
    _card2Scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.9, curve: Curves.elasticOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadPrices() async {
    final products = await IapService.instance.getProducts({
      'monthly_sub',
      'yearly_sub',
    });
    if (mounted) {
      setState(() {
        for (var p in products) {
          if (p.id == 'monthly_sub') {
            _monthlyPrice = p.price;
          }
          if (p.id == 'yearly_sub') {
            _yearlyPrice = '\$2.49 /mo';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    children: [
                      Text(
                        'Unlock your full\npersonalized\ncooking system.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0D1B3E),
                          fontFamily: 'SF Pro',
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Built around your goals, schedule,\nand taste.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF4B5563),
                          fontFamily: 'SF Pro',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Image
              FadeTransition(
                opacity: _titleOpacity, // Just reuse title opacity
                child: Center(
                  child: Image.asset(
                    'assets/images/step27.png',
                    height: 220.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 220.h,
                      width: 200.w,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text('assets/images/step27.png missing'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Subscription Options
              Row(
                children: [
                  Expanded(
                    child: FadeTransition(
                      opacity: _card1Opacity,
                      child: Transform.scale(
                        scale: _card1Scale.value,
                        child: _buildPlanCard(
                          id: 'monthly',
                          title: 'Monthly',
                          price: _monthlyPrice,
                          isSelected: _selectedPlan == 'monthly',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: FadeTransition(
                      opacity: _card2Opacity,
                      child: Transform.scale(
                        scale: _card2Scale.value,
                        child: _buildPlanCard(
                          id: 'yearly',
                          title: 'Yearly',
                          price: _yearlyPrice,
                          isSelected: _selectedPlan == 'yearly',
                          badge: widget.showTrialBadge ? '3 days free' : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Bottom Button Area
              FadeTransition(
                opacity: _card2Opacity,
                child: Column(
                  children: [
                    Text(
                      'No payment due today',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFC83A2D),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onPlanSelected(_selectedPlan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC83A2D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Try for Free',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '3 days free, then \$29.99/year. Cancel anytime.',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 12.sp,
                        color: const Color(0xFF7B8190),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
            ],
          );
        }
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
        HapticFeedback.selectionClick();
        setState(() => _selectedPlan = id);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFC83A2D)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 1.5.w : 1.w,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFFC83A2D).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF7B8190),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      SizedBox(height: 4.h),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0D1B3E),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFC83A2D) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFC83A2D) : const Color(0xFFE5E7EB),
                      width: 1.5.w,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                      : null,
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -12.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC83A2D),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
