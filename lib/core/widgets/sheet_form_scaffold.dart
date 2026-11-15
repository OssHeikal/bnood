import 'package:flutter/material.dart';

import '../config/theme/app_size.dart';
import 'bounded_sheet_navigator.dart';

/// Scrollable sheet body with an optional pinned footer that stays above the keyboard.
class SheetFormScaffold extends StatelessWidget {
  const SheetFormScaffold({
    super.key,
    required this.padding,
    required this.scrollChild,
    this.footer,
    this.header,
  });

  final EdgeInsets padding;
  final Widget scrollChild;
  final Widget? footer;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final maxHeight = SheetContentBounds.maxHeight(constraints, media);
        final footerBottom = SheetChromeInsets.sheetFooterBottomPadding(
          media: media,
          outerModalChromeApplied: true,
        );

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?header,
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: padding,
                  child: scrollChild,
                ),
              ),
              if (footer != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppSize.spaceMD,
                    padding.right,
                    footerBottom,
                  ),
                  child: footer,
                ),
            ],
          ),
        );
      },
    );
  }
}