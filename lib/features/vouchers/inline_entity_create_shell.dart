import 'package:flutter/material.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/sheet_drag_handle.dart';

/// Content-sized inline create route inside voucher / entity pickers.
class InlineEntityCreateShell extends StatelessWidget {
  const InlineEntityCreateShell({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.padForSystemChrome = true,
    this.preferContentHeight = false,
  });

  final String title;
  final Widget body;
  final Widget footer;
  final bool padForSystemChrome;
  final bool preferContentHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);
    final viewPadding = media.viewPadding;

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
              child: paddedBody,
            );

            final footerBottom = padForSystemChrome ? viewPadding.bottom : 0.0;
            final footerPad = Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceMD,
                AppSize.screenPadding,
                AppSize.spaceMD + footerBottom,
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
                  paddedBody,
                  footerPad,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                AppSize.spaceMD.gap,
                Expanded(child: scrollBody),
                footerPad,
              ],
            );
          },
        ),
    );
  }
}
