import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive, outlined, text, success, warning }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)]);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: onPressed, child: child),
      AppButtonVariant.secondary => FilledButton.tonal(onPressed: onPressed, child: child),
      AppButtonVariant.destructive => FilledButton(
        style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(onPressed: onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: onPressed, child: child),
      AppButtonVariant.success => FilledButton(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1B9E5A)),
        onPressed: onPressed,
        child: child,
      ),
      AppButtonVariant.warning => FilledButton(
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE6A23C)),
        onPressed: onPressed,
        child: child,
      ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
