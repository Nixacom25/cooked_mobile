class TutorialService {
  static final TutorialService instance = TutorialService._();
  TutorialService._();

  int _currentStep = 0;
  bool _isTutorialActive = true; // Set to true for testing

  int get currentStep => _currentStep;
  bool get isTutorialActive => _isTutorialActive;

  void nextStep() {
    _currentStep++;
  }

  void reset() {
    _currentStep = 0;
    _isTutorialActive = true;
  }

  void complete() {
    _isTutorialActive = false;
  }

  void setStep(int step) {
    _currentStep = step;
  }
}
