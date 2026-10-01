import 'package:cooked/core/motion/motion_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets('HeartBump flying heart is drawn in the overlay and stays red', (tester) async {
    var saved = false;
    late StateSetter set;
    const red = Color(0xFFC31E26);
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        set = setState;
        return Center(
          child: ClipRect(
            child: HeartBump(
              active: saved,
              ringColor: red,
              iconSize: 24,
              child: Icon(saved ? Icons.favorite : Icons.favorite_border, size: 24),
            ),
          ),
        );
      }),
    ));
    set(() => saved = true);
    await tester.pump();
    for (final ms in [80, 200, 400, 700]) {
      await tester.pump(Duration(milliseconds: ms ~/ 4));
      final flying = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Icons.favorite_rounded);
      expect(flying, findsOneWidget);
      // Every frame of the jump uses the app red (no purple/pink phase).
      expect(tester.widget<Icon>(flying).color, red);
      // Painted in the overlay, not under the ClipRect around the button.
      RenderObject? node = tester.renderObject(flying);
      var clipped = false;
      while (node != null) {
        if (node is RenderClipRect) clipped = true;
        node = node.parent;
      }
      expect(clipped, isFalse);
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('HeartBump plays save and unsave animations without errors', (tester) async {
    var saved = false;
    late StateSetter set;
    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(builder: (context, setState) {
        set = setState;
        return Center(
          child: HeartBump(
            active: saved,
            iconSize: 24,
            child: Icon(saved ? Icons.favorite : Icons.favorite_border, size: 24),
          ),
        );
      }),
    ));
    set(() => saved = true);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    set(() => saved = false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

String _dollars(double v) => '\$${v.toStringAsFixed(0)}';
