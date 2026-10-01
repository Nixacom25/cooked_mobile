import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';

/// Holds the app's UI language. English is the default; the user picks
/// another one on the Language page. Saved locally so the app starts in the
/// right language before the profile has loaded.
class LocaleService {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const String _prefKey = 'app_locale';
  static const Locale fallback = Locale('en');

  final ValueNotifier<Locale> locale = ValueNotifier(fallback);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) locale.value = _supported(Locale(code));
    } catch (_) {
      // Keep the default language.
    }
    Intl.defaultLocale = locale.value.languageCode;
    await initializeDateFormatting();
  }

  /// [language] is the stored profile value ("US English", "FR Français",
  /// "ES Español", ...).
  Future<void> setFromLanguageValue(String? language) => setLocale(localeForLanguage(language));

  Future<void> setLocale(Locale value) async {
    final next = _supported(value);
    if (next == locale.value) return;
    // Dates/numbers formatted with intl follow the UI language.
    Intl.defaultLocale = next.languageCode;
    locale.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, next.languageCode);
    } catch (_) {
      // Not persisted; the profile language is applied again on next launch.
    }
  }

  /// Profile value for the current UI language ("FR Français"...), used
  /// when the profile has none stored yet.
  String get languageValue => switch (locale.value.languageCode) {
        'fr' => 'FR Français',
        'es' => 'ES Español',
        _ => 'US English',
      };

  static Locale localeForLanguage(String? language) {
    final code = (language ?? '').trim().toUpperCase();
    if (code.startsWith('FR')) return const Locale('fr');
    if (code.startsWith('ES')) return const Locale('es');
    return fallback;
  }

  static Locale _supported(Locale value) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == value.languageCode)
          ? Locale(value.languageCode)
          : fallback;
}
