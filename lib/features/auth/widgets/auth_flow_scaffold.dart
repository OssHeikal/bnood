import 'package:flutter/material.dart';

import '../../../core/brand/app_brand_lockup.dart';
import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../home/home_foundation_scope.dart';

/// Body-only auth shell: empty app bar, keyboard-safe scroll, no pinned footer chrome.
enum AuthFlowAlignment { start, center }

class AuthFlowScaffold extends StatelessWidget {
  const AuthFlowScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.alignment = AuthFlowAlignment.start,
    this.showLogo = false,
    this.logoHeight = 140,
  });

  final String? title;
  final String? subtitle;
  final Widget child;
  final AuthFlowAlignment alignment;
  final bool showLogo;
  final double logoHeight;

  TextAlign get _textAlign => alignment == AuthFlowAlignment.center ? TextAlign.center : TextAlign.start;

  CrossAxisAlignment get _crossAxis =>
      alignment == AuthFlowAlignment.center ? CrossAxisAlignment.center : CrossAxisAlignment.stretch;

  @override
  Widget build(BuildContext context) {
    final insetBottom = MediaQuery.viewInsetsOf(context).bottom;
    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            appBar: AppBar(backgroundColor: colors.canvas),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSize.screenPadding,
                  AppSize.spaceLG,
                  AppSize.screenPadding,
                  AppSize.spaceLG + insetBottom,
                ),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: _crossAxis,
                  children: [
                    if (showLogo) ...[
                      AppSize.space2XL.gap,
                      AppBrandLockup(kind: AppBrandLockupKind.vertical, height: logoHeight),
                    ],
                    if (title != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Text(title!, style: context.text.pageTitle, textAlign: _textAlign),
                      ),
                      AppSize.spaceSM.gap,
                    ],
                    if (subtitle != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Text(subtitle!, style: context.text.supporting, textAlign: _textAlign),
                      ),
                      AppSize.spaceLG.gap,
                    ],
                    SizedBox(width: double.infinity, child: child),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
