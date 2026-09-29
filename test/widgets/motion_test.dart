import 'package:cooked/core/motion/motion_widgets.dart';
import 'package:cooked/core/widgets/ios_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  testWidgets('AnimatedNumber settles on the new value', (tester) async {
    final value = ValueNotifier<double>(8.42);
    await tester.pumpWidget(_app(ValueListenableBuilder<double>(
      valueListenable: value,
      builder: (_, v, __) => AnimatedNumber(value: v, format: AnimatedNumber.currency),
    )));
    expect(find.text('\$8.42'), findsOneWidget);

    value.value = 14.27;
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('\$14.27'), findsNothing); // still counting
    await tester.pumpAndSettle();
    expect(find.text('\$14.27'), findsOneWidget);
  });

  testWidgets('Only one toast is ever on screen', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(_app(Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));

    IosToast.show(ctx, message: 'First', type: ToastType.success);
    await tester.pump(const Duration(milliseconds: 100));
    IosToast.show(ctx, message: 'Second', type: ToastType.error);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('FadeIndexedStack keeps tab state when switching', (tester) async {
    final index = ValueNotifier<int>(0);
    await tester.pumpWidget(_app(ValueListenableBuilder<int>(
      valueListenable: index,
      builder: (_, i, __) => FadeIndexedStack(
        index: i,
        children: const [_Counter(key: ValueKey('a')), Text('Tab B')],
      ),
    )));

    await tester.tap(find.text('count 0'));
    await tester.pump();
    expect(find.text('count 1'), findsOneWidget);

    index.value = 1;
    await tester.pumpAndSettle();
    index.value = 0;
    await tester.pumpAndSettle();
    expect(find.text('count 1'), findsOneWidget);
  });
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int n = 0;
  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: () => setState(() => n++), child: Text('count $n'));
}
