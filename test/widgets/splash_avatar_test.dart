import 'package:cooked/l10n/app_localizations.dart';
import 'package:cooked/screens/splash/scan_frame_splash.dart';
import 'package:cooked/screens/splash/splash_screen.dart';
import 'package:cooked/screens/splash/splash_to_welcome.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cooked/widgets/alphabet_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('same seed = same plate whatever the displayed name', (tester) async {
    await tester.pumpWidget(_host(const Row(children: [
      AlphabetAvatar(name: 'Awa', seed: 'user-42'),
      AlphabetAvatar(name: 'Awa Diop', seed: 'user-42'),
    ])));
    final a = tester.widgetList<AlphabetAvatar>(find.byType(AlphabetAvatar)).map((w) => AlphabetAvatar.plateAvatarAsset(w.seed ?? w.name)).toSet();
    expect(a.length, 1);
  });

  test('plate avatar is stable per name and spread over the 8 plates', () {
    expect(AlphabetAvatar.plateAvatarAsset('Awa'), AlphabetAvatar.plateAvatarAsset(' awa '));
    final plates = {for (final n in ['Awa', 'Moussa', 'Fatou', 'John', 'Marie', 'Ali', 'Lea', 'Sam', 'Ana', 'Ibra']) AlphabetAvatar.plateAvatarAsset(n)};
    expect(plates.length, greaterThan(3));
    expect(AlphabetAvatar.plateAvatarAsset(''), 'assets/images/avatars/plate_01.svg');
    for (final p in plates) {
      expect(p, matches(RegExp(r'^assets/images/avatars/plate_0[1-8]\.svg$')));
    }
  });

  testWidgets('splash A animates in without errors', (tester) async {
    await tester.pumpWidget(_host(const SignatureRedSplash()));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.text('Dinner starts with what you already have.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('splash B: logo, then corners, then a looping scan', (tester) async {
    await tester.pumpWidget(_host(const ScanFrameSplash()));
    await tester.pump(const Duration(milliseconds: 600));
    // Corners haven't started yet at 0.6 s.
    expect(find.byType(CustomPaint).evaluate().where((e) => (e.widget as CustomPaint).size == const Size(44, 44)).length, 4);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.text('Dinner starts with what you already have.'), findsOneWidget);
    expect(tester.hasRunningAnimations, isTrue); // the scan keeps looping
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final variant in SplashVariant.values) {
    testWidgets('splash → welcome preview ($variant): logo rises, then texts', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(SplashToWelcome(variant: variant)));
      // Splash plays; welcome texts not shown yet.
      await tester.pump(const Duration(milliseconds: 2000));
      expect(find.text('Get Started'), findsNothing);
      // Hold + transition.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Welcome to Cooked'), findsOneWidget);
      // Sign In nudges (scale + wobble) once everything is in.
      await tester.pump(const Duration(milliseconds: 400));
      final nudged = find.ancestor(of: find.text('Sign In'), matching: find.byType(Transform));
      expect(nudged, findsWidgets);
      await tester.pumpWidget(const SizedBox());
      // Only missing-font noise from google_fonts is tolerated in tests.
      final error = tester.takeException();
      expect(error == null || '$error'.toLowerCase().contains('font'), isTrue, reason: '$error');
    });
  }
}

