import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final cleanVal = val.trim();
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
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll avoid these in your recipes",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 30.h),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dislikeController,
                  decoration: InputDecoration(
                    hintText: 'Type an ingredient...',
                    hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
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
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                height: 48.h,
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
                      fontSize: 14.sp,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedDislikes.isNotEmpty) ...[
            SizedBox(height: 20.h),
            Text(
              'Your dislikes:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0D1B3E),
                fontFamily: 'SF Pro',
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 8.h,
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
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () => _removeDislike(d),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          SizedBox(height: 40.h),

          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: OutlinedButton(
              onPressed: () {
                setState(() => _selectedDislikes.clear());
                widget.onChanged(_selectedDislikes);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.r),
                ),
                backgroundColor: const Color(0xFFE5E7EB),
                side: BorderSide.none,
              ),
              child: Text(
                'Skip — I eat most things',
                style: TextStyle(
                  color: const Color(0xFF0D1B3E),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
