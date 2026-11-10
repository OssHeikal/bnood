import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/items/items_providers.dart';
import 'package:bnood/core/shared/pagination/paged_fetch_page.dart';
import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/items/items_list_paging.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_box.dart';
import 'package:bnood/features/items/widgets/items_loading_skeleton.dart';
import 'package:bnood/features/items/items_screen.dart';
import 'package:bnood/features/items/widgets/item_catalog_tile.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 11, 9);
  final sampleItems = [
    CatalogItem(
      id: '01J',
      name: 'بند اختبار',
      iconKey: 'layers',
      colorKey: 'teal',
      isDefault: false,
      sortOrder: 10,
      createdAt: now,
      updatedAt: now,
    ),
    CatalogItem(
      id: '01K',
      name: 'افتراضي',
      iconKey: 'category',
      colorKey: 'gold',
      isDefault: true,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget wrap({
    required Widget child,
    required List<Override> overrides,
    Locale locale = const Locale('ar'),
    Size size = const Size(390, 844),
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, appChild) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: size,
              padding: itemsScreenMediaQueryForTests(context).copyWith(top: 59),
              viewPadding: itemsScreenMediaQueryForTests(context).copyWith(top: 59),
              disableAnimations: true,
            ),
            child: HomeFoundationScope(child: appChild!),
          );
        },
        home: child,
      ),
    );
  }

  List<Override> remoteOverrides({List<CatalogItem>? items}) {
    return [
      authControllerProvider.overrideWith(() => _AuthStub()),
      remoteItemsEnabledProvider.overrideWith((ref) => true),
      itemsListPageFetcherProvider.overrideWith(
        (ref) => ({required int page, required int pageSize}) async {
          if (page > 1) {
            return const PagedFetchPage(items: [], hasMore: false);
          }
          return PagedFetchPage(items: items ?? sampleItems, hasMore: false);
        },
      ),
      itemIconsCatalogProvider.overrideWith(
        (ref) async => const ItemIconsCatalog(
          colors: [ItemColorOption(key: 'teal', hex: '#0D9B8A')],
          iconKeys: ['category', 'layers'],
        ),
      ),
    ];
  }

  testWidgets('items catalog shows skeleton on first load', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: [
          ...remoteOverrides(),
          itemsListPageFetcherProvider.overrideWith(
            (ref) => ({required int page, required int pageSize}) async {
              await Future<void>.delayed(const Duration(milliseconds: 200));
              return PagedFetchPage(items: sampleItems, hasMore: false);
            },
          ),
        ],
      ),
    );
    await tester.pump();
    expect(find.byType(Skeleton), findsOneWidget);
    expect(find.byType(ItemsLoadingSkeleton), findsOneWidget);
    expect(find.byType(SkeletonBox), findsWidgets);

    final screen = tester.getRect(find.byType(Scaffold));
    final grid = tester.getRect(find.byType(ItemsLoadingSkeleton));
    final card = tester.getRect(find.byType(ItemCatalogTileSkeleton).first);
    const gridInset = AppSize.screenPadding;
    expect(card.top, grid.top);
    expect(screen.right - card.right, gridInset);
    expect(
      tester.getRect(find.text('البنود الافتراضية للقراءة فقط — يمكنك إضافة بنودك')).right,
      screen.right - gridInset,
    );
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.text('بند اختبار'), findsOneWidget);
  });

  testWidgets('catalog grid has horizontal gutter and 24px icons', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: remoteOverrides(),
      ),
    );
    await tester.pumpAndSettle();

    final paged = tester.widget<AppPagedView<CatalogItem>>(find.byType(AppPagedView<CatalogItem>));
    expect(paged.gridPadding?.left, AppSize.screenPadding);
    expect(paged.gridPadding?.right, AppSize.screenPadding);

    final icons = tester.widgetList<SvgPicture>(
      find.descendant(of: find.byType(ItemCatalogTile), matching: find.byType(SvgPicture)),
    );
    expect(icons, isNotEmpty);
    expect(icons.every((icon) => icon.width == AppSize.icon && icon.height == AppSize.icon), isTrue);
  });

  testWidgets('default item shows badge and custom item is tappable', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: remoteOverrides(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('افتراضي'), findsWidgets);
    await tester.tap(find.text('بند اختبار'));
    await tester.pumpAndSettle();
    expect(find.text('تعديل البند'), findsOneWidget);
  });

  testWidgets('create sheet rejects empty name', (tester) async {
    await tester.pumpWidget(
      wrap(
        child: const ItemsScreen(),
        overrides: remoteOverrides(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('items_app_bar_add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pump();
    expect(find.text('اكتب اسم البند'), findsOneWidget);
  });
}

class _AuthStub extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        bootstrapStarted: true,
        user: User(id: 'u1', phone: '+201012345678', name: 'Test'),
      );
}
