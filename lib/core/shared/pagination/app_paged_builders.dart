import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../config/theme/app_size.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_fallback.dart';
import '../../widgets/skeleton/paged_list_skeleton.dart';
import '../../../l10n/app_localizations.dart';

/// Optional overrides for indicator builders on [AppPagedView].
class AppPagedBuilders<T> {
  const AppPagedBuilders({
    this.firstPageProgress,
    this.newPageProgress,
    this.firstPageError,
    this.newPageError,
    this.empty,
    this.noMoreItems,
    this.invisibleItemsThreshold = 4,
    this.firstPageSkeletonCount = 4,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
  });

  final Widget Function(BuildContext context, PagingState<int, T> state)? firstPageProgress;
  final WidgetBuilder? newPageProgress;
  final Widget Function(BuildContext context, PagingState<int, T> state, VoidCallback retry)? firstPageError;
  final Widget Function(BuildContext context, PagingState<int, T> state, VoidCallback retry)? newPageError;
  final WidgetBuilder? empty;
  final WidgetBuilder? noMoreItems;
  final int invisibleItemsThreshold;
  final int firstPageSkeletonCount;
  final EdgeInsets contentPadding;

  PagedChildBuilderDelegate<T> toDelegate({
    required BuildContext context,
    required ItemWidgetBuilder<T> itemBuilder,
    required VoidCallback onRefresh,
    required NextPageCallback fetchNextPage,
    required PagingState<int, T> state,
  }) {
    final l10n = AppLocalizations.of(context);

    Widget padded(Widget child, {bool topSpacing = true}) {
      return Padding(
        padding: contentPadding.copyWith(top: topSpacing ? AppSize.spaceSM : 0),
        child: child,
      );
    }

    return PagedChildBuilderDelegate<T>(
      invisibleItemsThreshold: invisibleItemsThreshold,
      itemBuilder: itemBuilder,
      firstPageProgressIndicatorBuilder: (ctx) {
        if (state.items?.isNotEmpty == true) return const SizedBox.shrink();
        if (firstPageProgress != null) {
          return padded(firstPageProgress!(ctx, state));
        }
        return padded(
          PagedListSkeleton(count: firstPageSkeletonCount),
        );
      },
      newPageProgressIndicatorBuilder: (ctx) {
        if (newPageProgress != null) return padded(newPageProgress!(ctx), topSpacing: false);
        return padded(
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSize.spaceMD),
              child: SizedBox(
                width: AppSize.icon,
                height: AppSize.icon,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          topSpacing: false,
        );
      },
      firstPageErrorIndicatorBuilder: (ctx) {
        if (firstPageError != null) {
          return padded(firstPageError!(ctx, state, onRefresh));
        }
        return padded(
          AppCard(
            child: AppFallback.section(
              icon: Icons.error_outline,
              title: l10n.homeLoadErrorTitle,
              description: state.error?.toString() ?? l10n.homeLoadErrorTitle,
              actions: [
                AppFallbackAction(
                  label: l10n.retry,
                  onPressed: onRefresh,
                  role: AppFallbackActionRole.tertiary,
                ),
              ],
            ),
          ),
        );
      },
      newPageErrorIndicatorBuilder: (ctx) {
        if (newPageError != null) {
          return padded(newPageError!(ctx, state, fetchNextPage), topSpacing: false);
        }
        return padded(
          AppCard(
            child: AppFallback.section(
              icon: Icons.error_outline,
              title: l10n.homeLoadErrorTitle,
              description: state.error?.toString() ?? l10n.homeLoadErrorTitle,
              actions: [
                AppFallbackAction(
                  label: l10n.retry,
                  onPressed: fetchNextPage,
                  role: AppFallbackActionRole.tertiary,
                ),
              ],
            ),
          ),
          topSpacing: false,
        );
      },
      noItemsFoundIndicatorBuilder: (ctx) {
        if (empty != null) return padded(empty!(ctx));
        return padded(
          AppFallback.section(
            icon: Icons.inbox_outlined,
            title: l10n.homeNoActiveClientsTitle,
            description: l10n.homeNoActiveClientsDescription,
          ),
        );
      },
      noMoreItemsIndicatorBuilder: noMoreItems != null
          ? (ctx) => Padding(
                padding: contentPadding.copyWith(bottom: AppSize.spaceMD),
                child: noMoreItems!(ctx),
              )
          : null,
    );
  }
}
