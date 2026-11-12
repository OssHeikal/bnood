import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';

import '../formatting/display_digits.dart';
import '../layout/bnood_layout.dart';
import '../widgets/app_toaster.dart';
import '../../l10n/app_localizations.dart';

class DeviceContactFields {
  const DeviceContactFields({this.name, this.phone});

  final String? name;
  final String? phone;
}

/// Applies a contact pick into create form fields without clearing existing values with blanks.
void applyDeviceContactFields({
  required TextEditingController name,
  required TextEditingController phone,
  required DeviceContactFields fields,
}) {
  final pickedName = fields.name?.trim();
  if (pickedName != null && pickedName.isNotEmpty) {
    name.text = pickedName;
  }
  final pickedPhone = fields.phone?.trim();
  if (pickedPhone != null && pickedPhone.isNotEmpty) {
    phone.text = DisplayDigits.toWesternDigits(pickedPhone);
  }
}

/// Resolve phone when native picker returned multiple numbers without a single selection.
String? resolveContactPhoneForImport(Contact contact) {
  final selected = contact.selectedPhoneNumber?.trim();
  if (selected != null && selected.isNotEmpty) {
    return selected;
  }
  final numbers = contact.phoneNumbers?.map((p) => p.trim()).where((p) => p.isNotEmpty).toList() ?? [];
  if (numbers.length == 1) return numbers.first;
  return null;
}

List<String> contactPhoneChoices(Contact contact) {
  return contact.phoneNumbers?.map((p) => p.trim()).where((p) => p.isNotEmpty).toList() ?? [];
}

abstract final class DeviceContactPicker {
  static final _native = FlutterNativeContactPicker();
  static var _picking = false;

  @visibleForTesting
  static Future<Contact?> Function()? pickOverride;

  static Future<DeviceContactFields?> pick(BuildContext context) async {
    if (_picking) return null;
    _picking = true;
    try {
      final l10n = AppLocalizations.of(context);
      final Contact? contact = await (pickOverride ?? () => _native.selectPhoneNumber())();
      if (contact == null) return null;

      var phone = resolveContactPhoneForImport(contact);
      final choices = contactPhoneChoices(contact);
      if (phone == null && choices.length > 1) {
        if (!context.mounted) return null;
        phone = await _choosePhone(context, choices, l10n);
        if (phone == null) return null;
      }

      return DeviceContactFields(
        name: contact.fullName?.trim(),
        phone: phone?.trim().isNotEmpty == true ? phone : null,
      );
    } on PlatformException {
      if (context.mounted) {
        AppToaster.warning(AppLocalizations.of(context).contactPickFailed);
      }
      return null;
    } catch (_) {
      if (context.mounted) {
        AppToaster.warning(AppLocalizations.of(context).contactPickFailed);
      }
      return null;
    } finally {
      _picking = false;
    }
  }

  static Future<String?> _choosePhone(BuildContext context, List<String> phones, AppLocalizations l10n) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final insets = MediaQuery.viewInsetsOf(ctx);
        Widget sheet = Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Text(l10n.contactPickChoosePhone, textAlign: TextAlign.start),
                ),
                for (final p in phones)
                  ListTile(
                    title: Text(DisplayDigits.toWesternDigits(p), textDirection: TextDirection.ltr),
                    onTap: () => Navigator.pop(ctx, p),
                  ),
              ],
            ),
          ),
        );
        if (!ctx.isBnoodMobile) {
          sheet = Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ctx.formMaxWidth),
              child: sheet,
            ),
          );
        }
        return sheet;
      },
    );
  }
}
