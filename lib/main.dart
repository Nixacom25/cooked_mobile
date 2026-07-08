import 'package:cooked/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/success_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/forgot_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/forgot_success_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/view_all_screen.dart';
import 'screens/home/cookbook_detail_screen.dart';
import 'screens/home/cookbook_form_screen.dart';
import 'screens/home/recipe_detail_screen.dart';
import 'screens/home/savings_details_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/my_account_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/activity_history_screen.dart';
import 'screens/profile/help_center_screen.dart';
import 'screens/profile/user_preferences_screen.dart';
import 'screens/profile/subscription_management_screen.dart';
import 'screens/scan_screen.dart';
import 'package:cooked/core/services/tutorial_service.dart';
import 'package:cooked/services/notification_service.dart';
import 'package:cooked/services/history_service.dart';
import 'package:cooked/services/sharing_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cooked/widgets/clipboard_banner.dart';
import 'package:cooked/widgets/floating_heart.dart';
// import 'package:cooked/core/widgets/ios_toast.dart';

import 'package:cooked/services/database_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:rive/rive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();

  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  await DatabaseService.instance.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const CookedApp());
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class CookedApp extends StatefulWidget {
  const CookedApp({super.key});

  @override
  State<CookedApp> createState() => _CookedAppState();
}

class _CookedAppState extends State<CookedApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  // OverlayEntry? _clipboardOverlay;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SharingService.instance.sharedTextNotifier.removeListener(_onSharedTextReceived);
    // SharingService.instance.clipboardTextNotifier.removeListener(_onClipboardTextReceived);
    // _removeClipboardOverlay();
    SharingService.instance.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // SharingService.instance.checkClipboard();
    }
  }

  // void _onClipboardTextReceived() {
  //   final url = SharingService.instance.clipboardTextNotifier.value;
  //   if (url != null && url.isNotEmpty) {
  //     _showClipboardOverlay(url);
  //   } else {
  //     _removeClipboardOverlay();
  //   }
  // }

  // void _showClipboardOverlay(String url) {
  //   _removeClipboardOverlay();
  //   _clipboardOverlay = OverlayEntry(
  //     builder: (context) => ClipboardBanner(
  //       url: url,
  //       topOffset: MediaQuery.of(context).padding.top + 10.h,
  //       onClose: () => SharingService.instance.ignoreClipboard(),
  //       onPaste: () => _handlePaste(url),
  //     ),
  //   );
  //   _navigatorKey.currentState?.overlay?.insert(_clipboardOverlay!);
  // }
  // 
  // void _removeClipboardOverlay() {
  //   _clipboardOverlay?.remove();
  //   _clipboardOverlay = null;
  // }
  // 
  // void _handlePaste(String dummyUrl) async {
  //   SharingService.instance.ignoreClipboard();
  //   
  //   // Read the clipboard now that the user explicitly initiated the action
  //   final data = await Clipboard.getData(Clipboard.kTextPlain);
  //   final text = data?.text;
  //   if (text == null || text.isEmpty) return;
  //   
  //   final url = SharingService.instance.extractUrl(text);
  //   if (url == null) return;
  //   
  //   final isLoggedIn = AuthService.instance.isLoggedIn;
  // 
  //   if (!isLoggedIn) {
  //     final state = _navigatorKey.currentState;
  //     if (state != null) {
  //       state.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         IosToast.show(state.context, message: 'Please log in first to save this recipe', type: ToastType.warning);
  //       });
  //     }
  //     return;
  //   }
  // 
  //   final state = _navigatorKey.currentState;
  //   if (state != null) {
  //     // Check if it's an internal recipe link
  //     final recipeRegex = RegExp(r'(?:cooked\.nixacom\.com|cookedapp\.com)/(?:share/)?recipes/([a-zA-Z0-9-]+)');
  //     final match = recipeRegex.firstMatch(url);
  // 
  //     if (match != null) {
  //       final recipeId = match.group(1);
  //       debugPrint("CookedApp: Internal recipe link pasted. ID: $recipeId");
  //       
  //       state.pushNamedAndRemoveUntil(
  //         AppRoutes.home,
  //         (route) => false,
  //       );
  //       state.pushNamed(
  //         AppRoutes.recipeDetail,
  //         arguments: {'recipeId': recipeId},
  //       );
  //     } else {
  //       state.pushNamedAndRemoveUntil(
  //         AppRoutes.home,
  //         (route) => false,
  //         arguments: {'initialTab': 4, 'initialUrl': url},
  //       );
  //     }
  //   }
  // }

  Future<void> _initApp() async {
    try {
      SharingService.instance.init();
      SharingService.instance.sharedTextNotifier.addListener(_onSharedTextReceived);
      // SharingService.instance.clipboardTextNotifier.addListener(_onClipboardTextReceived);
      
      // Check clipboard on startup
      // SharingService.instance.checkClipboard();

      await Future.wait([
        AuthService.instance.getToken(),
        TutorialService.instance.init(),
        NotificationService.instance.init(),
        HistoryService.instance.init(),
      ]);
      
      _initDeepLinks();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    
    // Handle link when app is in cold state
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        debugPrint("CookedApp: Initial AppLink received: $uri");
        _handleDeepLink(uri.toString());
      }
    });

    // Handle link when app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        debugPrint("CookedApp: AppLink stream received: $uri");
        _handleDeepLink(uri.toString());
      }
    }, onError: (err) {
      debugPrint("CookedApp: AppLink stream error: $err");
    });
  }

  void _handleDeepLink(String url) {
    // Treat the deep link exactly like a shared text
    SharingService.instance.sharedTextNotifier.value = url;
  }

  void _onSharedTextReceived() {
    final text = SharingService.instance.sharedTextNotifier.value;
    debugPrint("CookedApp: _onSharedTextReceived triggered with text: $text");
    
    if (text != null && text.isNotEmpty) {
      final url = SharingService.instance.extractUrl(text);
      debugPrint("CookedApp: Extracted URL: $url");
      
      if (url != null) {
        // Heavy impact to show we caught it
        HapticFeedback.heavyImpact();
        
        final isLoggedIn = AuthService.instance.isLoggedIn;
        
        if (!isLoggedIn) {
          debugPrint("CookedApp: User not logged in. Keeping shared URL in memory for post-login import.");
          // We don't clear it from SharingService, so it stays available
          // If the user is on Welcome/Login, they will eventually log in
          // We can optionally force redirect to Welcome if they are elsewhere
          final state = _navigatorKey.currentState;
          if (state != null) {
             String? currentRoute;
             state.popUntil((route) {
               currentRoute = route.settings.name;
               return true;
             });
             
             if (currentRoute != AppRoutes.welcome && 
                 currentRoute != AppRoutes.login && 
                 currentRoute != AppRoutes.otp) {
               debugPrint("CookedApp: Not on auth screens, redirecting to Welcome.");
               state.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
             }
          }
          return;
        }

        // Short delay to ensure navigator is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          final state = _navigatorKey.currentState;
          if (state != null) {
            debugPrint("CookedApp: Processing shared URL: $url");
            
            // Check if it's an internal recipe link
            final recipeRegex = RegExp(r'(?:cooked\.nixacom\.com|cookedapp\.com)/(?:share/)?recipes/([a-zA-Z0-9-]+)');
            final match = recipeRegex.firstMatch(url);
            
            if (match != null) {
              final recipeId = match.group(1);
              debugPrint("CookedApp: Internal recipe link detected. ID: $recipeId");
              
              state.pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
              state.pushNamed(
                AppRoutes.recipeDetail,
                arguments: {'recipeId': recipeId},
              );
            } else {
              debugPrint("CookedApp: External link detected. Navigating to Import with URL: $url");
              state.pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
                arguments: {'initialTab': 4, 'initialUrl': url},
              );
            }
            SharingService.instance.consumeSharedText();
          } else {
            debugPrint("CookedApp: Navigator state is STILL NULL after delay.");
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: _NoScrollbarBehavior(),
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Cooked',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            builder: (context, child) {
              return FloatingHeartManager(
                child: GestureDetector(
                  onTap: () {
                    final currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  },
                  child: child!,
                ),
              );
            },
            navigatorObservers: [
              routeObserver,
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
            ],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              final isLoggedIn = AuthService.instance.isLoggedIn;
              final name = settings.name;

              // 🛡️ Navigation Guard
              if (isLoggedIn) {
                if (name == AppRoutes.welcome || name == AppRoutes.login) {
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                }
              }

              // Normal Routing
              Widget builder;
              switch (name) {
                case AppRoutes.splash:
                  builder = const SplashScreen();
                  break;
                case AppRoutes.welcome:
                  builder = const WelcomeScreen();
                  break;
                case AppRoutes.login:
                  builder = const LoginScreen();
                  break;
                case AppRoutes.otp:
                  builder = const OtpScreen();
                  break;
                case AppRoutes.success:
                  builder = const SuccessScreen();
                  break;
                case AppRoutes.preferences:
                  builder = const OnboardingScreen();
                  break;
                case AppRoutes.forgotPassword:
                  builder = const ForgotPasswordScreen();
                  break;
                case AppRoutes.forgotOtp:
                  builder = const ForgotOtpScreen();
                  break;
                case AppRoutes.resetPassword:
                  builder = const ResetPasswordScreen();
                  break;
                case AppRoutes.forgotSuccess:
                  builder = const ForgotSuccessScreen();
                  break;
                case AppRoutes.home:
                  final args = settings.arguments as Map<String, dynamic>?;
                  builder = HomeScreen(
                    initialTab: args?['initialTab'] ?? 0,
                    initialUrl: args?['initialUrl'],
                  );
                  break;
                case AppRoutes.viewAll:
                  builder = const ViewAllScreen();
                  break;
                case AppRoutes.cookbookDetail:
                  builder = const CookbookDetailScreen();
                  break;
                case AppRoutes.cookbookForm:
                  builder = const CookbookFormScreen();
                  break;
                case AppRoutes.recipeDetail:
                  builder = const RecipeDetailScreen();
                  break;
                case AppRoutes.profile:
                  builder = const ProfileScreen();
                  break;
                case AppRoutes.myAccount:
                  builder = const MyAccountScreen();
                  break;
                case AppRoutes.changePassword:
                  builder = const ChangePasswordScreen();
                  break;
                case AppRoutes.activityHistory:
                  builder = const ActivityHistoryScreen();
                  break;
                case AppRoutes.helpCenter:
                  builder = const HelpCenterScreen();
                  break;
                case AppRoutes.editPreferences:
                  builder = const UserPreferencesScreen();
                  break;
                case AppRoutes.subscriptionManagement:
                  builder = const SubscriptionManagementScreen();
                  break;
                case AppRoutes.scan:
                  builder = ScanScreen(isActiveNotifier: ValueNotifier<bool>(true));
                  break;
                case AppRoutes.savingsDetails:
                  builder = const SavingsDetailsScreen();
                  break;
                default:
                  builder = const SplashScreen();
              }

              return MaterialPageRoute(
                builder: (context) => builder,
                settings: settings,
              );
            },
          ),
        );
      },
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
