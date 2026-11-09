/// One page of items from a paginated source plus last-page signal from API meta.
class PagedFetchPage<T> {
  const PagedFetchPage({
    required this.items,
    required this.hasMore,
  });

  final List<T> items;
  final bool hasMore;
}

/// Fetches a single page. [page] is the page index/key; [pageSize] is the requested size.
typedef PagedFetchCallback<T> = Future<PagedFetchPage<T>> Function({
  required int page,
  required int pageSize,
});
