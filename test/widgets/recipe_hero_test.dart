import 'package:cooked/core/motion/motion_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _card(String label) => RecipeHeroArea(
      child: SizedBox(
        width: 100,
        height: 100,
        child: RecipeHeroImage(child: ColoredBox(color: Colors.red, child: Text(label))),
      ),
    );

String _tagOf(WidgetTester tester, String label) => tester
    .widget<Hero>(find.ancestor(of: find.text(label), matching: find.byType(Hero)))
    .tag as String;

void main() {
  testWidgets('only the touched card shares its tag with the detail page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Column(children: [_card('A'), _card('B')])),
    ));
    // Same recipe shown twice on one screen must not collide.
    expect(_tagOf(tester, 'A'), isNot(_tagOf(tester, 'B')));

    await tester.tap(find.text('B'));
    await tester.pump();
    final claimed = RecipeHero.claimTag();
    expect(claimed, isNotNull);
    expect(_tagOf(tester, 'B'), claimed);
    expect(_tagOf(tester, 'A'), isNot(claimed));
  });

  testWidgets('no tag is claimed long after the last touch', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: _card('C'))));
    await tester.tap(find.text('C'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1600)));
    expect(RecipeHero.claimTag(), isNull);
  });
}
