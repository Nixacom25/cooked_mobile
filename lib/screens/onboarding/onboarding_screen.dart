import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';
import '../../core/widgets/ios_toast.dart';
import 'widgets/language_region_step.dart';

import 'widgets/source_step.dart';
import 'widgets/dietary_preferences_step.dart';
import 'widgets/allergies_step.dart';
import 'widgets/dislikes_step.dart';
import 'widgets/flavor_spice_step.dart';
import 'widgets/cooking_skill_step.dart';
import 'widgets/time_preference_step.dart';
import 'widgets/cooking_target_step.dart';
import 'widgets/cuisines_step.dart';
import 'widgets/kitchen_step.dart';
import 'widgets/meal_planning_step.dart';
import 'widgets/notifications_step.dart';
import 'widgets/goals_step.dart';
import 'widgets/profile_loading_step.dart';
import 'widgets/profile_summary_step.dart';
import 'widgets/trial_step.dart';
import 'widgets/profile_signup_step.dart';
import 'widgets/account_step.dart';
import 'widgets/otp_step.dart';
import 'widgets/recipe_generation_loading_step.dart';
import '../../services/auth_service.dart';
import '../../services/iap_service.dart';
import '../../core/services/tutorial_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/utils/error_helper.dart';

import '../../core/widgets/terms_validation_modal.dart';
import 'onboarding_storage.dart';
import '../../widgets/red_button.dart';
import '../../widgets/loading_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isLoading = false;
  int _analysisDotCount = 0;
  Timer? _analysisTimer;

  // IAP
  List<ProductDetails> _products = [];
  bool _isIapAvailable = false;
  String _selectedPlanId = 'yearly';

  // State for all steps
  // State for all steps
  String _email = '';
  String _password = '';
  bool _acceptedTerms = false;
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _measurementSystem = 'Imperial';
  String? _source;
  String? _otherSource;
  String _language = 'US English';
  String _country = 'US United States';
  Set<String> _selectedDiet = {};
  Set<String> _selectedAllergy = {};
  Set<String> _selectedDislikes = {};
  Map<String, int> _flavorDna = {};
  String _spiceLevel = 'Medium heat';
  String _cookingSkill = 'Home Cook';
  String _cookingTime = '15–30 minutes';
  final String _cookingFrequency = '2–3 times a week';
  String _cookingTarget = '3–4 people';
  List<String> _favoriteCuisines = [];
  List<String> _kitchenAppliances = [];
  String _mealPlanningStyle = 'Weekly meal plan';
  List<String> _notificationPreferences = [];
  List<String> _onboardingGoals = [];
  final int _rating = 0;
  final String _feedback = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initial fallback
    _restoreProgress();
    _loadUser();
    _initIap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAssets();
    });
  }

  void _initIap() async {
    IapService.instance.initialize();
    IapService.instance.onPurchaseSuccess = () {
      if (mounted && _currentPage == 19) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    };
    IapService.instance.onPurchaseError = (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        IosToast.show(
          context,
          message: ErrorHelper.getFriendlyMessage(error),
          type: ToastType.error,
        );
      }
    };

    final products = await IapService.instance.getProducts({
      'monthly_sub',
      'yearly_sub',
    });
    if (mounted) {
      setState(() {
        _products = products;
        _isIapAvailable = products.isNotEmpty;
      });
    }
  }

  void _preloadAssets() {
    final svgs = [
      'assets/icones/Vector.svg',
      'assets/icones/google.svg',
      'assets/icones/apple.svg',
      // Common onboarding icons
      'assets/icones/cook-light-skin.svg',
      'assets/icones/pan.svg',
      'assets/icones/clock.svg',
      'assets/icones/fire.svg',
    ];

    // Preloading assets into memory cache
    for (final asset in svgs) {
      DefaultAssetBundle.of(context).load(asset);
    }

    final images = ['assets/images/fond.png'];

    for (final image in images) {
      precacheImage(AssetImage(image), context);
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _firstName = user['firstname'] ?? '';
        _lastName = user['lastname'] ?? '';
      });
    } catch (_) {
      // Ignore
    }
  }

  @override
  void dispose() {
    IapService.instance.dispose();
    _pageController.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  void _onStepChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    final data = {
      'email': _email,
      'password': _password,
      'acceptedTerms': _acceptedTerms,
      'firstName': _firstName,
      'lastName': _lastName,
      'phone': _phone,
      'measurementSystem': _measurementSystem,
      'source': _source,
      'otherSource': _otherSource,
      'language': _language,
      'country': _country,
      'selectedDiet': _selectedDiet,
      'selectedAllergy': _selectedAllergy,
      'selectedDislikes': _selectedDislikes,
      'flavorDna': _flavorDna,
      'spiceLevel': _spiceLevel,
      'cookingSkill': _cookingSkill,
      'cookingTime': _cookingTime,
      'cookingTarget': _cookingTarget,
      'favoriteCuisines': _favoriteCuisines,
      'kitchenAppliances': _kitchenAppliances,
      'mealPlanningStyle': _mealPlanningStyle,
      'notificationPreferences': _notificationPreferences,
      'onboardingGoals': _onboardingGoals,
    };
    await OnboardingStorage.saveProgress(_currentPage, data);
  }

  Future<void> _restoreProgress() async {
    final progress = await OnboardingStorage.loadProgress();
    if (progress == null) return;

    if (!mounted) return;

    setState(() {
      _currentPage = progress['step'] ?? 0;
      _email = progress['email'] ?? '';
      _password = progress['password'] ?? '';
      _acceptedTerms = progress['acceptedTerms'] ?? false;
      _firstName = progress['firstName'] ?? '';
      _lastName = progress['lastName'] ?? '';
      _phone = progress['phone'] ?? '';
      _measurementSystem = progress['measurementSystem'] ?? 'Imperial';
      _source = progress['source'];
      _otherSource = progress['otherSource'];
      _language = progress['language'] ?? 'US English';
      _country = progress['country'] ?? 'US United States';
      
      if (progress['selectedDiet'] != null) {
        _selectedDiet = (progress['selectedDiet'] as List).cast<String>().toSet();
      }
      if (progress['selectedAllergy'] != null) {
        _selectedAllergy = (progress['selectedAllergy'] as List).cast<String>().toSet();
      }
      if (progress['selectedDislikes'] != null) {
        _selectedDislikes = (progress['selectedDislikes'] as List).cast<String>().toSet();
      }
      if (progress['flavorDna'] != null) {
        _flavorDna = Map<String, int>.from(progress['flavorDna']);
      }
      
      _spiceLevel = progress['spiceLevel'] ?? 'Medium heat';
      _cookingSkill = progress['cookingSkill'] ?? 'Home Cook';
      _cookingTime = progress['cookingTime'] ?? '15–30 minutes';
      _cookingTarget = progress['cookingTarget'] ?? '3–4 people';
      
      if (progress['favoriteCuisines'] != null) {
        _favoriteCuisines = (progress['favoriteCuisines'] as List).cast<String>();
      }
      if (progress['kitchenAppliances'] != null) {
        _kitchenAppliances = (progress['kitchenAppliances'] as List).cast<String>();
      }
      
      _mealPlanningStyle = progress['mealPlanningStyle'] ?? 'Weekly meal plan';
      
      if (progress['notificationPreferences'] != null) {
        _notificationPreferences = (progress['notificationPreferences'] as List).cast<String>();
      }
      if (progress['onboardingGoals'] != null) {
        _onboardingGoals = (progress['onboardingGoals'] as List).cast<String>();
      }
    });

    if (_currentPage > 0) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      } else {
        _pageController = PageController(initialPage: _currentPage);
      }
    }
  }

  int _getEffectiveStep() {
    if (_currentPage < 14) return _currentPage + 1;
    if (_currentPage == 14) return 14; // Freeze during ProfileLoadingStep
    if (_currentPage > 14 && _currentPage < 20) return _currentPage;
    return 19;
  }

  int _calculateRecipeCount() {
    int baseCount = 2847;
    baseCount -= _selectedAllergy.length * 123;
    baseCount -= _selectedDiet.where((d) => d.toLowerCase() != 'none').length * 215;
    baseCount -= _selectedDislikes.length * 67;
    baseCount += _favoriteCuisines.length * 142;
    
    if (baseCount < 400) baseCount = 450 + (baseCount % 100);
    return baseCount;
  }

  Future<void> _onContinue() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    if (_currentPage == 0) {
      // LanguageRegionStep - No mandatory fields for now, or check country
    }

    if (_currentPage < 16) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 16) {
      // ProfileSignupStep handles its own navigation via callbacks
    } else if (_currentPage == 17) {
      // AccountStep -> Submit and potentially OTP
      _submitPreferences(isGuest: false);
    } else if (_currentPage == 18) {
      // OtpStep handles its own navigation via onComplete
    } else if (_currentPage == 19) {
      // TrialStep Payment Trigger
      if (!_isIapAvailable || _products.isEmpty) {
        // Fallback or dev: skip billing if store is unavailable
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        return;
      }

      setState(() => _isLoading = true);
      final targetId = _selectedPlanId == 'yearly'
          ? 'yearly_sub'
          : 'monthly_sub';
      ProductDetails product = _products.first;
      for (var p in _products) {
        if (p.id == targetId) {
          product = p;
          break;
        }
      }

      try {
        await IapService.instance.buyProduct(product);
      } catch (e) {
        setState(() => _isLoading = false);
        IosToast.show(
          context,
          message: 'Could not initiate purchase',
          type: ToastType.error,
        );
      }
    }
  }

  void _onBack() {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    if (_currentPage == 20) return; // Prevent going back during final loading
    if (_currentPage == 15) {
      // Skip ProfileLoadingStep (14) when going back from ProfileSummaryStep
      _pageController.animateToPage(
        13,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  Future<void> _submitPreferences({
    bool isGuest = false,
    String provider = 'LOCAL',
  }) async {
    HapticFeedback.selectionClick();

    if (_acceptedTerms || isGuest) {
      // Immediate loading to prevent visible delay before social picker
      if (provider != 'LOCAL') {
        _startAnalysisLoading();
        setState(() => _isLoading = true);
        // Ensure the loading frame is rendered before social picker takes over
        await Future.delayed(const Duration(milliseconds: 50));
      }
      _submitPreferencesActual(provider: provider, isGuest: isGuest);
      return;
    }

    TermsValidationModal.show(context, onAccepted: () async {
      setState(() => _acceptedTerms = true);
      
      if (provider != 'LOCAL') {
        _startAnalysisLoading();
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      _submitPreferencesActual(provider: provider, isGuest: isGuest);
    });
  }

  Future<void> _submitPreferencesActual({
    bool isGuest = false,
    String provider = 'LOCAL',
  }) async {
    bool isSocial = provider == 'GOOGLE' || provider == 'APPLE';
    
    // Validation before final submission
    if (!isGuest &&
        !isSocial &&
        (_email.isEmpty || _password.isEmpty || !_acceptedTerms)) {
      _pageController.animateToPage(
        17, // AccountStep directly if email signup
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      IosToast.show(
        context,
        message: 'Please complete account info to save your profile',
        type: ToastType.warning,
      );
      return;
    }

    // If not already set by _submitPreferences (e.g. for LOCAL flow)
    if (!_isLoading) {
      _startAnalysisLoading();
      setState(() => _isLoading = true);
    }

    try {
      if (!isGuest) {
        if (!isSocial) {
          // Standard Email Signup
          // Split name if it contains a space and lastname is empty
          String finalFirst = _firstName;
          String finalLast = _lastName;
          if (_lastName.isEmpty && _firstName.contains(' ')) {
            final parts = _firstName.trim().split(' ');
            finalFirst = parts.first;
            finalLast = parts.sublist(1).join(' ');
          }

          await AuthService.instance.register(
            firstname: finalFirst,
            lastname: finalLast,
            email: _email,
            password: _password,
            phone: _phone,
            discoverySource: _source,
            otherDiscoverySource: _otherSource,
            dietaryPreferences: _selectedDiet.toList(),
            allergies: _selectedAllergy.toList(),
            foodDislikes: _selectedDislikes.toList(),
            flavorDna: _flavorDna,
            spiceLevel: _spiceLevel,
            cookingSkill: _cookingSkill,
            cookingTimePreference: _cookingTime,
            cookingFrequency: _cookingFrequency,
            cookingTarget: _cookingTarget,
            favoriteCuisines: _favoriteCuisines,
            kitchenAppliances: _kitchenAppliances,
            mealPlanningStyle: _mealPlanningStyle,
            notificationPreferences: _notificationPreferences,
            onboardingGoals: _onboardingGoals,
            onboardingRating: _rating,
            onboardingFeedback: _feedback,
            language: _language,
            country: _country,
          );
        } else {
          // Atomic Social Registration Flow
          Map<String, dynamic> socialRes;
          if (provider == 'GOOGLE') {
            socialRes = await AuthService.instance.signInWithGoogle(
              isSignup: true,
              isManualBackendCall: false,
            );
          } else {
            socialRes = await AuthService.instance.signInWithApple(
              isSignup: true,
              isManualBackendCall: false,
            );
          }

          developer.log('Social Auth Result: $socialRes', name: 'OnboardingScreen');

          if (socialRes['success'] != true) {
            throw Exception('Social authentication failed');
          }

          // Fallback logic for missing social info (common with Apple)
          String finalEmail = (socialRes['email'] != null && socialRes['email'].toString().isNotEmpty)
              ? socialRes['email']
              : _email;

          String finalFirst = _firstName.isNotEmpty ? _firstName : (socialRes['firstname'] ?? '');
          String finalLast = _lastName.isNotEmpty ? _lastName : (socialRes['lastname'] ?? '');
          
          if (finalLast.isEmpty && finalFirst.contains(' ')) {
            final parts = finalFirst.trim().split(' ');
            finalFirst = parts.first;
            finalLast = parts.sublist(1).join(' ');
          }

          if (finalEmail.isEmpty) {
             throw Exception('Email is required for registration. Please provide your email in the previous step.');
          }

          developer.log('Final Registration Info: $finalEmail, $finalFirst $finalLast', name: 'OnboardingScreen');

          // Now call register with ALL preferences + social identity
          await AuthService.instance.register(
            firstname: finalFirst,
            lastname: finalLast,
            email: finalEmail,
            password: socialRes['idToken'], // Send token as password for verification
            provider: provider,
            phone: _phone,
            discoverySource: _source,
            otherDiscoverySource: _otherSource,
            dietaryPreferences: _selectedDiet.toList(),
            allergies: _selectedAllergy.toList(),
            foodDislikes: _selectedDislikes.toList(),
            flavorDna: _flavorDna,
            spiceLevel: _spiceLevel,
            cookingSkill: _cookingSkill,
            cookingTimePreference: _cookingTime,
            cookingFrequency: _cookingFrequency,
            cookingTarget: _cookingTarget,
            favoriteCuisines: _favoriteCuisines,
            kitchenAppliances: _kitchenAppliances,
            mealPlanningStyle: _mealPlanningStyle,
            notificationPreferences: _notificationPreferences,
            onboardingGoals: _onboardingGoals,
            onboardingRating: _rating,
            onboardingFeedback: _feedback,
            language: _language,
            country: _country,
          );
        }
      } else {
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Reset tutorial for new accounts
      if (!isGuest) {
        TutorialService.instance.reset();
        await OnboardingStorage.clear();
      }

      // Navigation logic ONLY after success
      if (isGuest || isSocial) {
        _pageController.animateToPage(
          19, // Jump to TrialStep
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          18, // Jump to OtpStep
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _stopAnalysisLoading();

      final errorMsg = ErrorHelper.getFriendlyMessage(e).replaceAll('Exception: ', '');
      
      // Security Logic: Block navigation and show clear fallback instructions
      String finalMsg = errorMsg;
      if (isSocial && !errorMsg.contains('already exists')) {
        finalMsg = '$errorMsg\n\nTip: If the problem persists with Google, try signing up via email.';
      }
      
      IosToast.show(
        context,
        message: finalMsg,
        type: ToastType.error,
      );
    }
  }

  void _startAnalysisLoading() {
    _analysisDotCount = 0;
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _analysisDotCount = (_analysisDotCount + 1) % 4;
        });
      }
    });
  }

  void _stopAnalysisLoading() {
    _analysisTimer?.cancel();
  }

  Widget _buildFullScreenLoading() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo2.png',
              width: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            LoadingText(
              text: 'Analyzing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'SF Pro',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),
          SafeArea(
            child: Column(
              children: [
                // Header: Progress & Skip
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: (_currentPage == 20)
                            ? 0.0
                            : 1.0,
                        child: GestureDetector(
                          onTap: (_currentPage == 20)
                              ? null
                              : _onBack,
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.05),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Stack(
                            children: [
                              Container(
                                height: 6.h,
                                color: const Color(0xFFE5E7EB),
                              ),
                              AnimatedFractionallySizedBox(
                                duration: const Duration(milliseconds: 400),
                                widthFactor: _getEffectiveStep() / 20,
                                child: Container(
                                  height: 6.h,
                                  color: const Color(0xFFC83A2D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: _onStepChanged,
                    children: [

                      LanguageRegionStep(
                        initialLanguage: _language,
                        initialCountry: _country,
                        initialMeasurementSystem: _measurementSystem,
                        onChanged:
                            ({
                              required language,
                              required country,
                              required measurementSystem,
                            }) {
                              setState(() {
                                _language = language;
                                _country = country;
                                _measurementSystem = measurementSystem;
                              });
                            },
                      ),
                      SourceStep(
                        userName: _firstName.isEmpty ? 'Friend' : _firstName,
                        initialSource: _source,
                        initialOtherSource: _otherSource,
                        onChanged: (src, other) {
                          setState(() {
                            _source = src;
                            _otherSource = other;
                          });
                        },
                      ),
                      // Removed duplicated steps
                      DietaryPreferencesStep(
                        initialSelected: _selectedDiet,
                        onChanged: (selected) =>
                            setState(() => _selectedDiet = selected),
                      ),
                      AllergiesStep(
                        initialSelected: _selectedAllergy,
                        onChanged: (selected) =>
                            setState(() => _selectedAllergy = selected),
                      ),
                      DislikesStep(
                        initialSelected: _selectedDislikes,
                        onChanged: (selected) =>
                            setState(() => _selectedDislikes = selected),
                      ),
                      FlavorSpiceStep(
                        initialDna: _flavorDna,
                        initialSpice: _spiceLevel,
                        onChanged: ({required dna, required spice}) {
                          setState(() {
                            _flavorDna = dna;
                            _spiceLevel = spice;
                          });
                        },
                      ),
                      CookingSkillStep(
                        initialSelected: _cookingSkill,
                        onChanged: (selected) =>
                            setState(() => _cookingSkill = selected),
                      ),
                      TimePreferenceStep(
                        initialSelected: _cookingTime,
                        onChanged: (selected) =>
                            setState(() => _cookingTime = selected),
                      ),
                      CookingTargetStep(
                        initialTarget: _cookingTarget,
                        onChanged: (target) =>
                            setState(() => _cookingTarget = target),
                      ),
                      CuisinesStep(
                        initialSelected: _favoriteCuisines,
                        onChanged: (selected) =>
                            setState(() => _favoriteCuisines = selected),
                      ),
                      KitchenStep(
                        initialSelected: _kitchenAppliances,
                        onChanged: (selected) =>
                            setState(() => _kitchenAppliances = selected),
                      ),
                      MealPlanningStep(
                        initialSelected: _mealPlanningStyle,
                        onChanged: (selected) =>
                            setState(() => _mealPlanningStyle = selected),
                      ),
                      NotificationsStep(
                        initialSelected: _notificationPreferences,
                        onChanged: (selected) =>
                            setState(() => _notificationPreferences = selected),
                      ),
                      GoalsStep(
                        initialSelected: _onboardingGoals,
                        onChanged: (selected) =>
                            setState(() => _onboardingGoals = selected),
                      ),
                      ProfileLoadingStep(onComplete: _onContinue),
                      ProfileSummaryStep(
                        firstName: _firstName,
                        favoriteCuisines: _favoriteCuisines,
                        flavorDna: _flavorDna.keys.toList(),
                        recipeCount: _calculateRecipeCount(),
                        onContinue: _onContinue,
                      ),
                      ProfileSignupStep(
                        onSignupEmail: () {
                          TermsValidationModal.show(
                            context,
                            onAccepted: () {
                              setState(() => _acceptedTerms = true);
                              _pageController.animateToPage(
                                17, // AccountStep
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                          );
                        },
                        onSignupGoogle: () =>
                            _submitPreferences(provider: 'GOOGLE'),
                        onSignupApple: () =>
                            _submitPreferences(provider: 'APPLE'),
                        onGuest: () => _submitPreferences(isGuest: true),
                      ),
                      AccountStep(
                        initialFullName: _firstName,
                        initialEmail: _email,
                        initialPassword: _password,
                        initialPhone: _phone,
                        initialAcceptedTerms: _acceptedTerms,
                        onChanged:
                            ({
                              required fullName,
                              required email,
                              required password,
                              required phone,
                              required acceptedTerms,
                            }) {
                              setState(() {
                                _firstName = fullName;
                                _email = email;
                                _password = password;
                                _phone = phone;
                                _acceptedTerms = acceptedTerms;
                              });
                            },
                      ),
                      OtpStep(
                        email: _email,
                        onComplete: () {
                          _pageController.animateToPage(
                            19, // TrialStep
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      TrialStep(
                        onPlanSelected: (plan) {
                          setState(() => _selectedPlanId = plan);
                        },
                        onSkip: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      RecipeGenerationLoadingStep(
                        onComplete: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                              arguments: {'initialTab': 0},
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Footer: Continue Button
                if (_currentPage != 14 && // ProfileLoading
                    _currentPage != 16 && // ProfileSignup
                    _currentPage != 18 && // Otp
                    _currentPage != 20)  // RecipeGenerationLoading
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 5.h, 24.w, 15.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RedButton(
                            label: _currentPage == 19
                                ? (_selectedPlanId == 'yearly'
                                    ? 'Start My 3-Day Free Trial'
                                    : 'Start Monthly Subscription')
                                : 'Continue',
                            loadingLabel: _currentPage == 19 ? 'Processing' : 'Continuing',
                            isLoading: _isLoading,
                            isDisabled: (_currentPage == 1 && _source == null) ||
                                (_currentPage == 17 && (_email.isEmpty || _password.isEmpty || !_acceptedTerms)),
                            onTap: _onContinue,
                            height: 55.h,
                            fontSize: 18.sp,
                          ),
                          if (_currentPage == 19) ...[
                            // TrialStep
                            SizedBox(height: 12.h),
                            Text(
                              _selectedPlanId == 'yearly'
                                  ? '3 days free, then \$29.99 per year (\$2.49/mo)'
                                  : '\$9.99 per month',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF7B8190),
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                          // "Sign In" link only for the first onboarding step
                          if (_currentPage == 0) ...[
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF7B8190),
                                    fontFamily: 'SF Pro',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.login,
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFC83A2D),
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading) _buildFullScreenLoading(),
        ],
      ),
    ),
  );
}
}
