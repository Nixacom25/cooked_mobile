import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const LoadingText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<LoadingText> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    // Add spaces to prevent text jumping
    String padding = ' ' * (3 - _dotCount);
    
    return Text(
      '${widget.text}$dots$padding',
      style: widget.style ?? TextStyle(
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
        color: Colors.white,
      ),
    );
  }
}
