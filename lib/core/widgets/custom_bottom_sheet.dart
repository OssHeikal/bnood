import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_shape.dart';
import '../config/theme/app_size.dart';
import '../../features/home/home_foundation_scope.dart';
import 'bounded_sheet_navigator.dart';

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
    bool showDragHandle = true,
  }) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      showDragHandle: showDragHandle,
      backgroundColor: colors.surface,
      shape: AppShape.superellipse(radius: AppSize.radiusLG),
      builder: (ctx) {
        final insets = MediaQuery.viewInsetsOf(ctx);
        final keyboardGap = insets.bottom > 0 ? AppSize.spaceMD : 0.0;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom > 0 ? insets.bottom + keyboardGap : 0),
          child: CustomBottomSheet(
            title: title,
            child: nestedNavigator
                ? BoundedSheetNavigator(builder: builder)
                : _BoundedStandaloneChild(builder: builder),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight =
                    SheetContentBounds.maxHeight(constraints, MediaQuery.of(context));
                return SizedBox(
                  height: maxHeight,
                  child: Column(
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
                      Expanded(child: child),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BoundedStandaloneChild extends StatelessWidget {
  const _BoundedStandaloneChild({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = SheetContentBounds.maxHeight(constraints, MediaQuery.of(context));
        return SizedBox(
          height: maxHeight,
          width: constraints.maxWidth,
          child: Builder(builder: builder),
        );
      },
    );
  }
}
