import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/core/agreements/agreements_riverpod.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/core/vouchers/vouchers_riverpod.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_detail_provider.dart';
import 'package:bnood/features/providers/provider_detail_screen.dart';
import 'package:bnood/features/providers/provider_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Stub extends ProviderDetailNotifier {
  _Stub(this.snapshot);
  final ProviderDetailSnapshot snapshot;

  @override
  Future<ProviderDetailSnapshot> build(String arg) async => snapshot;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AR RTL stacks label and amount on the same start edge in total cards', (tester) async {
    final snapshot = ProviderDetailSnapshot(
      provider: AppProvider(
        id: '01JCRAFT',
        name: 'صنايعي',
        phone: null,
        type: AppProviderType.craftsman,
        createdAt: DateTime.utc(2026, 11, 9),
        updatedAt: DateTime.utc(2026, 11, 9),
      ),
      clientAgreements: [
        ProviderDetailClientRow(
          clientName: 'عميل',
          agreement: AppAgreement(
            id: 'a1',
            clientId: 'c1',
            providerId: '01JCRAFT',
            amountPiastres: null,
            amountMajor: 15,
            paidMajor: 3,
            remainingMajor: 12,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerDetailProvider.overrideWith(() => _Stub(snapshot)),
          remoteVouchersEnabledProvider.overrideWithValue(false),
          remoteAgreementsEnabledProvider.overrideWithValue(true),
          authControllerProvider.overrideWith(_AuthOk.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: ProviderDetailScreen(providerId: '01JCRAFT'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final paidCard = find.byKey(const Key('provider_detail_total_paid'));
    _expectLabelAndAmountShareStartEdge(
      tester,
      label: find.descendant(of: paidCard, matching: find.text('مدفوع')),
      amount: find.descendant(of: paidCard, matching: find.textContaining('EGP')),
      card: paidCard,
    );
  });

  testWidgets('AR RTL supplier paid header stacks label and amount on start edge', (tester) async {
    final snapshot = ProviderDetailSnapshot(
      provider: AppProvider(
        id: '01JSUP',
        name: 'مورد',
        phone: null,
        type: AppProviderType.supplier,
        createdAt: DateTime.utc(2026, 11, 9),
        updatedAt: DateTime.utc(2026, 11, 9),
      ),
      totalVoucherMinor: 1_000_000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerDetailProvider.overrideWith(() => _Stub(snapshot)),
          remoteVouchersEnabledProvider.overrideWithValue(false),
          remoteAgreementsEnabledProvider.overrideWithValue(false),
          authControllerProvider.overrideWith(_AuthOk.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: ProviderDetailScreen(providerId: '01JSUP'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final header = find.byKey(const Key('provider_detail_supplier_paid_header'));
    _expectLabelAndAmountShareStartEdge(
      tester,
      label: find.descendant(of: header, matching: find.textContaining('إجمالي')),
      amount: find.descendant(of: header, matching: find.textContaining('10,000')),
      card: header,
    );
  });
}

void _expectLabelAndAmountShareStartEdge(
  WidgetTester tester, {
  required Finder label,
  required Finder amount,
  required Finder card,
}) {
  final cardRect = tester.getRect(card.first);
  final labelRect = tester.getRect(label.first);
  final amountRect = tester.getRect(amount.first);

  final labelStartEdge = labelRect.right;
  final amountStartEdge = amountRect.right;
  expect((labelStartEdge - amountStartEdge).abs(), lessThan(8));

  final insetFromCardStart = cardRect.right - labelStartEdge;
  expect(insetFromCardStart, greaterThan(0));
  expect(insetFromCardStart, lessThan(cardRect.width * 0.4));

  expect(amountRect.left, greaterThan(cardRect.left + cardRect.width * 0.35));
}

class _AuthOk extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(id: 'u1', phone: '+201000000001', name: 'Osama'),
      bootstrapStarted: true,
    );
  }
}
