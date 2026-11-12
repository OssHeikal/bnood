import 'dart:async';

import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/core/widgets/skeleton/paged_list_skeleton.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first load shows default skeleton then items', (tester) async {
    final gate = Completer<PagedFetchPage<String>>();
    addTearDown(() {
      if (!gate.isCompleted) {
        gate.complete(const PagedFetchPage(items: [], hasMore: false));
      }
    });

    final paging = AppPagingController<String>(
      fetchPage: ({required int page, required int pageSize}) => gate.future,
    );
    addTearDown(paging.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppPagedView<String>(
          controller: paging,
          itemBuilder: (context, item, index) => Text(item),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(PagedListSkeleton), findsOneWidget);

    gate.complete(const PagedFetchPage(items: ['one'], hasMore: false));
    await tester.pumpAndSettle();
    expect(find.text('one'), findsOneWidget);
    expect(find.byType(PagedListSkeleton), findsNothing);
  });

  testWidgets('first-page error shows retry', (tester) async {
    var attempt = 0;
    final paging = AppPagingController<String>(
      fetchPage: ({required int page, required int pageSize}) async {
        attempt++;
        if (attempt == 1) throw Exception('fail');
        return const PagedFetchPage(items: ['ok'], hasMore: false);
      },
    );
    addTearDown(paging.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppPagedView<String>(
          controller: paging,
          itemBuilder: (context, item, index) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('ok'), findsOneWidget);
  });

  testWidgets('refresh reloads first page', (tester) async {
    var generation = 0;
    final paging = AppPagingController<String>(
      fetchPage: ({required int page, required int pageSize}) async {
        generation++;
        return PagedFetchPage(items: ['item$generation'], hasMore: false);
      },
    );
    addTearDown(paging.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppPagedView<String>(
          controller: paging,
          itemBuilder: (context, item, index) => Text(item),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('item1'), findsOneWidget);

    paging.refresh();
    await tester.pumpAndSettle();
    expect(find.text('item2'), findsOneWidget);
  });
}
