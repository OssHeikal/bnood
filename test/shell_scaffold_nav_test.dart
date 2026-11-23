import 'package:bnood/app/shell_scaffold.dart';
import 'package:bnood/app/shell_tab_scaffold.dart';
import 'package:bnood/app/widgets/floating_shell_dock.dart';
import 'package:bnood/core/ui/theme/app_theme.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('bottom fade is IgnorePointer so list receives taps', (
    tester,
  ) async {
    var tapped = false;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellScaffold(navigationShell: navigationShell),
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
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/clients', builder: (_, _) => const SizedBox()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/directory',
                  builder: (_, _) => const SizedBox(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/more', builder: (_, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('last-row'));
    await tester.pump();
    expect(tapped, isTrue);

    final fadeIgnores = find.descendant(
      of: find.byType(ShellScaffold),
      matching: find.byWidgetPredicate((w) => w is IgnorePointer && w.ignoring),
    );
    expect(fadeIgnores, findsWidgets);
  });

  testWidgets('keyboard applies inset once to tab list viewport', (
    tester,
  ) async {
    const phone = Size(390, 844);
    const keyboard = 336.0;
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;

    final router = GoRouter(
      initialLocation: '/clients',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellScaffold(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/clients',
                  builder: (_, _) => ShellTabScaffold(
                    body: ListView(
                      key: const PageStorageKey('clients-test'),
                      children: const [SizedBox(height: 1200)],
                    ),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/directory',
                  builder: (_, _) => const SizedBox(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/more', builder: (_, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.reset);
    await tester.pump();

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    final expectedViewport = phone.height - keyboard;
    expect(position.viewportDimension, closeTo(expectedViewport, 8));
    expect(
      position.viewportDimension,
      greaterThan(phone.height - keyboard * 1.5),
    );
  });

  testWidgets('hides floating dock while keyboard is open', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              ShellScaffold(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) =>
                      const Scaffold(body: TextField()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/clients', builder: (_, _) => const SizedBox()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/directory',
                  builder: (_, _) => const SizedBox(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/more', builder: (_, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(FloatingShellDock), findsOneWidget);

    tester.view.viewInsets = const FakeViewPadding(bottom: 336);
    addTearDown(tester.view.reset);
    await tester.pump();
    expect(find.byType(FloatingShellDock), findsNothing);

    final padded = tester.widgetList<MediaQuery>(
      find.descendant(
        of: find.byType(ShellScaffold),
        matching: find.byType(MediaQuery),
      ),
    );
    expect(
      padded.any(
        (mq) => mq.data.padding.bottom < FloatingShellDock.clearanceHeight,
      ),
      isTrue,
    );
  });
}
