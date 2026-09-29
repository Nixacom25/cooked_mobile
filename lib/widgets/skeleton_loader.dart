import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/motion/skeleton.dart';

/// Legacy skeleton API, now backed by the shared motion [SkeletonBox]
/// (1.4 s low-contrast shimmer, warm gray in light mode, dark gray in dark).
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius.r),
    );
  }
}
