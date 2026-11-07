import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/suppliers/widgets/directory_person_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('paid-only subtitle without kind metadata', (tester) async {
    var detailTaps = 0;
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => HomeFoundationScope(
                child: Scaffold(
                  body: DirectoryPersonCard(
                    name: 'Ahmed Steel',
                    paidPiastres: 50000,
                    accentKey: 'teal',
                    localeCode: 'en',
                    onOpenDetail: () => detailTaps++,
                    onArchive: () async {},
                  ),
                ),
              ),
            ),
            GoRoute(path: '/suppliers/x', builder: (_, __) => const Scaffold(body: Text('detail'))),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Materials supplier'), findsNothing);
    expect(find.textContaining('EGP'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.archive_outlined), findsNothing);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(detailTaps, 0);
    expect(find.text('View details'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
  });

  testWidgets('card body tap opens detail; menu does not navigate on open', (tester) async {
    var detailTaps = 0;
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, __) => HomeFoundationScope(
                child: Scaffold(
                  body: DirectoryPersonCard(
                    name: 'Vendor',
                    paidPiastres: 0,
                    accentKey: 'teal',
                    localeCode: 'en',
                    onOpenDetail: () => detailTaps++,
                    onArchive: () async {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Vendor'));
    await tester.pump();
    expect(detailTaps, 1);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(detailTaps, 1);
  });
}
