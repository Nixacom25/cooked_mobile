import 'package:cooked/core/motion/shimmer_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({bool reduceMotion = false}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Scaffold(
            body: ShimmerText(
              'What would you like to cook today?',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ),
      );

  testWidgets('sweeps a highlight across the text on a loop', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('What would you like to cook today?'), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
    // Keeps running (loop) without throwing, across several cycles.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 700));
    }
    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('Reduce Motion shows plain text in full color', (tester) async {
    await tester.pumpWidget(host(reduceMotion: true));
    expect(find.byType(ShaderMask), findsNothing);
    final text = tester.widget<Text>(find.text('What would you like to cook today?'));
    expect(text.style?.color, Colors.black);
  });
}
