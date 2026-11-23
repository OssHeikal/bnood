import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/shell_bottom_inset.dart';
import '../../../../app/shell_tab_scaffold.dart';
import '../../../../core/account/account_context_providers.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/bnood_list_canvas.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/settings/presentation/widgets/app_menu_body.dart';

/// Shell **More** tab: menu modules, account, content, and logout.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isPersonal = ref.watch(accountContextProvider.select((s) => s.isPersonal));
    final title = isPersonal ? l10n.navMorePersonal : l10n.navMoreOffice;

    return HomeFoundationScope(
      child: ShellTabScaffold(
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          title: title,
        ),
        body: BnoodListCanvas(
          child: Builder(
            builder: (context) {
              final bottomInset =
                  ShellBottomInset.listScrollBottomPadding(context);
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  0,
                  AppSize.spaceMD,
                  0,
                  bottomInset,
                ),
                child: const AppMenuBody(),
              );
            },
          ),
        ),
      ),
    );
  }
}