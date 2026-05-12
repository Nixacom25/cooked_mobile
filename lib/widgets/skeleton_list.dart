import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'skeleton_loader.dart';

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double height;
  final double? width;
  final Axis scrollDirection;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double borderRadius;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    required this.height,
    this.width,
    this.scrollDirection = Axis.vertical,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      scrollDirection: scrollDirection,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => scrollDirection == Axis.vertical
          ? SizedBox(height: spacing.h)
          : SizedBox(width: spacing.w),
      itemBuilder: (_, __) => SkeletonLoader(
        width: width ?? (scrollDirection == Axis.vertical ? 1.sw : 120.w),
        height: height.h,
        borderRadius: borderRadius,
      ),
    );
  }
}
