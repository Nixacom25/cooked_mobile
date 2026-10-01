import 'package:cooked/core/theme/app_theme.dart';
import 'package:cooked/l10n/app_localizations.dart';
import 'package:cooked/widgets/import_fallback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// The fallback page must fit on one screen (no scroll) on every phone size,
/// in light and dark, with the longest (French) copy.
void main() {
  const sizes = [Size(320, 568), Size(375, 667), Size(393, 852), Size(430, 932)];

  for (final size in sizes) {
    for (final dark in [false, true]) {
      for (final locale in const [Locale('en'), Locale('fr')]) {
        testWidgets('fits ${size.width.toInt()}x${size.height.toInt()} '
            '${dark ? 'dark' : 'light'} ${locale.languageCode}', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => MaterialApp(
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: ImportFallbackPage(
                  failedUrl: 'https://www.instagram.com/reel/Dd7dkazPg5v/?stkn=MTMyN254bDdzdGRndA',
                  errorMessage: 'Website is blocking access. Please try another source.',
                  onTryAnotherLink: () {},
                  onEnterManually: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(Scrollable), findsNothing);
          expect(find.byIcon(Icons.link_rounded), findsOneWidget);
          expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
        });
      }
    }
  }
}
