import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'auth_controller.dart';
import 'auth_form_ui.dart';
import 'auth_state.dart';

class AuthBootstrapScreen extends ConsumerWidget {
  const AuthBootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authBootstrapInitProvider);
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(authControllerProvider).bootstrapStatus;
    final showRetry = status == AuthBootstrapStatus.bootstrapNetworkError;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: CustomAppBar(title: l10n.appTitle),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSize.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showRetry) ...[
                      Text(
                        l10n.authNetworkError,
                        style: context.text.body,
                        textAlign: TextAlign.center,
                      ),
                      AppSize.spaceLG.gap,
                      AppButton.primary(
                        text: l10n.authBootstrapRetry,
                        onPressed: () => ref
                            .read(authControllerProvider.notifier)
                            .retryBootstrap(),
                      ),
                    ] else
                      const CircularProgressIndicator.adaptive(),
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
