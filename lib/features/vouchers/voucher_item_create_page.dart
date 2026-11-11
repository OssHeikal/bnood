import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../items/item_create_sheet.dart';

/// Full-screen item create for voucher pickers — pops with new item id.
class VoucherItemCreatePage extends StatelessWidget {
  const VoucherItemCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(title: l10n.itemCreateSheetTitle),
      body: const SafeArea(
        top: false,
        child: ItemCreateSheet(
          returnCreatedItemId: true,
          showSheetChrome: false,
        ),
      ),
    );
  }
}
