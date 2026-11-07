import 'package:flutter/material.dart';

import '../config/extensions/num_extensions.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import 'buttons/app_button.dart';

enum AppFallbackActionRole { primary, secondary, tertiary }

/// Compact in-section empty/error vs full-screen fallback.
enum AppFallbackScope { screen, section }

class AppFallbackAction {
  const AppFallbackAction({
    required this.label,
    required this.onPressed,
    this.role = AppFallbackActionRole.primary,
    this.icon,
    this.disabled = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppFallbackActionRole role;
  final IconData? icon;
  final bool disabled;
  final bool loading;
}

class AppFallback extends StatelessWidget {
  const AppFallback({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.leading,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actions,
    this.isError = false,
    this.expanded = false,
    this.scope = AppFallbackScope.screen,
  });

  const AppFallback.section({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.leading,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actions,
    this.isError = false,
  })  : expanded = false,
        scope = AppFallbackScope.section;

  final IconData icon;
  final Widget? leading;
  final String title;
  final String? description;

  /// Legacy single primary action (compatible with phase 1 callers).
  final String? actionLabel;
  final VoidCallback? onAction;

  final List<AppFallbackAction>? actions;
  final bool isError;
  final bool expanded;
  final AppFallbackScope scope;

  List<AppFallbackAction> _resolvedActions() {
    if (actions != null && actions!.isNotEmpty) {
      return actions!;
    }
    if (actionLabel != null && onAction != null) {
      return [AppFallbackAction(label: actionLabel!, onPressed: onAction)];
    }
    return const [];
  }

  Widget _actionButton(AppFallbackAction action) {
    final onPressed = action.disabled ? null : action.onPressed;
    final expanded = scope == AppFallbackScope.screen;
    return switch (action.role) {
      AppFallbackActionRole.primary => AppButton.primary(
          text: action.label,
          icon: action.icon,
          onPressed: onPressed,
          isLoading: action.loading,
          isExpanded: expanded,
        ),
      AppFallbackActionRole.secondary => AppButton.outlined(
          text: action.label,
          icon: action.icon,
          onPressed: onPressed,
          isLoading: action.loading,
          isExpanded: expanded,
        ),
      AppFallbackActionRole.tertiary => AppButton.text(
          text: action.label,
          icon: action.icon,
          onPressed: onPressed,
          isLoading: action.loading,
          isExpanded: expanded,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tint = isError ? colors.error : colors.muted;
    final resolved = _resolvedActions();
    final section = scope == AppFallbackScope.section;
    final iconSize = section ? AppSize.icon : AppSize.iconExtraLarge;
    final titleStyle = section ? text.bodyEmphasis : text.sectionTitle;
    final descriptionStyle = section ? text.caption.copyWith(color: colors.onSurfaceMuted) : text.supporting;
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.center,
          child: leading ??
              Icon(icon, size: iconSize, color: tint),
        ),
        AppSize.spaceSM.gap,
        Text(title, style: titleStyle, textAlign: TextAlign.center),
        if (description != null) ...[
          AppSize.spaceXS.gap,
          Text(description!, style: descriptionStyle, textAlign: TextAlign.center),
        ],
        if (resolved.isNotEmpty) ...[
          SizedBox(height: section ? AppSize.spaceMD : AppSize.spaceLG),
          for (var i = 0; i < resolved.length; i++) ...[
            if (i > 0) AppSize.spaceSM.gap,
            if (section)
              Align(alignment: Alignment.center, child: _actionButton(resolved[i]))
            else
              _actionButton(resolved[i]),
          ],
        ],
      ],
    );

    final padded = section ? body : Padding(padding: const EdgeInsets.all(AppSize.spaceLG), child: body);
    if (expanded) {
      return Center(child: padded);
    }
    return padded;
  }
}
