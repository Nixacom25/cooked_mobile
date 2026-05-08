import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlavorSpiceStep extends StatefulWidget {
  final Map<String, int> initialDna;
  final String? initialSpice;
  final Function({required Map<String, int> dna, required String spice})
  onChanged;

  const FlavorSpiceStep({
    super.key,
    required this.initialDna,
    required this.initialSpice,
    required this.onChanged,
  });

  @override
  State<FlavorSpiceStep> createState() => _FlavorSpiceStepState();
}

class _FlavorSpiceStepState extends State<FlavorSpiceStep> {
  late Map<String, int> _dna;
  late String _spice;

  final List<Map<String, String>> _levels = [
    {'title': 'Mild', 'desc': 'No heat at all', 'chillis': '1'},
    {'title': 'Medium', 'desc': 'Just a hint of spice', 'chillis': '2'},
    {'title': 'Spicy', 'desc': 'I enjoy spice', 'chillis': '3'},
    {'title': 'Hot', 'desc': 'The spicier the better', 'chillis': '4'},
    {'title': 'Inferno', 'desc': 'I put hot sauce', 'chillis': '5'},
  ];

  final List<Map<String, dynamic>> _scales = [
    {
      'left': 'Sweet',
      'leftEmoji': '🍰',
      'right': 'Savory',
      'rightEmoji': '🧂',
      'key': 'sweetness',
    },
    {
      'left': 'Crunchy textures',
      'leftEmoji': '🍟',
      'right': 'Soft & creamy',
      'rightEmoji': '🧀',
      'key': 'texture',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dna = Map.from(widget.initialDna);
    _spice = widget.initialSpice ?? 'Mild';
    // Ensure keys exist
    for (var scale in _scales) {
      _dna.putIfAbsent(scale['key']!, () => 50);
    }
  }

  void _notifyChange() {
    widget.onChanged(dna: _dna, spice: _spice);
  }

  String _getSummaryLabel(int value) {
    if (value < 40) return 'More Left';
    if (value > 60) return 'More Right';
    return 'Balanced';
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels.firstWhere(
      (l) => l['title'] == _spice,
      orElse: () => _levels.first,
    );
    final chiliCount = int.parse(currentLevel['chillis']!);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your flavor DNA',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Move the sliders to match your taste',
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF9CA3AF),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 16.h),

          // Spice Tolerance Section
          Text(
            'Spice Tolerance',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final active = index < chiliCount;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _spice = _levels[index]['title']!);
                        _notifyChange();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: SvgPicture.asset(
                          active
                              ? 'assets/icones/spice1.svg'
                              : 'assets/icones/spice2.svg',
                          width: 25.sp,
                          height: 25.sp,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentLevel['title']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0D1B3E),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currentLevel['desc']!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF9CA3AF),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Flavor DNA Sliders
          ..._scales.map((scale) {
            final key = scale['key']!;
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            scale['leftEmoji']!,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            scale['left']!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0D1B3E),
                              fontFamily: 'SF Pro',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            scale['right']!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0D1B3E),
                              fontFamily: 'SF Pro',
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            scale['rightEmoji']!,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFC83A2D),
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      trackHeight: 4.0.h,
                      thumbColor: const Color(0xFFC83A2D),
                      overlayColor: const Color(0xFFC83A2D).withAlpha(32),
                      trackShape: RoundedRectSliderTrackShape(),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: _dna[key]!.toDouble(),
                      min: 0,
                      max: 100,
                      onChanged: (val) {
                        setState(() => _dna[key] = val.toInt());
                        _notifyChange();
                      },
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Summary Box
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F7F2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  'Your Flavor DNA:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                    fontFamily: 'SF Pro',
                  ),
                ),
                SizedBox(height: 14.h),
                Wrap(
                  spacing: 12.w,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSummaryCapsule(_spice),
                    ..._scales.map(
                      (s) => _buildSummaryCapsule(
                        _getSummaryLabel(_dna[s['key']!]!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildSummaryCapsule(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }
}
