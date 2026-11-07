import 'package:flutter/material.dart';

import '../config/extensions/num_extensions.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import 'buttons/app_button.dart';

enum AppFallbackActionRole { primary, secondary, tertiary }

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
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.actions,
    this.isError = false,
    this.expanded = false,
  });

  final IconData icon;
  final String title;
  final String? description;

  /// Legacy single primary action (compatible with phase 1 callers).
  final String? actionLabel;
  final VoidCallback? onAction;

  final List<AppFallbackAction>? actions;
  final bool isError;
  final bool expanded;

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
    return switch (action.role) {
      AppFallbackActionRole.primary => AppButton.primary(
          text: action.label,
          icon: action.icon,
          onPressed: onPressed,
          isLoading: action.loading,
          isExpanded: true,
        ),
      AppFallbackActionRole.secondary => AppButton.outlined(
          text: action.label,
          icon: action.icon,
          onPressed: onPressed,
          isLoading: action.loading,
          isExpanded: true,
        ),
      AppFallbackActionRole.tertiary => AppButton.text(
          text: action.label,
          icon: action.icon,
          onPressed: onPressed,
          isLoading: action.loading,
          isExpanded: true,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tint = isError ? colors.error : colors.muted;
    final resolved = _resolvedActions();
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: AppSize.iconExtraLarge, color: tint),
        AppSize.spaceMD.gap,
        Text(title, style: text.sectionTitle, textAlign: TextAlign.center),
        if (description != null) ...[
          AppSize.spaceSM.gap,
          Text(description!, style: text.supporting, textAlign: TextAlign.center),
        ],
        if (resolved.isNotEmpty) ...[
          AppSize.spaceLG.gap,
          for (var i = 0; i < resolved.length; i++) ...[
            if (i > 0) AppSize.spaceSM.gap,
            _actionButton(resolved[i]),
          ],
        ],
      ],
    );

    final padded = Padding(padding: const EdgeInsets.all(AppSize.spaceLG), child: body);
    if (expanded) {
      return Center(child: padded);
    }
    return padded;
  }
}
