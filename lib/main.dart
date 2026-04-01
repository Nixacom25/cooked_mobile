import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:device_preview/device_preview.dart';
import 'package:app_ecommerce/utils/theme.dart';
import 'package:app_ecommerce/screens/splash_screen.dart';
import 'package:app_ecommerce/services/global_video_cache.dart';

import 'package:app_ecommerce/screens/cart_screen.dart';
import 'package:app_ecommerce/screens/validation_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_ecommerce/services/fcm_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FCMService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
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
      navigatorKey: navigatorKey, // Add key
      useInheritedMediaQuery: true, // Required for DevicePreview
      locale: DevicePreview.locale(context), // Add the locale
      builder: (context, child) {
        return DevicePreview.appBuilder(context, child);
      },
      debugShowCheckedModeBanner: false,
      title: 'Bawane',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/cart': (context) => const CartScreen(),
        '/validation': (context) => const ValidationScreen(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
    );
  }
}
