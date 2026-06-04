import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

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

class _FlavorSpiceStepState extends State<FlavorSpiceStep> with SingleTickerProviderStateMixin {
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

  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _spiceOpacity;
  late Animation<Offset> _spiceSlide;
  late List<Animation<double>> _sliderOpacities;
  late List<Animation<Offset>> _sliderSlides;
  late Animation<double> _summaryOpacity;
  late Animation<Offset> _summarySlide;

  @override
  void initState() {
    super.initState();
    _dna = Map.from(widget.initialDna);
    _spice = widget.initialSpice ?? 'Mild';
    for (var scale in _scales) {
      _dna.putIfAbsent(scale['key']!, () => 50);
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Animation<double> createOpacity(double start, double end) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    }

    Animation<Offset> createSlide(double start, double end) {
      return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    }

    _titleOpacity = createOpacity(0.0, 0.4);
    _titleSlide = createSlide(0.0, 0.4);

    _subtitleOpacity = createOpacity(0.1, 0.5);
    _subtitleSlide = createSlide(0.1, 0.5);

    _spiceOpacity = createOpacity(0.2, 0.6);
    _spiceSlide = createSlide(0.2, 0.6);

    _sliderOpacities = [];
    _sliderSlides = [];
    double currentDelay = 0.3;
    for (int i = 0; i < _scales.length; i++) {
      _sliderOpacities.add(createOpacity(currentDelay, currentDelay + 0.4));
      _sliderSlides.add(createSlide(currentDelay, currentDelay + 0.4));
      currentDelay += 0.1;
    }

    _summaryOpacity = createOpacity(currentDelay, currentDelay + 0.4);
    _summarySlide = createSlide(currentDelay, currentDelay + 0.4);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onChanged(dna: _dna, spice: _spice);
  }

  String _getSummaryLabel(int value) {
    if (value < 40) return 'Sweet';
    if (value > 60) return 'Savory';
    return 'Balanced';
  }

  String _getTextureLabel(int value) {
    if (value < 40) return 'Crunchy';
    if (value > 60) return 'Creamy';
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _titleOpacity,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'Your flavor DNA',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0D1B3E),
                      fontFamily: 'SF Pro',
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FadeTransition(
                opacity: _subtitleOpacity,
                child: SlideTransition(
                  position: _subtitleSlide,
                  child: Text(
                    'Move the sliders to match your taste',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Spice Tolerance Section
              FadeTransition(
                opacity: _spiceOpacity,
                child: SlideTransition(
                  position: _spiceSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spice Tolerance',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
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
                                    HapticFeedback.selectionClick();
                                    setState(() => _spice = _levels[index]['title']!);
                                    _notifyChange();
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4.w),
                                    child: SvgPicture.asset(
                                      active
                                          ? 'assets/icones/spice1.svg'
                                          : 'assets/icones/spice3.svg',
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
                                      fontSize: 14.sp,
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
                                        fontSize: 11.sp,
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Flavor DNA Sliders
              ...List.generate(_scales.length, (index) {
                final scale = _scales[index];
                final key = scale['key']!;
                return FadeTransition(
                  opacity: _sliderOpacities[index],
                  child: SlideTransition(
                    position: _sliderSlides[index],
                    child: Container(
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
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
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
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
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
                                if ((val - _dna[key]!).abs() > 5) {
                                  HapticFeedback.selectionClick();
                                }
                                setState(() => _dna[key] = val.toInt());
                                _notifyChange();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Summary Box
              FadeTransition(
                opacity: _summaryOpacity,
                child: SlideTransition(
                  position: _summarySlide,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR PROFILE PREVIEW',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: const Color(0xFF7B8190),
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _buildSummaryCapsule(
                              label: _spice,
                              bgColor: const Color(0xFFFEE2E2), // Light Red
                              textColor: const Color(0xFFEF4444), // Red
                            ),
                            _buildSummaryCapsule(
                              label: '${_getSummaryLabel(_dna['sweetness']!)} leaning',
                              bgColor: const Color(0xFFE5E7EB), // Light Grey
                              textColor: const Color(0xFF4B5563), // Grey
                            ),
                            _buildSummaryCapsule(
                              label: '${_getTextureLabel(_dna['texture']!)} texture',
                              bgColor: const Color(0xFFDBEAFE), // Light Blue
                              textColor: const Color(0xFF3B82F6), // Blue
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSummaryCapsule({required String label, required Color bgColor, required Color textColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }
}
