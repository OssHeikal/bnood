import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/core/ui/theme/app_theme.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/settings/presentation/screens/more_screen.dart';
import 'package:bnood/features/subscription/data/app_subscription.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DisabledSubscription extends SubscriptionNotifier {
  @override
  Future<AppSubscriptionSnapshot?> build() async =>
      AppSubscriptionSnapshot.fromDataJson({
        'paywall_enabled': false,
        'entitlements': {'show_paywall_surfaces': false},
      });
}

class _AuthUser extends AuthController {
  @override
  AuthState build() => const AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: User(id: 'u1', phone: '+201012345678', name: 'Osama Home'),
        bootstrapStarted: true,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('more screen dark AR scrolled to bottom golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            AppSettingsSnapshot(
              themeMode: ThemeMode.dark,
              locale: const Locale('ar'),
              prefs: prefs,
            ),
          ),
          authControllerProvider.overrideWith(_AuthUser.new),
          subscriptionProvider.overrideWith(_DisabledSubscription.new),
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
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1600));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MoreScreen),
      matchesGoldenFile('goldens/more_screen_dark_ar_bottom.png'),
    );
  });
}