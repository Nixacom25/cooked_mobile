import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/user_service.dart';
import '../../core/widgets/ios_toast.dart';
import 'widgets/savings_step.dart';
import 'widgets/meals_step.dart';
import 'widgets/dinner_figured_out_step.dart';
import 'widgets/frustrations_step.dart';
import 'widgets/costing_more_step.dart';
import 'widgets/groceries_bad_step.dart';
import 'widgets/eating_out_budget_step.dart';
import 'widgets/total_savings_step.dart';
import 'widgets/cooking_system_loading_step.dart';
import 'widgets/profile_loading_step.dart';
import 'widgets/age_step.dart';
import 'widgets/healthy_eating_intro_step.dart';
import 'widgets/meal_repetition_intro_step.dart';
import 'widgets/cooked_handles_meals_step.dart';
import 'widgets/features_excited_step.dart';
import 'widgets/goals_step.dart';
import 'widgets/health_goals_step.dart';
import 'widgets/frustrations_intro_step.dart';

import 'widgets/source_step.dart';
import 'widgets/grocery_shop_step.dart';
import 'widgets/excited_features_step.dart';
import 'widgets/dietary_preferences_step.dart';
import 'widgets/allergies_step.dart';
import 'widgets/dislikes_step.dart';
import 'widgets/flavor_spice_step.dart';
import 'widgets/cooking_skill_step.dart';
import 'widgets/time_preference_step.dart';
import 'widgets/cooking_target_step.dart';
import 'widgets/cuisines_step.dart';
import 'widgets/kitchen_step.dart';
import 'widgets/meal_repetition_step.dart';
import 'widgets/notifications_step.dart';
import 'widgets/savings_pitch_step.dart';
import 'widgets/profile_summary_step.dart';
import 'widgets/social_proof_step.dart';
import 'widgets/trial_step.dart';
import 'widgets/profile_signup_step.dart';
import 'widgets/account_step.dart';
import 'widgets/otp_step.dart';
import 'widgets/recipe_generation_loading_step.dart';
import 'widgets/free_trial_guide_step.dart';
import 'widgets/perfect_meal_step.dart';

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
  List<String> _recipeSources = [];
  String? _otherSource;
  String? _groceryFrequency;
  List<String> _groceryStores = [];
  String? _groceryBudget;
  List<String> _excitedFeatures = [];
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
  List<String> _notificationPreferences = [];
  List<String> _onboardingGoals = [];
  List<String> _featuresExcited = [];

  int _eatingOutSavings = 0;
  int _grocerySavings = 0;

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
          duration: const Duration(milliseconds: 300),
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
      'source': _recipeSources.join(','),
      'groceryFrequency': _groceryFrequency,
      'groceryStores': _groceryStores,
      'groceryBudget': _groceryBudget,
      'excitedFeatures': _excitedFeatures,
      'otherSource': _otherSource,
      'selectedDiet': _selectedDiet.toList(),
      'selectedAllergy': _selectedAllergy.toList(),
      'selectedDislikes': _selectedDislikes.toList(),
      'flavorDna': _flavorDna,
      'spiceLevel': _spiceLevel,
      'cookingSkill': _cookingSkill,
      'cookingTime': _cookingTime,
      'cookingTarget': _cookingTarget,
      'favoriteCuisines': _favoriteCuisines,
      'kitchenAppliances': _kitchenAppliances,
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
      _recipeSources = (progress['source'] as String?)?.split(',').where((e) => e.isNotEmpty).toList() ?? [];
      _groceryFrequency = progress['groceryFrequency'] as String?;
      _groceryStores = (progress['groceryStores'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      _groceryBudget = progress['groceryBudget'] as String?;
      _excitedFeatures = (progress['excitedFeatures'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      _otherSource = progress['otherSource'] as String?;
      
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
      
      if (progress['favoriteCuisines'] != null) {
        _favoriteCuisines = (progress['favoriteCuisines'] as List).cast<String>();
      }
      if (progress['kitchenAppliances'] != null) {
        _kitchenAppliances = (progress['kitchenAppliances'] as List).cast<String>();
      }
      
      if (progress['notificationPreferences'] != null) {
        _notificationPreferences = (progress['notificationPreferences'] as List).cast<String>();
      }
      if (progress['onboardingGoals'] != null) {
        _onboardingGoals = (progress['onboardingGoals'] as List).cast<String>();
      }
    });

    if (_currentPage > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }
  }

  int _getEffectiveStep() {
    if (_currentPage == 8 || _currentPage == 20) return _currentPage;
    return _currentPage < 23 ? _currentPage + 1 : 23;
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

    if (_currentPage == 2) {
      // FrustrationsStep
    } else if (_currentPage == 3) {
      // SpendEatingOutStep
    } else if (_currentPage == 4) {
      // GroceriesBadStep
    } else if (_currentPage == 5) {
      // FridgeScannerStep
    } else if (_currentPage == 6) {
      // TakeoutSpendingStep
    } else if (_currentPage == 7) {
      // CookMoreSaveMoneyStep
    } else if (_currentPage == 8) {
      // CookingSystemStep
    } else if (_currentPage == 9) {
      // AgeStep
    } else if (_currentPage == 10) {
      // GoalsStep
    } else if (_currentPage == 11) {
      // HealthGoalsStep
    } else if (_currentPage == 12) {
      // FrustrationsIntroStep
    } else if (_currentPage == 13) {
      // CookingSkillStep
    } else if (_currentPage == 14) {
      // CuisinesStep
    } else if (_currentPage == 15) {
      // MealRepetitionStep
    }

    if (_currentPage < 21) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 21) {
      // ProfileSummaryStep handles its own navigation via callbacks
    } else if (_currentPage == 33) {
      // AccountStep -> Submit and potentially OTP
      _submitPreferences(isGuest: false);
    } else if (_currentPage == 34) {
      // OtpStep handles its own navigation via onComplete
    } else if (_currentPage == 35) {
      // FreeTrialGuideStep handles its own navigation
    } else if (_currentPage == 36) {
      // TrialStep Payment Trigger
      if (!_isIapAvailable || _products.isEmpty) {
        // Fallback or dev: skip billing if store is unavailable
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
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
    if (_currentPage == 20 || _currentPage == 8) return; // Prevent going back during loading steps
    
    if (_currentPage == 21) {
      // Skip ProfileLoadingStep (20) when going back from ProfileSummaryStep
      _pageController.jumpToPage(19);
      return;
    }

    if (_currentPage == 9) {
      // Skip CookingSystemLoadingStep (8) when going back from GoalsStep
      _pageController.jumpToPage(7);
      return;
    }
    
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
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
      _submitPreferencesActual(provider: provider, isGuest: isGuest);
      return;
    }

    TermsValidationModal.show(context, onAccepted: () async {
      setState(() => _acceptedTerms = true);
      
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
      _pageController.jumpToPage(33);
      IosToast.show(
        context,
        message: 'Please complete account info to save your profile',
        type: ToastType.warning,
      );
      return;
    }

    // If not already set (e.g. for LOCAL flow)
    if (!isSocial && !_isLoading) {
      _startAnalysisLoading();
      setState(() => _isLoading = true);
    }

    try {
      if (!isGuest) {
        if (!isSocial) {
          // Standard Email Signup
          // Split name if it contains a space and lastname is empty
          String finalFirst = _firstName.isNotEmpty ? _firstName : 'Chef';
          String finalLast = _lastName;
          if (_lastName.isEmpty && _firstName.contains(' ')) {
            final trimmedName = _firstName.trim();
            final lastSpaceIndex = trimmedName.lastIndexOf(' ');
            finalFirst = trimmedName.substring(0, lastSpaceIndex).trim();
            finalLast = trimmedName.substring(lastSpaceIndex + 1).trim();
          }

          await AuthService.instance.register(
            firstname: finalFirst,
            lastname: finalLast,
            email: _email,
            password: _password,
            phone: _phone,
            discoverySource: _recipeSources.join(','),
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
            groceryFrequency: _groceryFrequency,
            groceryStores: _groceryStores,
            groceryBudget: _groceryBudget,
            excitedFeatures: _excitedFeatures,
            notificationPreferences: _notificationPreferences,
            onboardingGoals: _onboardingGoals,
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

          // Start loading ONLY after the social modal has been dismissed by the user
          _startAnalysisLoading();
          setState(() => _isLoading = true);

          developer.log('Social Auth Result: $socialRes', name: 'OnboardingScreen');

          if (socialRes['success'] != true) {
            throw Exception('Social authentication failed');
          }

          // Fallback logic for missing social info (common with Apple)
          String finalEmail = (socialRes['email'] != null && socialRes['email'].toString().isNotEmpty)
              ? socialRes['email']
              : _email;

          String finalFirst = _firstName.isNotEmpty ? _firstName : (socialRes['firstname']?.toString().isNotEmpty == true ? socialRes['firstname'] : 'Chef');
          String finalLast = _lastName.isNotEmpty ? _lastName : (socialRes['lastname'] ?? '');
          
          if (finalLast.isEmpty && finalFirst.contains(' ')) {
            final trimmedName = finalFirst.trim();
            final lastSpaceIndex = trimmedName.lastIndexOf(' ');
            finalFirst = trimmedName.substring(0, lastSpaceIndex).trim();
            finalLast = trimmedName.substring(lastSpaceIndex + 1).trim();
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
            photo: socialRes['photo'],
            discoverySource: _recipeSources.join(','),
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
            groceryFrequency: _groceryFrequency,
            groceryStores: _groceryStores,
            groceryBudget: _groceryBudget,
            excitedFeatures: _excitedFeatures,
            notificationPreferences: _notificationPreferences,
            onboardingGoals: _onboardingGoals,
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
        _pageController.jumpToPage(35); // Jump to FreeTrialGuideStep directly
      } else {
        _pageController.jumpToPage(34); // Jump to OtpStep for local auth
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
              width: 100.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),
            LoadingText(
              text: 'Connecting',
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
          // Image.asset('assets/images/fond.png', fit: BoxFit.cover),
          Container(color: Colors.white),
          SafeArea(
            child: Column(
              children: [
                // Header: Progress & Skip
                if (_currentPage != 8 && _currentPage != 20)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                  child: Row(
                    children: [
                      Opacity(
                        opacity: 1.0,
                        child: GestureDetector(
                          onTap: _onBack,
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
                                widthFactor: (_getEffectiveStep() / 23).clamp(0.0, 1.0),
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
                      MealsStep(onContinue: _onContinue), // Step 1
                      DinnerFiguredOutStep(onContinue: _onContinue), // Step 2
                      FrustrationsStep(onContinue: _onContinue), // Step 3
                      SavingsStep(onContinue: _onContinue), // Step 4
                      CostingMoreStep(onContinue: _onContinue), // Step 5
                      EatingOutBudgetStep(onContinue: (savings) {
                        setState(() => _eatingOutSavings = savings);
                        _onContinue();
                      }), // Step 6
                      GroceriesBadStep(onContinue: (savings) {
                        setState(() => _grocerySavings = savings);
                        _onContinue();
                      }), // Step 7
                      TotalSavingsStep(
                        eatingOutSavings: _eatingOutSavings,
                        grocerySavings: _grocerySavings,
                        onContinue: _onContinue,
                      ), // Step 8
                      CookingSystemLoadingStep(onContinue: _onContinue), // Step 9
                      GoalsStep( // Step 10
                        onContinue: _onContinue,
                        initialSelected: _onboardingGoals.where((g) => [
                          'save_money', 'eat_healthier', 'gain_muscle', 'lose_weight',
                          'waste_less', 'learn_cook', 'discover_recipes', 'meal_prep'
                        ].contains(g)).toList(),
                        onChanged: (selections) {
                          setState(() {
                            final healthGoals = _onboardingGoals.where((g) => [
                              'weight_loss', 'muscle_gain', 'high_protein', 'healthy_heart', 
                              'quick_meals', 'budget_friendly', 'no_goal'
                            ].contains(g)).toList();
                            _onboardingGoals = [...selections, ...healthGoals];
                          });
                        },
                      ),
                      AgeStep(onContinue: _onContinue), // Step 11
                      CuisinesStep( // Step 12
                        initialSelected: _favoriteCuisines,
                        onChanged: (val) => setState(() => _favoriteCuisines = val),
                        onContinue: _onContinue,
                      ),
                      AllergiesStep( // Step 13
                        initialSelected: _selectedAllergy,
                        onChanged: (selected) =>
                            setState(() => _selectedAllergy = selected),
                        onContinue: _onContinue,
                      ),
                      DislikesStep( // Step 14
                        initialSelected: _selectedDislikes,
                        onChanged: (selected) =>
                            setState(() => _selectedDislikes = selected),
                        onContinue: _onContinue,
                      ),
                      TimePreferenceStep( // Step 15
                        initialSelected: _cookingTime,
                        onChanged: (selected) =>
                            setState(() => _cookingTime = selected),
                        onContinue: _onContinue,
                      ),
                      CookingTargetStep( // Step 16
                        initialTarget: _cookingTarget,
                        onChanged: (target) =>
                            setState(() => _cookingTarget = target),
                        onContinue: _onContinue,
                      ),
                      
                      HealthyEatingIntroStep( // Step 17
                        onContinue: _onContinue,
                      ),
                      MealRepetitionIntroStep( // Step 18
                        onContinue: _onContinue,
                      ),
                      CookedHandlesMealsStep( // Step 19
                        onContinue: _onContinue,
                      ),
                      FeaturesExcitedStep( // Step 20
                        initialSelected: _featuresExcited,
                        onChanged: (selected) =>
                            setState(() => _featuresExcited = selected),
                        onContinue: _onContinue,
                      ),
                      ProfileLoadingStep(onComplete: _onContinue),
                      ProfileSummaryStep(
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
                              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                        initialEmail: _email,
                        initialPassword: _password,
                        initialPhone: _phone,
                        initialAcceptedTerms: _acceptedTerms,
                        
                        onChanged:
                            ({
                              required email,
                              required password,
                              required phone,
                              required acceptedTerms,
                              firstname,
                              lastname,
                            }) {
                              setState(() {
                                _email = email;
                                _password = password;
                                _phone = phone;
                                _acceptedTerms = acceptedTerms;
                                _firstName = firstname ?? '';
                                _lastName = lastname ?? '';
                              });
                            },
                      ),
                      OtpStep(
                        email: _email,
                        onComplete: () {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                      FreeTrialGuideStep(
                        onContinue: () {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                      TrialStep(
                        onPlanSelected: (plan) {
                          setState(() => _selectedPlanId = plan);
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        onSkip: () {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                      ),
                      PerfectMealStep(
                        onStartCooking: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                              arguments: {'initialTab': 0},
                            );
                          }
                        },
                        onViewMore: () {
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.home,
                              arguments: {'initialTab': 0},
                            );
                          }
                        },
                      ),
                    ].map((step) => Container(child: step)).toList(),
                  ),
                ),

                // Footer: Continue Button
                if (_currentPage != 0 && // MealsStep
                    _currentPage != 1 && // DinnerFiguredOutStep
                    _currentPage != 2 && // FrustrationsStep
                    _currentPage != 3 && // SavingsStep
                    _currentPage != 4 && // CostingMoreStep
                    _currentPage != 5 && // EatingOutBudgetStep
                    _currentPage != 6 && // GroceriesBadStep
                    _currentPage != 7 && // TotalSavingsStep
                    _currentPage != 8 && // CookMoreSaveMoneyStep
                    _currentPage != 9 && // CookingSystemStep
                    _currentPage != 10 && // GoalsStep
                    _currentPage != 11 && // HealthGoalsStep
                    _currentPage != 12 && // AllergiesStep
                    _currentPage != 13 && // DislikesStep
                    _currentPage != 14 && // TimePreferenceStep
                    _currentPage != 15 && // CookingTargetStep
                    _currentPage != 16 && // HealthyEatingIntroStep
                    _currentPage != 17 && // MealRepetitionIntroStep
                    _currentPage != 18 && // CookedHandlesMealsStep
                    _currentPage != 19 && // FeaturesExcitedStep
                    _currentPage != 31 && // ProfileLoading
                    _currentPage != 32 && // ProfileSummary
                    _currentPage != 33 && // SocialProof
                    _currentPage != 34 && // SavingsPitch
                    _currentPage != 35 && // RecipeGenLoading
                    _currentPage != 32 && // ProfileSignup
                    _currentPage != 34 && // Otp
                    _currentPage != 35 && // FreeTrialGuideStep
                    _currentPage != 37)  // PerfectMealStep
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 5.h, 24.w, 15.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentPage == 18) ...[
                            // Dislikes step Skip button
                            GestureDetector(
                              onTap: _onContinue,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(50.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'Skip — I eat most things',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                          ],
                          RedButton(
                            label: _currentPage == 36
                                ? 'Start My 3-Day Free Trial (\$0.00)'
                                : 'Continue',
                            loadingLabel: _currentPage == 36 ? 'Processing' : 'Continuing',
                            isLoading: _isLoading,
                            isDisabled: (_currentPage == 22 && (_groceryFrequency == null || _groceryStores.isEmpty || _groceryBudget == null)) ||
                                (_currentPage == 24 && _recipeSources.isEmpty) ||
                                (_currentPage == 25 && _excitedFeatures.isEmpty) ||
                                (_currentPage == 33 && (_email.isEmpty || _password.isEmpty || !_acceptedTerms)),
                            onTap: _currentPage == 36 ? () {
                              if (mounted) {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            } : _onContinue, // Trial step skips billing and goes home
                            height: 55.h,
                            fontSize: 18.sp,
                          ),
                          if (_currentPage == 36) ...[
                            // TrialStep
                            SizedBox(height: 12.h),
                            Text(
                              _selectedPlanId == 'yearly'
                                  ? '3 days free, then \$29.99 per year (\$2.49/mo)'
                                  : '3 days free, then \$9.99 per month',
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
