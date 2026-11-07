import 'package:flutter/material.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_chevron.dart';
import '../../core/widgets/custom_text_field.dart';

/// Bordered in-label control matching [CustomTextField]; opens picker on tap.
class VoucherSelectorField extends StatelessWidget {
  const VoucherSelectorField({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.placeholder,
    this.enabled = true,
    this.errorMessage,
  });

  final String label;
  final VoidCallback? onTap;
  final String? value;
  final String? placeholder;
  final bool enabled;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final trimmed = value?.trim() ?? '';
    final hasValue = trimmed.isNotEmpty;
    return CustomTextField(
      key: ValueKey('$label|$trimmed|$enabled'),
      initialValue: hasValue ? trimmed : null,
      readOnly: true,
      clearable: false,
      disabled: !enabled,
      onTap: enabled ? onTap : null,
      label: label,
      placeholder: hasValue ? null : (placeholder ?? label),
      fieldHeight: AppSize.fieldHeightComfortable,
      invalid: errorMessage != null,
      errorMessage: errorMessage,
      trailing: enabled ? const AppChevron.forward() : null,
    );
  }
}
