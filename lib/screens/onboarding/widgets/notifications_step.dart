import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

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
    {'title': 'Meal plan reminder', 'subtitle': 'Your weekly plan is ready'},
    {'title': 'What\'s in your fridge?', 'subtitle': 'Dinner time prompt'},
    {'title': 'New recipes for you', 'subtitle': 'Matching your taste'},
    {'title': 'Special events & seasonal', 'subtitle': 'Holidays, Ramadan, etc.'},
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
            'Stay inspired with notifications',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose what you\'d like to hear about',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),
          ..._options.map((opt) => _buildToggleItem(opt)),
          SizedBox(height: 16.h),
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
                backgroundColor: const Color(0xFFD8D8D8),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                  side: BorderSide(
                    color: _selected.isEmpty
                        ? const Color(0xFFD8D8D8)
                        : const Color(0xFFC83A2D),
                  ),
                ),
              ),
              child: Text(
                _selected.isEmpty ? 'Turn on all' : 'Turn off all',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _selected.isEmpty
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFC83A2D),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EF),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Text('💡', style: TextStyle(fontSize: 12.sp)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'You can adjust these anytime in your settings',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12.sp,
                      color: const Color(0xFF854D0E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
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
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC83A2D)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5.w : 1.w,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opt['title']!,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      opt['subtitle']!,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 12.sp,
                        color: const Color(0xFF7B8190),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20.sp,
                height: 20.sp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFC83A2D)
                      : const Color(0xFFE5E7EB),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
