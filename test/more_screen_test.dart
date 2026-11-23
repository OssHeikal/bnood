import 'package:bnood/app/shell_bottom_inset.dart';
import 'package:bnood/core/services/config/theme/app_size.dart';
import 'package:bnood/core/ui/layout/bnood_list_canvas.dart';
import 'package:bnood/core/ui/theme/app_theme.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/settings/presentation/screens/more_screen.dart';
import 'package:bnood/features/settings/presentation/widgets/app_menu_body.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthUser extends AuthController {
  @override
  AuthState build() => const AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: User(id: 'u1', phone: '+201012345678', name: 'Osama'),
        bootstrapStarted: true,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMore(WidgetTester tester, {Locale locale = const Locale('ar')}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            AppSettingsSnapshot(
              themeMode: ThemeMode.dark,
              locale: locale,
              prefs: prefs,
            ),
          ),
          authControllerProvider.overrideWith(_AuthUser.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MoreScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('More list scroll padding clears floating dock', (tester) async {
    await pumpMore(tester);
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    final context = tester.element(find.byType(MoreScreen));
    final expectedMin = ShellBottomInset.listScrollBottomPadding(context);
    expect((scroll.padding as EdgeInsets).bottom, expectedMin);
  });

  testWidgets('menu body uses single horizontal gutter on More tab', (tester) async {
    await pumpMore(tester);
    final sections = tester.widgetList<Padding>(
      find.descendant(
        of: find.byType(AppMenuBody),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
        ),
      ),
    );
    expect(sections, isNotEmpty);
    final canvas = tester.widget<BnoodListCanvas>(find.byType(BnoodListCanvas));
    expect(canvas.padding, EdgeInsetsDirectional.zero);
  });

  testWidgets('logout row is reachable by scrolling', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            const AppSettingsSnapshot(
              themeMode: ThemeMode.dark,
              locale: Locale('ar'),
              prefs: null,
            ),
          ),
          authControllerProvider.overrideWith(_AuthUser.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MoreScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(MoreScreen)));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text(l10n.authSignOut), findsOneWidget);
  });
}