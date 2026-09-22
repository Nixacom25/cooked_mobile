import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/cooked_blob_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for at least 2.4s for the animation
    await Future.delayed(const Duration(milliseconds: 2400));

    if (!mounted) return;

    final token = await AuthService.instance.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      try {
        // Verify token by fetching user data
        await UserService.instance.getCurrentUser();
        if (!mounted) return;

        final bool isUserPremium = UserService.instance.isPremium;
        if (!isUserPremium) {
          await AuthService.instance.logout();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
        }
      } catch (e) {
        // If token is invalid or expired, force logout and go to welcome
        await AuthService.instance.logout();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CookedBlobBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isDark
                    ? 'assets/images/logo4.png'
                    : 'assets/images/logo5.png',
                width: 220.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

