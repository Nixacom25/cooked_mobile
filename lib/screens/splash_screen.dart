import 'package:flutter/material.dart';
import 'package:app_ecommerce/utils/constants.dart';
import 'package:app_ecommerce/screens/main_navigation.dart';
import 'package:app_ecommerce/services/video_preload_service.dart';
import 'package:app_ecommerce/services/data_cache_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Ensure the splash screen is rendered before starting heavy tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start fetching data immediately while animation plays
      final dataFuture = _prefetchData();

      // Navigate to Main Navigation (Reels Tab) after delay AND data fetch
      Future.wait([
        Future.delayed(const Duration(seconds: 5)),
        dataFuture,
      ]).then((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 0),
            ),
          );
        }
      });
    });
  }

  Future<void> _prefetchData() async {
    // Start preloading videos immediately while splash screen is visible
    VideoPreloadService.preloadFirstVideos();

    // Prefetch all critical home screen data globally before navigation
    try {
      await DataCacheService().prefetchAll();
    } catch (e) {
      debugPrint("Warning: Cache prefetch failed: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'BAWANE',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
