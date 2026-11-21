import 'package:bnood/core/push/notification_settings_record.dart';
import 'package:bnood/features/settings/data/notification_settings_provider.dart';
import 'package:bnood/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('notification settings shows toggle and amount field', (
    tester,
  ) async {
    const record = NotificationSettingsRecord(
      lowBalanceEnabled: true,
      lowBalanceAmountMinor: 1_000_000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationSettingsProvider.overrideWith(
            () => _StaticNotificationSettingsNotifier(record),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Low client balance'), findsOneWidget);
    expect(find.text('10,000 EGP'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
    expect(find.text('All notifications'), findsOneWidget);
  });
}

class _StaticNotificationSettingsNotifier extends NotificationSettingsNotifier {
  _StaticNotificationSettingsNotifier(this._record);

  final NotificationSettingsRecord _record;

  @override
  Future<NotificationSettingsRecord> build() async => _record;
}
