import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/layout/app_form_route_canvas.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/overlay_form_presentation.dart';
import '../../../core/widgets/sheet_drag_handle.dart';

/// Inline create route inside voucher / entity pickers.
class InlineEntityCreateShell extends StatelessWidget {
  const InlineEntityCreateShell({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.presentation = OverlayFormPresentation.inSheet,
    this.padForSystemChrome = true,
    this.preferContentHeight = false,
  });

  final String title;
  final Widget body;
  final Widget footer;
  final OverlayFormPresentation presentation;
  final bool padForSystemChrome;
  final bool preferContentHeight;

  @override
  Widget build(BuildContext context) {
    final viewPad = MediaQuery.viewPaddingOf(context);
    final footerBottom = presentation == OverlayFormPresentation.fullScreen
        ? AppSize.spaceMD + viewPad.bottom
        : 0.0;

    if (presentation == OverlayFormPresentation.fullScreen) {
      return AppFormRouteCanvas(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(title: title),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSize.screenPadding,
                    AppSize.spaceMD,
                    AppSize.screenPadding,
                    AppSize.spaceMD,
                  ),
                  child: body,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSize.screenPadding,
                  AppSize.spaceMD,
                  AppSize.screenPadding,
                  footerBottom,
                ),
                child: footer,
              ),
            ],
          ),
        ),
      );
    }

    final colors = context.colors;

    return Material(
      color: colors.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasFiniteMax =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite && constraints.maxHeight > 0;

          final header = Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSize.screenPadding,
              AppSize.spaceSM,
              AppSize.screenPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetDragHandle(),
                AppSize.spaceMD.gap,
                Row(
                  children: [
                    BackButton(onPressed: () => Navigator.maybePop(context)),
                    Expanded(child: Text(title, style: context.text.title)),
                  ],
                ),
              ],
            ),
          );

          final paddedBody = Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
            child: body,
          );
          final scrollBody = SingleChildScrollView(
            padding: EdgeInsets.zero,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: paddedBody,
          );

          final footerPad = Padding(
            padding: EdgeInsets.fromLTRB(
              AppSize.screenPadding,
              AppSize.spaceMD,
              AppSize.screenPadding,
              footerBottom,
            ),
            child: footer,
          );

          if (!hasFiniteMax || preferContentHeight) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                AppSize.spaceMD.gap,
                if (hasFiniteMax) Flexible(child: scrollBody) else paddedBody,
                footerPad,
              ],
            );
          }

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      AppSize.spaceMD.gap,
                      paddedBody,
                    ],
                  ),
                  footerPad,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}