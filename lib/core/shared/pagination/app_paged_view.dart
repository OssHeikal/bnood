import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../config/theme/app_size.dart';
import 'app_paged_builders.dart';
import 'app_paging_controller.dart';

enum AppPagedLayout { list, listSeparated, sliverList, sliverListSeparated, sliverGrid }

class AppPagedView<T> extends StatelessWidget {
  AppPagedView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    AppPagedBuilders<T>? builders,
    this.layout = AppPagedLayout.sliverListSeparated,
    this.separatorBuilder,
    this.itemPadding,
    this.pullToRefresh = false,
    this.refreshEdgeOffset = 0,
    this.scrollPhysics,
    this.sliverHeaders = const [],
    this.sliverFooters = const [],
    this.gridPadding,
    this.shrinkWrapFirstPageIndicators = true,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: AppSize.spaceMD,
      mainAxisSpacing: AppSize.spaceMD,
      mainAxisExtent: 116,
    ),
  }) : builders = builders ?? AppPagedBuilders<T>();

  final AppPagingController<T> controller;
  final ItemWidgetBuilder<T> itemBuilder;
  final AppPagedBuilders<T> builders;
  final AppPagedLayout layout;
  final SliverGridDelegate gridDelegate;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsets Function(int index)? itemPadding;
  final bool pullToRefresh;
  final double refreshEdgeOffset;
  final ScrollPhysics? scrollPhysics;
  final List<Widget> sliverHeaders;
  final List<Widget> sliverFooters;
  final EdgeInsets? gridPadding;
  final bool shrinkWrapFirstPageIndicators;

  Future<void> _onRefresh() async {
    controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final content = PagingListener<int, T>(
      controller: controller.pagingController,
      builder: (context, state, fetchNextPage) {
        Widget builtItem(BuildContext context, T item, int index) {
          final child = itemBuilder(context, item, index);
          final padding = itemPadding?.call(index);
          if (padding == null) return child;
          return Padding(padding: padding, child: child);
        }

        final delegate = builders.toDelegate(
          context: context,
          itemBuilder: builtItem,
          onRefresh: controller.refresh,
          fetchNextPage: fetchNextPage,
          state: state,
        );

        return switch (layout) {
          AppPagedLayout.list => PagedListView<int, T>(
            state: state,
            fetchNextPage: fetchNextPage,
            physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
            builderDelegate: delegate,
          ),
          AppPagedLayout.listSeparated => PagedListView<int, T>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
            builderDelegate: delegate,
            separatorBuilder: separatorBuilder ?? (_, _) => const SizedBox(height: AppSize.spaceMD),
          ),
          AppPagedLayout.sliverList => CustomScrollView(
            physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
            slivers: [
              ...sliverHeaders,
              PagedSliverList<int, T>(
                state: state,
                fetchNextPage: fetchNextPage,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                builderDelegate: delegate,
              ),
              ...sliverFooters,
            ],
          ),
          AppPagedLayout.sliverListSeparated => CustomScrollView(
            physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
            slivers: [
              ...sliverHeaders,
              PagedSliverList<int, T>.separated(
                state: state,
                fetchNextPage: fetchNextPage,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                builderDelegate: delegate,
                separatorBuilder: separatorBuilder ?? (_, _) => const SizedBox(height: AppSize.spaceMD),
              ),
              ...sliverFooters,
            ],
          ),
          AppPagedLayout.sliverGrid => CustomScrollView(
            physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
            slivers: [
              ...sliverHeaders,
              if (gridPadding != null)
                SliverPadding(
                  padding: gridPadding!,
                  sliver: PagedSliverGrid<int, T>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                    gridDelegate: gridDelegate,
                    builderDelegate: delegate,
                  ),
                )
              else
                PagedSliverGrid<int, T>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                  gridDelegate: gridDelegate,
                  builderDelegate: delegate,
                ),
              ...sliverFooters,
            ],
          ),
        };
      },
    );

    if (!pullToRefresh) return content;

    return RefreshIndicator.adaptive(edgeOffset: refreshEdgeOffset, onRefresh: _onRefresh, child: content);
  }
}
