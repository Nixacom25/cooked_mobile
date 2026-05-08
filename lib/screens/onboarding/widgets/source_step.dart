import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/string_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiscoverySource {
  final String label;
  final String iconAsset;
  final String value;

  DiscoverySource(this.label, this.iconAsset, this.value);
}

class SourceStep extends StatefulWidget {
  final String userName;
  final String? initialSource;
  final String? initialOtherSource;
  final Function(String source, String? otherSource) onChanged;

  const SourceStep({
    super.key,
    required this.userName,
    this.initialSource,
    this.initialOtherSource,
    required this.onChanged,
  });

  @override
  State<SourceStep> createState() => _SourceStepState();
}

class _SourceStepState extends State<SourceStep> {
  String? _selectedSource;
  late TextEditingController _otherController;

  final List<DiscoverySource> _sources = [
    DiscoverySource('Instagram', 'instagram.svg', 'Instagram'),
    DiscoverySource('Facebook', 'facebook.svg', 'Facebook'),
    DiscoverySource('Tiktok', 'tiktok.svg', 'Tiktok'),
    DiscoverySource('Google', 'google.svg', 'Google'),
    DiscoverySource('Friend Referral', 'friend.svg', 'Friend Referral'),
    DiscoverySource('Others', 'others.svg', 'Others'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.initialSource;
    _otherController = TextEditingController(text: widget.initialOtherSource);
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _handleSourceTap(String source) {
    setState(() {
      _selectedSource = source;
    });
    widget.onChanged(
      _selectedSource!,
      _selectedSource == 'Others' ? _otherController.text.toTitleCase() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.userName}!\nHow did you find us?',
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
            "This helps us improve our reach",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.6,
            children: _sources.map((source) {
              final isSelected = _selectedSource == source.value;

              return GestureDetector(
                onTap: () => _handleSourceTap(source.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC83A2D)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2.w : 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (source.iconAsset.isNotEmpty) ...[
                        SvgPicture.asset(
                          'assets/icones/${source.iconAsset}',
                          height: 26.h,
                          width: 26.w,
                          placeholderBuilder: (BuildContext context) =>
                              Container(
                                padding: EdgeInsets.all(8.r),
                                child: const CircularProgressIndicator(),
                              ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      Text(
                        source.label,
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFFC83A2D)
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedSource == 'Others') ...[
            SizedBox(height: 24.h),
            TextField(
              controller: _otherController,
              textCapitalization: TextCapitalization.words,
              onChanged: (val) => widget.onChanged(_selectedSource!, val.toTitleCase()),
              decoration: InputDecoration(
                hintText: 'Please specify...',
                hintStyle: TextStyle(
                  color: const Color(0xFFBDC3C7),
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFC83A2D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFC83A2D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: const Color(0xFFC83A2D),
                    width: 1.5.w,
                  ),
                ),
              ),
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 16.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 32.h),
        ],
      ),
    );
  }
}
