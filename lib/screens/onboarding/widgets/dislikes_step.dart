import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';

class DislikesStep extends StatefulWidget {
  final Set<String> initialSelected;
  final Function(Set<String> selected) onChanged;

  const DislikesStep({
    super.key,
    required this.initialSelected,
    required this.onChanged,
  });

  @override
  State<DislikesStep> createState() => _DislikesStepState();
}

class _DislikesStepState extends State<DislikesStep> {
  late Set<String> _selectedDislikes;
  final TextEditingController _dislikeController = TextEditingController();

  final List<String> _suggestions = [
    'Onions',
    'Garlic',
    'Broccoli',
    'Spinach',
    'Cheese',
    'Eggs',
    'Seafood',
    'Chicken',
    'Tomatos',
    'Bell Peppers',
    'Anchovies',
    'Tofu',
    'Bitter melon',
    'Brussels sprouts',
    'Pickles',
    'Oysters',
    'Cilantro',
    'Mushrooms',
    'Olives',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDislikes = Set.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _dislikeController.dispose();
    super.dispose();
  }

  void _addDislike(String val) {
    final cleanVal = val.trim().toTitleCase();
    if (cleanVal.isNotEmpty) {
      setState(() {
        _selectedDislikes.add(cleanVal);
        _dislikeController.clear();
      });
      widget.onChanged(_selectedDislikes);
    }
  }

  void _removeDislike(String val) {
    setState(() {
      _selectedDislikes.remove(val);
    });
    widget.onChanged(_selectedDislikes);
  }

  void _toggleSuggestion(String val) {
    setState(() {
      if (_selectedDislikes.contains(val)) {
        _selectedDislikes.remove(val);
      } else {
        _selectedDislikes.add(val);
      }
    });
    widget.onChanged(_selectedDislikes);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foods you dislike',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "We'll avoid these in your recipes",
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dislikeController,
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type an ingredient...',
                    hintStyle: TextStyle(
                      color: const Color(0xFFBDC3C7),
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: Color(0xFFC83A2D),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: _addDislike,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () => _addDislike(_dislikeController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC83A2D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro',
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Wrap(
            spacing: 6.w,
            runSpacing: 8.h,
            children: _suggestions.map((s) {
              final isSelected = _selectedDislikes.contains(s);
              return GestureDetector(
                onTap: () => _toggleSuggestion(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC83A2D)
                        : const Color(0xFFEAEAEA),
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC83A2D)
                          : const Color(0xFFDFDFDF),
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF4B5563),
                    fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedDislikes.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              'Your dislikes:',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D1B3E),
                fontFamily: 'SF Pro',
              ),
            ),
            SizedBox(height: 12.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 2.5,
              children: _selectedDislikes.map((d) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC83A2D),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        d,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () => _removeDislike(d),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
