import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'package:cooked/widgets/scan_animation_overlay.dart';
import 'package:cooked/models/recipe.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanAnimationOverlay & Rive Asset Verification', () {
    test('Verify cooked.riv asset file exists and is readable binary', () async {
      final file = File('assets/cooked.riv');
      expect(file.existsSync(), isTrue, reason: 'assets/cooked.riv must exist in project root');

      final bytes = await file.readAsBytes();
      expect(bytes.length, greaterThan(0), reason: 'assets/cooked.riv file must not be empty');
    });

    testWidgets('ScanAnimationOverlay renders placeholder initially and triggers completion callback', (WidgetTester tester) async {
      bool completed = false;

      // Ignore expected headless desktop FFI font symbol lookup log during test execution
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('makeFont')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanAnimationOverlay(
              showTestControls: true,
              onAnimationComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Verify widget mounts cleanly without throwing exceptions
      expect(find.byType(ScanAnimationOverlay), findsOneWidget);

      // Tap close/fermer button in test controls
      final closeButton = find.text('Fermer');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(completed, isTrue, reason: 'onAnimationComplete callback should be called on close');
      FlutterError.onError = originalOnError;
    });

    testWidgets('ScanAnimationOverlay completes automatically when data is provided', (WidgetTester tester) async {
      bool completed = false;

      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('makeFont')) return;
        originalOnError?.call(details);
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanAnimationOverlay(
              generatedRecipes: [
                Recipe(
                  id: '1',
                  name: 'Test Recipe',
                  cookTime: 15,
                  kcal: 300,
                  steps: [],
                  equipment: [],
                  ingredients: [],
                  isPublic: false,
                  isFavorite: false,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ],
              onAnimationComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Fast-forward timer by 2.1 seconds to trigger minimum animation duration
      await tester.pump(const Duration(milliseconds: 2100));

      expect(completed, isTrue, reason: 'Animation overlay must trigger onAnimationComplete when recipes are ready');
      FlutterError.onError = originalOnError;
    });
  });
}
