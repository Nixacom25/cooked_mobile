import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'skeleton_loader.dart';

class GrocerySkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const GrocerySkeleton({
    super.key,
    this.itemCount = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(
        height: 0,
        thickness: 1,
        color: Color(0xFFF2F2F2),
      ),
      itemBuilder: (_, __) => const GrocerySkeletonItem(),
    );
  }
}

class GrocerySkeletonItem extends StatelessWidget {
  const GrocerySkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          const SkeletonLoader(width: 20, height: 20, borderRadius: 10),
          SizedBox(width: 14.w),
          const SkeletonLoader(width: 24, height: 24, borderRadius: 4),
          SizedBox(width: 5.w),
          Expanded(
            child: const SkeletonLoader(width: 150, height: 16),
          ),
          const SkeletonLoader(width: 40, height: 14),
        ],
      ),
    );
  }
}
