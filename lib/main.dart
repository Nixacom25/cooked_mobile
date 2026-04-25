import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TutorialService.instance.init();
  await NotificationService.instance.init();
  await HistoryService.instance.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const CookedApp(),
    ),
  );
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
  }

 

  @override
  void dispose() {
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
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            navigatorObservers: [routeObserver],
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.welcome: (_) => const WelcomeScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.otp: (_) => const OtpScreen(),
              AppRoutes.success: (_) => const SuccessScreen(),
              AppRoutes.preferences: (_) => const OnboardingScreen(),
              AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
              AppRoutes.forgotOtp: (_) => const ForgotOtpScreen(),
              AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
              AppRoutes.forgotSuccess: (_) => const ForgotSuccessScreen(),
              AppRoutes.home: (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                return HomeScreen(initialTab: args?['initialTab'] ?? 0);
              },
              AppRoutes.viewAll: (_) => const ViewAllScreen(),
              AppRoutes.cookbookDetail: (_) => const CookbookDetailScreen(),
              AppRoutes.cookbookForm: (_) => const CookbookFormScreen(),
              AppRoutes.recipeDetail: (_) => const RecipeDetailScreen(),
              AppRoutes.profile: (_) => const ProfileScreen(),
              AppRoutes.myAccount: (_) => const MyAccountScreen(),
              AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
              AppRoutes.favorites: (_) => const FavoritesScreen(),
              AppRoutes.activityHistory: (_) => const ActivityHistoryScreen(),
              AppRoutes.helpCenter: (_) => const HelpCenterScreen(),
              AppRoutes.editPreferences: (_) => const UserPreferencesScreen(),
              AppRoutes.subscriptionManagement: (_) =>
                  const SubscriptionManagementScreen(),
              AppRoutes.scan: (_) => ScanScreen(isActiveNotifier: ValueNotifier<bool>(true)),
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
