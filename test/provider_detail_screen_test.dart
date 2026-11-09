import 'package:bnood/core/agreements/app_agreement_record.dart';
import 'package:bnood/core/agreements/agreements_riverpod.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/core/vouchers/app_voucher_record.dart';
import 'package:bnood/core/vouchers/vouchers_riverpod.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_detail_provider.dart';
import 'package:bnood/features/providers/provider_detail_screen.dart';
import 'package:bnood/features/providers/provider_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubProviderDetailNotifier extends ProviderDetailNotifier {
  _StubProviderDetailNotifier(this.snapshot);

  final ProviderDetailSnapshot snapshot;
  static int openLoads = 0;

  @override
  Future<ProviderDetailSnapshot> build(String arg) async {
    openLoads++;
    return snapshot;
  }

  @override
  Future<ProviderDetailSnapshot> loadSnapshot(String providerId) async {
    openLoads++;
    return snapshot;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _StubProviderDetailNotifier.openLoads = 0;
  });

  testWidgets('craftsman detail omits duplicate type/name card', (tester) async {
    await _pumpCraftsmanDetail(tester, agreements: const []);
    await tester.pumpAndSettle();

    expect(find.text('Type'), findsNothing);
    expect(find.text('Name'), findsNothing);
    expect(find.text('Ali Craftsman'), findsOneWidget);
    expect(find.text('Linked clients'), findsOneWidget);
  });

  testWidgets('craftsman shows agreement totals header and linked client metrics', (tester) async {
    await _pumpCraftsmanDetail(
      tester,
      agreements: [
        ProviderDetailClientRow(
          clientName: 'Client Osama',
          agreement: AppAgreement(
            id: 'ag1',
            clientId: 'c1',
            providerId: '01JCRAFT',
            amountPiastres: null,
            amountMajor: 5,
            paidMajor: 2,
            remainingMajor: 3,
            clientName: 'Client Osama',
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('provider_detail_agreement_totals_header')), findsOneWidget);
    expect(find.byKey(const Key('provider_detail_total_agreed')), findsOneWidget);
    expect(find.byKey(const Key('provider_detail_total_paid')), findsOneWidget);
    expect(find.byKey(const Key('provider_detail_total_remaining')), findsOneWidget);
    expect(find.text('Agreed'), findsWidgets);
    expect(find.text('Paid'), findsWidgets);
    expect(find.text('Remaining'), findsWidgets);
    expect(find.text('Client Osama'), findsOneWidget);
    expect(find.byKey(const Key('provider_detail_edit_agreement_ag1')), findsOneWidget);
    expect(find.byKey(const Key('provider_detail_unlink_ag1')), findsOneWidget);
    expect(find.textContaining('5 EGP'), findsWidgets);
  });

  testWidgets('supplier shows header total without duplicate type card', (tester) async {
    final snapshot = ProviderDetailSnapshot(
      provider: AppProvider(
        id: '01JSUP',
        name: 'Abdel Supplier',
        phone: '+201011111111',
        type: AppProviderType.supplier,
        createdAt: DateTime.utc(2026, 11, 9),
        updatedAt: DateTime.utc(2026, 11, 9),
      ),
      totalVoucherMinor: 1_000_000,
      voucherHistory: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerDetailProvider.overrideWith(() => _StubProviderDetailNotifier(snapshot)),
          remoteVouchersEnabledProvider.overrideWithValue(true),
          remoteAgreementsEnabledProvider.overrideWithValue(true),
          authControllerProvider.overrideWith(_AuthOk.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: ProviderDetailScreen(providerId: '01JSUP'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Type'), findsNothing);
    expect(find.byKey(const Key('provider_detail_supplier_paid_header')), findsOneWidget);
    expect(find.text('Total paid to supplier'), findsOneWidget);
    expect(find.textContaining('10,000'), findsOneWidget);
    expect(find.text('Linked clients'), findsNothing);
  });

  testWidgets('provider movements use client movement card with client subtitle and chips', (tester) async {
    final snapshot = ProviderDetailSnapshot(
      provider: AppProvider(
        id: '01JCRAFT',
        name: 'Ali Craftsman',
        phone: '+201011111111',
        type: AppProviderType.craftsman,
        createdAt: DateTime.utc(2026, 11, 9),
        updatedAt: DateTime.utc(2026, 11, 9),
      ),
      voucherHistory: [
        ProviderDetailVoucherRow(
          clientName: 'Ahmed Client',
          voucher: AppVoucher(
            id: 'v1',
            clientId: 'c99',
            type: 'spend',
            amountMinor: 100_000,
            voucherDate: DateTime.utc(2026, 11, 9),
            method: 'cash',
            expenseClassification: 'labor',
            itemName: 'Plumbing',
            clientName: 'Ahmed Client',
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerDetailProvider.overrideWith(() => _StubProviderDetailNotifier(snapshot)),
          remoteVouchersEnabledProvider.overrideWithValue(true),
          remoteAgreementsEnabledProvider.overrideWithValue(false),
          authControllerProvider.overrideWith(_AuthOk.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: ProviderDetailScreen(providerId: '01JCRAFT'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plumbing'), findsOneWidget);
    expect(find.text('Ahmed Client'), findsOneWidget);
    expect(find.text('Labor'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);
  });

  testWidgets('refetchOnOpen loads details again when screen opens', (tester) async {
    await _pumpCraftsmanDetail(tester, agreements: const []);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(_StubProviderDetailNotifier.openLoads, greaterThanOrEqualTo(2));
  });
}

Future<void> _pumpCraftsmanDetail(
  WidgetTester tester, {
  required List<ProviderDetailClientRow> agreements,
}) async {
  final snapshot = ProviderDetailSnapshot(
    provider: AppProvider(
      id: '01JCRAFT',
      name: 'Ali Craftsman',
      phone: '+201011111111',
      type: AppProviderType.craftsman,
      createdAt: DateTime.utc(2026, 11, 9),
      updatedAt: DateTime.utc(2026, 11, 9),
    ),
    clientAgreements: agreements,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        providerDetailProvider.overrideWith(() => _StubProviderDetailNotifier(snapshot)),
        remoteVouchersEnabledProvider.overrideWithValue(false),
        remoteAgreementsEnabledProvider.overrideWithValue(true),
        authControllerProvider.overrideWith(_AuthOk.new),
      ],
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeFoundationScope(
          child: ProviderDetailScreen(providerId: '01JCRAFT'),
        ),
      ),
    ),
  );
}

class _AuthOk extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(
        id: 'u1',
        phone: '+201000000001',
        name: 'Osama',
      ),
      bootstrapStarted: true,
    );
  }
}
