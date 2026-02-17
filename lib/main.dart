import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:device_preview/device_preview.dart';
import 'package:app_ecommerce/utils/theme.dart';
import 'package:app_ecommerce/screens/splash_screen.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';
import 'package:app_ecommerce/widgets/floating_cart_overlay.dart';
import 'package:app_ecommerce/utils/cart_observer.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey _cartOverlayKey = GlobalKey();

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(), // Wrap your app
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Cleanup ALL videos when app closes
    GlobalVideoCache.disposeAll();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App in background - pause all videos
      GlobalVideoCache.pauseAllExcept(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // Add key
      navigatorObservers: [CartVisibilityObserver()], // Add observer
      useInheritedMediaQuery: true, // Required for DevicePreview
      locale: DevicePreview.locale(context), // Add the locale
      builder: (context, child) {
        final widget = DevicePreview.appBuilder(context, child);
        return Stack(
          children: [
            widget,
            FloatingCartOverlay(
              key: _cartOverlayKey, // Ensure state is preserved
              navigatorKey: _navigatorKey,
            ),
          ],
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Bawane',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
    );
  }
}
