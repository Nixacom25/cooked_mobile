import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF1E1E2C); // Dark Blue/Black
  static const Color primaryLight = Color(0xFF2D2D44);

  // Accent Colors
  static const Color accent = Color(0xFFFB8324); // Orange from mockup
  static const Color accentLight = Color(0xFFFFAB91);

  // Specific Colors
  static const Color success = Color(0xFF2ECC71); // Vibrant Green for prices
  static const Color error = Color(0xFFE57373);

  // Background Colors
  static const Color background = Color(0xFFF5F5F7); // Off-white
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E1E2C);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Colors.white;
}

class AppConstants {
  static const double defaultPadding = 10.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Diverse HLS Streams for testing
  static const List<String> testVideoUrls = [
    'https://ireplay.tv/test/blender.m3u8', // Blender Loop
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8', // BipBop
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8', // Big Buck Bunny
    'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8', // Sintel
    'https://test-streams.mux.dev/dai-discontinuity-deltatre/manifest.m3u8', // Sports/Ad test
    'https://cph-msl.akamaized.net/hls/live/2000341/test/master.m3u8', // Tears of Steel Live
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8', // BipBop FMP4
  ];
}
