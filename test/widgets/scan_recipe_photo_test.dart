import 'package:cooked/core/motion/skeleton.dart';
import 'package:cooked/widgets/scan_recipe_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(String? url) => MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 300, height: 200, child: ScanRecipePhoto(url: url)),
        ),
      );

  testWidgets('shows a skeleton while the AI photo is loading', (tester) async {
    await tester.pumpWidget(host('https://link.cookedapp.com/share/ai-photo/x.jpg'));
    expect(find.byType(SkeletonBox), findsOneWidget);
  });

  testWidgets('no photo: the default dish, no skeleton', (tester) async {
    await tester.pumpWidget(host(null));
    expect(find.byType(SkeletonBox), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}
