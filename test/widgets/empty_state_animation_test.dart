import 'package:cooked/core/motion/motion_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final kind in EmptyStateKind.values) {
    testWidgets('EmptyStateAnimation ${kind.name} runs a full loop without errors', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Center(child: EmptyStateAnimation(kind: kind, color: Colors.grey)),
      ));
      // One full cycle (5.5 s) in small steps.
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
    });
  }
}
