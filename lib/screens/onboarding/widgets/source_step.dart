import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiscoverySource {
  final String label;
  final String iconAsset;
  final String value;

  DiscoverySource(this.label, this.iconAsset, this.value);
}

class SourceStep extends StatefulWidget {
  final List<String> initialSources;
  final String? initialOtherSource;
  final Function(List<String> sources, String? otherSource) onChanged;

  const SourceStep({
    super.key,
    required this.initialSources,
    this.initialOtherSource,
    required this.onChanged,
  });

  @override
  State<SourceStep> createState() => _SourceStepState();
}

class _SourceStepState extends State<SourceStep> {
  late Set<String> _selectedSources;
  late TextEditingController _otherController;

  final List<DiscoverySource> _sources = [
    DiscoverySource('Tiktok', 'tiktok.svg', 'Tiktok'),
    DiscoverySource('Instagram', 'instagram.svg', 'Instagram'),
    DiscoverySource('Youtube', 'you.svg', 'Youtube'), // No youtube.svg, using trending
    DiscoverySource('Google', 'google.svg', 'Google'),
    DiscoverySource('Recipe Websites', 'web.png', 'Recipe Websites'), // Extracted PNG
    DiscoverySource('Family/Friends', 'friend1.svg', 'Family/Friends'), // friend instead of friends
    DiscoverySource('Pinterest', 'printerest.png', 'Pinterest'), // Extracted PNG
    DiscoverySource('Cookbooks', 'cookbook.svg', 'Cookbooks'), // books instead of cookbook
    DiscoverySource('I usually make this up', 'reflex.svg', 'I usually make this up'), // others instead of make_up
  ];

  @override
  void initState() {
    super.initState();
    _selectedSources = widget.initialSources.toSet();
    _otherController = TextEditingController(text: widget.initialOtherSource);
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _handleSourceTap(String source) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedSources.contains(source)) {
        _selectedSources.remove(source);
      } else {
        _selectedSources.add(source);
      }
    });
    
    // We only send the other field text if they selected something that might need it.
    // In the new design there is no explicit 'Others' block, but let's keep the logic
    // if 'I usually make this up' is used as a trigger, or we can just send null.
    // Based on the screenshot, there is no "Others" option.
    widget.onChanged(
      _selectedSources.toList(),
      null,
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
            'Where do you usually get recipes?',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Select all that apply.",
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 32.h),

          Wrap(
            spacing: 16.w,
            runSpacing: 16.h,
            children: _sources.map((source) {
              final isSelected = _selectedSources.contains(source.value);

              final isFullWidth = source.value == 'I usually make this up';
              final itemWidth = isFullWidth 
                  ? double.infinity 
                  : (MediaQuery.of(context).size.width - 40.w - 16.w) / 2;

              return GestureDetector(
                onTap: () => _handleSourceTap(source.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: itemWidth,
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF4F2) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC83A2D)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2.w : 1.w,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFFC83A2D).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (source.iconAsset.isNotEmpty) ...[
                        source.iconAsset.endsWith('.svg')
                            ? SvgPicture.asset(
                                'assets/icones/${source.iconAsset}',
                                height: 26.h,
                                width: 26.w,
                                placeholderBuilder: (BuildContext context) => const SizedBox.shrink(),
                              )
                            : Image.asset(
                                'assets/icones/${source.iconAsset}',
                                height: 32.h,
                                width: 32.w,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 32.h),
        ],
      ),
    );
  }
}
