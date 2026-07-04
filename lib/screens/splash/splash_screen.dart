import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for at least 2.4s for the animation
    await Future.delayed(const Duration(milliseconds: 2400));

    if (!mounted) return;

    final token = await AuthService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        // Verify token by fetching user data
        await UserService.instance.getCurrentUser();
        if (!mounted) return;
        
        final bool isUserPremium = UserService.instance.isPremium;
        if (!isUserPremium) {
          await AuthService.instance.logout();
          Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        // If token is invalid or expired, force logout and go to welcome
        await AuthService.instance.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Food pattern background
          Image.asset('assets/images/fond.png', fit: BoxFit.cover),
          // Centered logo only — no title/button here
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 140,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
