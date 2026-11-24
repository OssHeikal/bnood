import 'package:bnood/features/home/data/craftsman_snapshot_limit.dart';
import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/subscription/data/app_subscription.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/providers/presentation/widgets/remote_craftsman_summary_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

class _SilentSubscriptionNotifier extends SubscriptionNotifier {
  @override
  Future<AppSubscriptionSnapshot?> build() async => null;
}

HomeCraftsmanActivityRow _row(int index) {
  final id = 'c$index';
  final now = DateTime.utc(2026, 1, 1);
  return HomeCraftsmanActivityRow(
    craftsman: CraftsmenData(
      id: id,
      workspaceId: 'w',
      name: 'Craftsman $id',
      phone: '',
      createdAt: now,
      updatedAt: now,
    ),
    paidPiastres: 100,
    lastLaborAt: now,
    remainingPiastres: null,
    clientsCount: 1,
  );
}

void main() {
  test('craftsmanSnapshotRows keeps order and caps at 3', () {
    final source = List.generate(5, (i) => i);
    expect(craftsmanSnapshotRows(source), [0, 1, 2]);
  });

  testWidgets('home shows at most three craftsman cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_AuthUser.new),
          homeTotalsOverride(
            const HomeTotals(receivedPiastres: 0, spentPiastres: 0),
          ),
          homeActiveProjectsOverride(const []),
          homeCraftsmenProvider.overrideWith(
            () => StubHomeCraftsmenNotifier(List.generate(5, _row)),
          ),
          emptyHomeSupplierSpendsOverride(),
          subscriptionProvider.overrideWith(_SilentSubscriptionNotifier.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RemoteCraftsmanSummaryCard), findsNWidgets(3));
  });
}

class _AuthUser extends AuthController {
  @override
  AuthState build() => AuthState(
    bootstrapStatus: AuthBootstrapStatus.authenticated,
    user: const User(id: 'u1', phone: '+201012345678', name: 'Tester'),
    bootstrapStarted: true,
  );
}
