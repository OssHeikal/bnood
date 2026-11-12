import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'paged_fetch_page.dart';

/// v5 [PagingController] with API `hasMore` metadata (non-empty last pages).
class AppPagingController<T> {
  AppPagingController({required PagedFetchCallback<T> fetchPage, this.firstPageKey = 1, this.pageSize = 20})
    : _fetchPage = fetchPage {
    pagingController = PagingController<int, T>(
      getNextPageKey: (state) {
        if (!_hasMore) return null;
        if (state.lastPageIsEmpty) return null;
        if (state.keys == null || state.keys!.isEmpty) {
          return firstPageKey;
        }
        return state.nextIntPageKey;
      },
      fetchPage: (pageKey) async {
        final result = await _fetchPage(page: pageKey, pageSize: pageSize);
        _hasMore = result.hasMore;
        return result.items;
      },
    );
  }

  final PagedFetchCallback<T> _fetchPage;
  final int firstPageKey;
  final int pageSize;

  bool _hasMore = true;

  late final PagingController<int, T> pagingController;

  PagingState<int, T> get state => pagingController.value;

  List<T>? get items => pagingController.items;

  Object? get error => pagingController.error;

  bool get hasNextPage => pagingController.hasNextPage;

  void refresh() {
    _hasMore = true;
    pagingController.refresh();
  }

  void dispose() => pagingController.dispose();
}
