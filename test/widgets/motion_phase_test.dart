import 'package:cooked/core/motion/motion_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SlidingPillChips slides one pill under the selected chip', (tester) async {
    int? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SlidingPillChips(
            height: 40,
            spacing: 8,
            pillColor: Colors.red,
            itemCount: 3,
            selectedIndex: selected,
            onTap: (i) => setState(() => selected = i),
            itemBuilder: (_, i, __) => SizedBox(width: 60, height: 30, child: Text('chip$i')),
          ),
        ),
      ),
    ));
    expect(find.byType(AnimatedPositioned), findsNothing); // nothing selected

    await tester.tap(find.text('chip0'));
    await tester.pumpAndSettle();
    final left0 = tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left;

    await tester.tap(find.text('chip2'));
    await tester.pumpAndSettle();
    final left2 = tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left;

    expect(find.byType(AnimatedPositioned), findsOneWidget); // a single shared pill
    expect(left2! - left0!, 2 * (60 + 8));
  });

  testWidgets('AnimatedRemoval calls onRemoved after its exit animation', (tester) async {
    var removed = false;
    var removing = false;
    late StateSetter set;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        set = setState;
        return AnimatedRemoval(
          removing: removing,
          onRemoved: () => removed = true,
          child: const Text('item'),
        );
      }),
    ));
    set(() => removing = true);
    await tester.pump();
    expect(removed, isFalse); // still animating out
    await tester.pumpAndSettle();
    expect(removed, isTrue);
  });

  testWidgets('AnimatedNumber counts up from 0 after its delay', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AnimatedNumber(
        value: 68,
        format: _dollars,
        countUpFrom: 0,
        startDelay: Duration(milliseconds: 250),
        duration: Duration(milliseconds: 900),
      ),
    ));
    expect(find.text('\$0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300)); // delay passed
    await tester.pump(const Duration(milliseconds: 400)); // mid-count
    expect(find.text('\$0'), findsNothing);
    expect(find.text('\$68'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('\$68'), findsOneWidget);
  });
}

String _dollars(double v) => '\$${v.toStringAsFixed(0)}';
