import 'package:flutter/material.dart';

import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/app_layout.dart';

/// Phone-only project detail: scroll-away summary header + pinned [TabBar].
class ProjectDetailPhoneLayout extends StatelessWidget {
  const ProjectDetailPhoneLayout({
    super.key,
    required this.headerChildren,
    required this.tabLabels,
    required this.itemsTab,
    required this.craftsmenTab,
    required this.suppliersTab,
    required this.movementsTab,
  });

  final List<Widget> headerChildren;
  final List<String> tabLabels;
  final Widget itemsTab;
  final Widget craftsmenTab;
  final Widget suppliersTab;
  final Widget movementsTab;

  static const tabBarHeight = AppSize.fieldHeight;

  @override
  Widget build(BuildContext context) {
    assert(tabLabels.length == 4, 'Expected 4 tab labels');
    final colors = context.colors;
    final textTheme = context.text;
    final gutter = context.pageGutter;
    const dividerHeight = 1.0;
    final barBodyHeight = tabBarHeight - dividerHeight;

    return DefaultTabController(
      length: 4,
      child: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(gutter, 0, gutter, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: headerChildren,
                ),
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedTabBarHeader(
                  height: tabBarHeight,
                  child: ColoredBox(
                    color: colors.canvas,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: barBodyHeight,
                          child: TabBar(
                            isScrollable: false,
                            tabAlignment: TabAlignment.fill,
                            dividerHeight: 0,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorWeight: 3,
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: WidgetStateProperty.all(
                              colors.primary.withValues(alpha: 0.08),
                            ),
                            indicatorColor: colors.primary,
                            labelColor: colors.primaryDark,
                            unselectedLabelColor: colors.onSurfaceMuted,
                            labelStyle: textTheme.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            unselectedLabelStyle: textTheme.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            tabs: [
                              for (final label in tabLabels) Tab(text: label),
                            ],
                          ),
                        ),
                        Divider(
                          height: dividerHeight,
                          thickness: dividerHeight,
                          color: colors.outlineSubtle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _ProjectDetailTabScroll(
              storageKey: 'project_detail_tab_items',
              horizontalGutter: gutter,
              child: itemsTab,
            ),
            _ProjectDetailTabScroll(
              storageKey: 'project_detail_tab_craftsmen',
              horizontalGutter: gutter,
              child: craftsmenTab,
            ),
            _ProjectDetailTabScroll(
              storageKey: 'project_detail_tab_suppliers',
              horizontalGutter: gutter,
              child: suppliersTab,
            ),
            _ProjectDetailTabScroll(
              storageKey: 'project_detail_tab_movements',
              horizontalGutter: gutter,
              child: movementsTab,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectDetailTabScroll extends StatelessWidget {
  const _ProjectDetailTabScroll({
    required this.storageKey,
    required this.horizontalGutter,
    required this.child,
  });

  final String storageKey;
  final double horizontalGutter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Builder(
      builder: (context) {
        return CustomScrollView(
          key: PageStorageKey<String>(storageKey),
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(
                horizontalGutter,
                AppSize.spaceMD,
                horizontalGutter,
                AppSize.spaceMD + bottom,
              ),
              sliver: SliverToBoxAdapter(child: child),
            ),
          ],
        );
      },
    );
  }
}

class _PinnedTabBarHeader extends SliverPersistentHeaderDelegate {
  _PinnedTabBarHeader({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarHeader oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}