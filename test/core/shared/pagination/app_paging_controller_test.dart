import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPagingController', () {
    test('stops after hasMore false', () async {
      var calls = 0;
      final controller = AppPagingController<String>(
        pageSize: 2,
        fetchPage: ({required int page, required int pageSize}) async {
          calls++;
          if (page == 1) {
            return PagedFetchPage(
              items: List.generate(pageSize, (i) => 'p1-$i'),
              hasMore: true,
            );
          }
          return const PagedFetchPage(items: ['last'], hasMore: false);
        },
      );
      addTearDown(controller.dispose);

      for (var i = 0; i < 2; i++) {
        controller.pagingController.fetchNextPage();
        await pumpEventQueue(times: 8);
      }

      expect(controller.items, ['p1-0', 'p1-1', 'last']);
      expect(calls, 2);

      controller.pagingController.fetchNextPage();
      await pumpEventQueue(times: 4);
      expect(calls, 2);
      expect(controller.hasNextPage, isFalse);
    });

    test('refresh resets and loads first page again', () async {
      var generation = 0;
      final controller = AppPagingController<String>(
        fetchPage: ({required int page, required int pageSize}) async {
          generation++;
          if (page > 1) return const PagedFetchPage(items: [], hasMore: false);
          return PagedFetchPage(items: ['v$generation'], hasMore: false);
        },
      );
      addTearDown(controller.dispose);

      controller.pagingController.fetchNextPage();
      await pumpEventQueue(times: 4);
      expect(controller.items, ['v1']);

      controller.refresh();
      controller.pagingController.fetchNextPage();
      await pumpEventQueue(times: 4);
      expect(controller.items, ['v2']);
    });

    test('surfaces first-page error', () async {
      final controller = AppPagingController<String>(
        fetchPage: ({required int page, required int pageSize}) async {
          throw Exception('network');
        },
      );
      addTearDown(controller.dispose);

      controller.pagingController.fetchNextPage();
      await pumpEventQueue(times: 4);

      expect(controller.error, isNotNull);
      expect(controller.items, isNull);
    });
  });
}
