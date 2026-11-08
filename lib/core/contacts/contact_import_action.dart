import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/buttons/app_button.dart';
import 'device_contact_import.dart';

/// Full-width optional import from device contacts for create forms.
class ContactImportAction extends StatefulWidget {
  const ContactImportAction({
    super.key,
    required this.nameController,
    required this.phoneController,
    this.enabled = true,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool enabled;

  @override
  State<ContactImportAction> createState() => _ContactImportActionState();
}

class _ContactImportActionState extends State<ContactImportAction> {
  var _busy = false;

  Future<void> _pick() async {
    if (!widget.enabled || _busy) return;
    setState(() => _busy = true);
    try {
      final fields = await DeviceContactPicker.pick(context);
      if (fields == null || !mounted) return;
      applyDeviceContactFields(
        name: widget.nameController,
        phone: widget.phoneController,
        fields: fields,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppButton.outlined(
      text: l10n.pickFromContacts,
      isLoading: _busy,
      isExpanded: true,
      followDirectionality: true,
      icon: Icons.contacts_outlined,
      onPressed: widget.enabled && !_busy ? _pick : null,
    );
  }
}
