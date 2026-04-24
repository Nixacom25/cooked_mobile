import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static final TutorialService instance = TutorialService._();
  TutorialService._();

  static const String _keyHome = 'seen_tutorial_home';
  static const String _keyScan = 'seen_tutorial_scan';
  static const String _keyImport = 'seen_tutorial_import';

  SharedPreferences? _prefs;
  int _currentStep = 0;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  int get currentStep => _currentStep;
  
  bool get hasSeenHome => _prefs?.getBool(_keyHome) ?? false;
  bool get hasSeenScan => _prefs?.getBool(_keyScan) ?? false;
  bool get hasSeenImport => _prefs?.getBool(_keyImport) ?? false;

  bool get isTutorialActive => !hasSeenHome;

  Future<void> completeHome() async {
    await _prefs?.setBool(_keyHome, true);
  }

  Future<void> completeScan() async {
    await _prefs?.setBool(_keyScan, true);
  }

  Future<void> completeImport() async {
    await _prefs?.setBool(_keyImport, true);
  }

  void reset() {
    _currentStep = 0;
    _prefs?.setBool(_keyHome, false);
    _prefs?.setBool(_keyScan, false);
    _prefs?.setBool(_keyImport, false);
  }

  void setStep(int step) {
    _currentStep = step;
  }
}
