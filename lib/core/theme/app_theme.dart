import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFC83A2D);
  static const Color darkBlue = Color(0xFF1F4277);
  static const Color green = Color(0xFF1F9D57);
  static const Color yellow = Color(0xFFF2C94C);
  static const Color background = Color(0xFFF0F1F3);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF7B8190);
}

/// Semantic color roles screens should read via `context.colors` instead of
/// hardcoding hex values, so they automatically follow light/dark mode.
///
/// Elevation ladder (both themes): [pageBackground] < [surface] <
/// [elevatedSurface]. A card sits on the page background one step lighter;
/// a modal/bottom sheet/dialog sits on a card one step lighter still - this
/// is what makes dark mode read as layered dark grays instead of one flat
/// black, matching iOS's own systemBackground / secondarySystemBackground /
/// tertiarySystemBackground ladder.
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  final Color pageBackground;
  final Color surface;
  final Color elevatedSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color divider;
  final Color accent;
  final Color destructive;

  const AppColorTokens({
    required this.pageBackground,
    required this.surface,
    required this.elevatedSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.accent,
    required this.destructive,
  });

  static const light = AppColorTokens(
    pageBackground: Color(0xFFF1F5F9),
    surface: Colors.white,
    elevatedSurface: Colors.white,
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
    border: Color(0xFFE2E8F0),
    divider: Color(0xFFF1F5F9),
    accent: Color(0xFFC31E26),
    destructive: Color(0xFFDC2626),
  );

  static const dark = AppColorTokens(
    // Very dark charcoal, not pure black.
    pageBackground: Color(0xFF0D0D0F),
    // Cards/sections: one step lighter than the page (iOS
    // secondarySystemBackground).
    surface: Color(0xFF1C1C1E),
    // Modals/sheets/dialogs: one step lighter again (iOS
    // tertiarySystemBackground), so a sheet visibly separates from the
    // cards behind it instead of matching them.
    elevatedSurface: Color(0xFF2C2C2E),
    // Off-white, not harsh pure white.
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF6B7280),
    border: Color(0xFF3A3A3C),
    divider: Color(0xFF2C2C2E),
    // Slightly brighter/warmer than the light-mode red so buttons still pop
    // with enough contrast against near-black backgrounds.
    accent: Color(0xFFE5323D),
    destructive: Color(0xFFEF4444),
  );

  @override
  AppColorTokens copyWith({
    Color? pageBackground,
    Color? surface,
    Color? elevatedSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? accent,
    Color? destructive,
  }) {
    return AppColorTokens(
      pageBackground: pageBackground ?? this.pageBackground,
      surface: surface ?? this.surface,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      accent: accent ?? this.accent,
      destructive: destructive ?? this.destructive,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
    );
  }
}

extension AppColorTokensContext on BuildContext {
  AppColorTokens get colors =>
      Theme.of(this).extension<AppColorTokens>() ?? AppColorTokens.light;
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'SF Pro',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.yellow,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xEBF8FAFC),
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xCCFFFFFF),
          width: 1.2,
        ),
      ),
    ),
    extensions: const [AppColorTokens.light],
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SF Pro',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.yellow,
      surface: AppColorTokens.dark.surface,
    ),
    scaffoldBackgroundColor: AppColorTokens.dark.pageBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: 'SF Pro',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorTokens.dark.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorTokens.dark.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorTokens.dark.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: TextStyle(color: AppColorTokens.dark.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColorTokens.dark.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColorTokens.dark.border,
          width: 1.2,
        ),
      ),
    ),
    // Default AlertDialog/bottom-sheet fill for the (few) call sites that
    // don't set their own backgroundColor - keeps them one step lighter
    // than cards instead of falling back to Material's flat colorScheme.surface.
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorTokens.dark.elevatedSurface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorTokens.dark.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColorTokens.dark.elevatedSurface,
    ),
    extensions: const [AppColorTokens.dark],
  );
}
