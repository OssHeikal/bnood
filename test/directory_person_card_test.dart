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
              builder: (_, _) => HomeFoundationScope(
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
            GoRoute(
              path: '/suppliers/x',
              builder: (_, _) => const Scaffold(body: Text('detail')),
            ),
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
              builder: (_, _) => HomeFoundationScope(
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

  testWidgets('craftsman card puts paid trailing and remaining as an unlabeled subtitle', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: DirectoryPersonCard(
              name: 'Ahmed',
              trade: 'Plumber',
              paidPiastres: 100000,
              remainingPiastres: 700000,
              paidInTrailing: true,
              accentKey: 'teal',
              localeCode: 'en',
              showOverflowMenu: false,
              onOpenDetail: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final name = tester.getTopLeft(find.text('Ahmed'));
    final paid = tester.getTopLeft(find.textContaining('1,000 EGP'));
    final remaining = tester.getTopLeft(find.textContaining('7,000 EGP'));
    expect(paid.dx, greaterThan(name.dx));
    expect(remaining.dx, lessThan(paid.dx));
    expect(remaining.dy, greaterThan(name.dy));
    expect(find.text('Paid: '), findsNothing);
    expect(find.text('Remaining'), findsNothing);
  });
}
