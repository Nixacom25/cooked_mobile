import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/user_service.dart';
import '../../models/activity_log.dart';
import '../../widgets/skeleton_list.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ACTIVITY HISTORY SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});
  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: const Color(0xFF1A1A1A), size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity History',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 22.sp,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: FutureBuilder<List<ActivityLog>>(
        future: UserService.instance.getActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonList(height: 100, itemCount: 6),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load activity history.',
                style: TextStyle(fontFamily: 'SF Pro', fontSize: 14.sp),
              ),
            );
          }

          final activities = snapshot.data ?? [];
          if (activities.isEmpty) {
            return Center(
              child: Text(
                'No activity found.',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: const Color(0xFF888888),
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            itemCount: activities.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              final log = activities[i];
              final dateStr =
                  "${log.createdAt.day.toString().padLeft(2, '0')}/${log.createdAt.month.toString().padLeft(2, '0')}/${log.createdAt.year} ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}";

              IconData icon = Icons.notifications_rounded;
              Color iconColor = const Color(0xFF00B251);
              final t = log.title.toLowerCase();
              if (t.contains('password')) {
                icon = Icons.lock_reset_rounded;
                iconColor = const Color(0xFFE84C4C);
              } else if (t.contains('login') || t.contains('account')) {
                icon = Icons.person_rounded;
              } else if (t.contains('recipe') || t.contains('cookbook')) {
                icon = Icons.restaurant_menu_rounded;
                iconColor = const Color(0xFFC83A2D);
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFEEEEEE), width: 1.w),
                ),
                padding: EdgeInsets.all(16.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: iconColor, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.title,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            log.message,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 14.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 12.sp,
                              color: const Color(0xFFCCCCCC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
