import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsStep extends StatefulWidget {
  final List<String> initialSelected;
  final Function(List<String> selected) onChanged;

  const NotificationsStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<NotificationsStep> createState() => _NotificationsStepState();
}

class _NotificationsStepState extends State<NotificationsStep> {
  final List<Map<String, String>> _options = [
    {'title': 'Daily recipe inspiration', 'subtitle': 'Morning suggestion'},
    {'title': 'Grocery Reminder', 'subtitle': 'Remember what to buy before ingredients run out.'},
  ];

  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay inspired with new recipes',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: context.colors.textPrimary,
              height: 1.2,
              letterSpacing: -0.5)),
          SizedBox(height: 8.h),
          Text(
            'Choose what you\'d like to hear about',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: context.colors.textMuted)),
          SizedBox(height: 32.h),
          ..._options.map((opt) => _buildToggleItem(opt)),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (_selected.isEmpty) {
                    _selected = _options.map((o) => o['title']!).toSet();
                  } else {
                    _selected.clear();
                  }
                });
                HapticFeedback.selectionClick();
                widget.onChanged(_selected.toList());
              },
              style: TextButton.styleFrom(
                backgroundColor: context.colors.surface,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                  side: BorderSide(
                    color: context.colors.accent,
                    width: 1.5.w))),
              child: Text(
                _selected.isEmpty ? 'Turn on all' : 'Turn off all',
                style: GoogleFonts.poppins(fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.accent)))),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFD97706).withValues(alpha: 0.16)
                  : const Color(0xFFFFF7ED), // Light yellowish-beige
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFFD97706).withValues(alpha: 0.4)
                      : const Color(0xFFFDE68A),
                  width: 0.5)),
            child: Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'You can adjust these anytime in your settings',
                    style: GoogleFonts.poppins(fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary))),
              ])),
          SizedBox(height: 10.h),
        ]));
  }

  Widget _buildToggleItem(Map<String, String> opt) {
    final bool isSelected = _selected.contains(opt['title']);
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selected.remove(opt['title']);
            } else {
              _selected.add(opt['title']!);
            }
          });
          HapticFeedback.selectionClick();
          widget.onChanged(_selected.toList());
        },
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.colors.divider,
              width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8.r,
                offset: Offset(0, 4.h)),
            ]),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt['title']!,
                      style: GoogleFonts.poppins(fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary)),
                    SizedBox(height: 4.h),
                    Text(
                      opt['subtitle']!,
                      style: GoogleFonts.poppins(fontSize: 13.sp,
                        color: context.colors.textMuted)),
                  ])),
              SizedBox(width: 12.w),
              Container(
                width: 24.sp,
                height: 24.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? context.colors.accent : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? context.colors.accent : context.colors.border,
                    width: 1.5.w)),
                child: isSelected
                    ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                    : null),
            ]))));
  }
}
