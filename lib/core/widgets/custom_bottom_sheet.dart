import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import '../../features/home/home_foundation_scope.dart';

/// Root bottom sheet with nested [Navigator] for inline-create flows.
class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
  });

  final Widget child;
  final String? title;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    bool useRootNavigator = true,
    bool nestedNavigator = true,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colors.surface,
      shape: AppShape.superellipse(radius: AppSize.radiusLG),
      builder: (ctx) {
        final insets = MediaQuery.viewInsetsOf(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: CustomBottomSheet(
            title: title,
            child: nestedNavigator
                ? _BoundedSheetNavigator(builder: builder)
                : Builder(builder: builder),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSize.screenPadding,
                      0,
                      AppSize.screenPadding,
                      AppSize.spaceSM,
                    ),
                    child: Text(title!, style: context.text.titleLarge),
                  ),
                ],
                child,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Nested [Navigator] needs finite max height inside content-sized sheet (Overlay sizing).
class _BoundedSheetNavigator extends StatelessWidget {
  const _BoundedSheetNavigator({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final maxHeight = _navigatorMaxHeight(constraints, media);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: maxHeight,
          ),
          child: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(builder: builder),
          ),
        );
      },
    );
  }

  static double _navigatorMaxHeight(BoxConstraints constraints, MediaQueryData media) {
    final reservedTop = media.viewPadding.top + AppSize.space2XL;
    final viewportCap = media.size.height - reservedTop;
    final parent = constraints.maxHeight;
    if (!parent.isFinite) {
      return viewportCap;
    }
    return parent < viewportCap ? parent : viewportCap;
  }
}
