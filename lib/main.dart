import 'package:cooked/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
import 'screens/profile/profile_screen.dart';
import 'screens/profile/my_account_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/favorites_screen.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class _CookedAppState extends State<CookedApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Non-blocking initialization
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      SharingService.instance.init();
      SharingService.instance.sharedTextNotifier.addListener(_onSharedTextReceived);

      await Future.wait([
        AuthService.instance.getToken(),
        TutorialService.instance.init(),
        NotificationService.instance.init(),
        HistoryService.instance.init(),
      ]);
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
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
            debugPrint("CookedApp: Navigating to Home/Import with URL: $url");
            state.pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
              arguments: {'initialTab': 4, 'initialUrl': url},
            );
            SharingService.instance.consumeSharedText();
          } else {
            debugPrint("CookedApp: Navigator state is STILL NULL after delay.");
          }
        });
      }
    }
  }

  @override
  void dispose() {
    SharingService.instance.sharedTextNotifier.removeListener(_onSharedTextReceived);
    SharingService.instance.dispose();
    super.dispose();
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
              return GestureDetector(
                onTap: () {
                  final currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
                child: child!,
              );
            },
            navigatorObservers: [routeObserver],
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
                case AppRoutes.favorites:
                  builder = const FavoritesScreen();
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
