import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/utils/extensions/bidi_isolate.dart';
import '../../core/widgets/app_toaster.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/foundation_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'auth_controller.dart';
import 'auth_messages.dart';
import 'auth_paths.dart';

class RemoteWorkspaceScreen extends ConsumerWidget {
  const RemoteWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).user;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: FoundationAppBar(title: l10n.authRemoteWorkspaceTitle),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSize.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.authRemoteWorkspaceBody,
                      style: context.text.body,
                      textAlign: TextAlign.start,
                    ),
                    if (user != null) ...[
                      AppSize.spaceXL.gap,
                      Text(l10n.authSignedInAs, style: context.text.label),
                      AppSize.spaceXS.gap,
                      Text(
                        LtrIsolate.isolate(user.phone),
                        style: context.text.bodyEmphasis,
                      ),
                    ],
                    const Spacer(),
                    AppButton.primary(
                      text: l10n.authChangePassword,
                      onPressed: () => context.push(AuthPaths.changePassword),
                    ),
                    AppSize.spaceMD.gap,
                    AppButton.outlined(
                      text: l10n.authSignOut,
                      onPressed: () async {
                        final failure = await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (!context.mounted) return;
                        if (failure != null) {
                          AppToaster.show(
                            authApiMessage(l10n, failure),
                            kind: ToastKind.warning,
                          );
                        }
                        context.go(AuthPaths.login);
                      },
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
