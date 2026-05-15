import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StandardPlusButton extends StatelessWidget {
  final bool isValidated;
  final VoidCallback? onTap;
  final Color? inactiveColor;

  const StandardPlusButton({
    super.key,
    required this.isValidated,
    this.onTap,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32.r,
        height: 32.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
            ),
            Icon(
              isValidated ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: isValidated 
                  ? Colors.green 
                  : (inactiveColor ?? const Color(0xFFAAAAAA)),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
