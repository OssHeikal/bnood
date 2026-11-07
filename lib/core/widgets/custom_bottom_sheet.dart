import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import '../../features/home/home_foundation_scope.dart';
import 'bnood_modal_sheet.dart';
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
    return BnoodModalSheet.show<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (ctx) => CustomBottomSheet(
        title: title,
        child: nestedNavigator
            ? BoundedSheetNavigator(builder: builder)
            : _BoundedStandaloneChild(builder: builder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight =
                  SheetContentBounds.maxHeight(constraints, MediaQuery.of(context));
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
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
                    Flexible(
                      fit: FlexFit.loose,
                      child: child,
                    ),
                  ],
                ),
              );
            },
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
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: constraints.maxWidth,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Builder(builder: builder),
          ),
        );
      },
    );
  }
}
