import 'package:bnood/app/shell_scaffold.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('bottom fade is IgnorePointer so list receives taps', (tester) async {
    var tapped = false;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => ShellScaffold(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => ListView(
                    children: [
                      const SizedBox(height: 400),
                      ListTile(
                        title: const Text('last-row'),
                        onTap: () => tapped = true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            StatefulShellBranch(routes: [GoRoute(path: '/clients', builder: (_, __) => const SizedBox())]),
            StatefulShellBranch(routes: [GoRoute(path: '/directory', builder: (_, __) => const SizedBox())]),
            StatefulShellBranch(routes: [GoRoute(path: '/items', builder: (_, __) => const SizedBox())]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('last-row'));
    await tester.pump();
    expect(tapped, isTrue);

    final fadeIgnores = find.descendant(
      of: find.byType(ShellScaffold),
      matching: find.byWidgetPredicate(
        (w) => w is IgnorePointer && w.ignoring,
      ),
    );
    expect(fadeIgnores, findsWidgets);
  });
}
