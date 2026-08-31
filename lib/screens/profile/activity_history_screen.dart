import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../services/user_service.dart';
import '../../models/activity_log.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_header_background.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
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
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header (Back Button & Title) ──
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
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Recent Recipes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  // ── Section Title ──
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Text(
                      DateFormat('MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  // ── Activity Content ──
                  Expanded(
                    child: FutureBuilder<List<ActivityLog>>(
                      future: UserService.instance.getActivities(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.all(20.r),
                            child: const SkeletonList(height: 110, itemCount: 4),
                          );
                        }

                        final activities = snapshot.data ?? [];
                        if (activities.isEmpty) {
                          // Fallback sample cards matching mockup if no server activities
                          return ListView(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            children: const [
                              _ActivityCard(
                                title: 'Chicken Stir-Fry',
                                itemCountStr: '1 item',
                                isSuccess: true,
                                imageAsset: 'assets/images/plat1.png',
                              ),
                              SizedBox(height: 14),
                              _ActivityCard(
                                title: 'Tacos',
                                itemCountStr: '2 items',
                                isSuccess: false,
                                imageAsset: 'assets/images/plat2.png',
                              ),
                            ],
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                          itemCount: activities.length,
                          separatorBuilder: (_, __) => SizedBox(height: 14.h),
                          itemBuilder: (context, i) {
                            final log = activities[i];
                            final isSuccess = !log.title.toLowerCase().contains('failed');
                            return _ActivityCard(
                              title: log.title,
                              itemCountStr: '1 item',
                              isSuccess: isSuccess,
                              imageAsset: 'assets/images/plat${(i % 3) + 1}.png',
                            );
                          },
                        );
                      },
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
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String itemCountStr;
  final bool isSuccess;
  final String imageAsset;

  const _ActivityCard({
    required this.title,
    required this.itemCountStr,
    required this.isSuccess,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5E8),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item count badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              size: 13.sp,
                              color: const Color(0xFF64748B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              itemCountStr,
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isSuccess ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          isSuccess ? 'Success' : 'Failed',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isSuccess ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
