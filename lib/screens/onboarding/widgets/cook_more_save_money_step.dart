import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../widgets/red_button.dart';

class CookMoreSaveMoneyStep extends StatelessWidget {
  final VoidCallback onContinue;

  const CookMoreSaveMoneyStep({super.key, required this.onContinue});

  Widget _buildHabitRow(IconData icon, Color bgColor, Color iconColor, String text) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 15.sp),
        ),
        SizedBox(width: 12.w),
        Text(text, style: TextStyle(color: const Color(0xFF1B1C1C), fontSize: 15.sp, fontFamily: 'SF Pro')),
      ],
    );
  }

  Widget _buildSmallCard(IconData icon, Color iconColor, String title, String value) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(height: 12.h),
          Text(title, style: TextStyle(color: const Color(0xFF7B8190), fontSize: 12.sp, height: 1.3, fontFamily: 'SF Pro')),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(color: const Color(0xFF1B1C1C), fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: 'SF Pro')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cook more. Waste less. Save money.',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0D1B36),
                  fontFamily: 'SF Pro',
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Many users reduce takeout and grocery waste within weeks.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF7B8190),
                  fontFamily: 'SF Pro',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
            child: Column(
              children: [
                // Large Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estimated Monthly Savings', style: TextStyle(color: const Color(0xFF7B8190), fontSize: 14.sp, fontFamily: 'SF Pro')),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$180', style: TextStyle(color: const Color(0xFF00C40A), fontSize: 40.sp, fontWeight: FontWeight.w800, letterSpacing: -1, fontFamily: 'SF Pro', height: 1)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h, left: 4.w),
                            child: Text(' /month', style: TextStyle(color: const Color(0xFF1B1C1C), fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'SF Pro')),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Potential Yearly: \$2,160', style: TextStyle(color: const Color(0xFF7B8190), fontSize: 12.sp, fontFamily: 'SF Pro')),
                          Text('Progress 85%', style: TextStyle(color: const Color(0xFFD92D20), fontSize: 12.sp, fontWeight: FontWeight.bold, fontFamily: 'SF Pro')),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: SizedBox(
                          height: 8.h,
                          child: Row(
                            children: [
                              Expanded(flex: 85, child: Container(color: const Color(0xFF374151))),
                              Expanded(flex: 15, child: Container(color: const Color(0xFFFFF1F2))),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildHabitRow(Icons.takeout_dining_outlined, const Color(0xFFFFF7ED), const Color(0xFFF79009), 'Takeout reduced'),
                      SizedBox(height: 10.h),
                      _buildHabitRow(Icons.inventory_2_outlined, const Color(0xFFF0F9FF), const Color(0xFF0BA5EC), 'Groceries used smarter'),
                      SizedBox(height: 10.h),
                      _buildHabitRow(Icons.local_fire_department_outlined, const Color(0xFFECFDF3), const Color(0xFF12B76A), 'Recipes matched to your habits'),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Small Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallCard(Icons.home_outlined, const Color(0xFFD92D20), 'Meals cooked at\nhome', '+12'),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildSmallCard(Icons.delete_outline, const Color(0xFF0D894F), 'Ingredients used\nbefore waste', '94%'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 15.h),
          child: RedButton(
            label: 'Continue',
            onTap: onContinue,
            height: 55.h,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
