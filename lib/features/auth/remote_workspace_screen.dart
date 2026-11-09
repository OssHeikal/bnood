import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'auth_paths.dart';

/// Legacy route: account actions now live on Profile and Settings.
class RemoteWorkspaceScreen extends ConsumerWidget {
  const RemoteWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: CustomAppBar(title: l10n.authRemoteWorkspaceTitle),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSize.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authRemoteWorkspaceMovedBody,
                      style: context.text.body,
                      textAlign: TextAlign.start,
                    ),
                    AppSize.spaceXL.gap,
                    AppButton.primary(
                      text: l10n.userProfileTitle,
                      onPressed: () => context.push(AuthPaths.profile),
                    ),
                    AppSize.spaceMD.gap,
                    AppButton.outlined(
                      text: l10n.settingsTitle,
                      onPressed: () => context.push(AuthPaths.settings),
                    ),
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
