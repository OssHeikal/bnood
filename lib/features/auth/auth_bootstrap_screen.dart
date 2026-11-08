import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/foundation_app_bar.dart';
import '../home/home_foundation_scope.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

class AuthBootstrapScreen extends ConsumerStatefulWidget {
  const AuthBootstrapScreen({super.key});

  @override
  ConsumerState<AuthBootstrapScreen> createState() => _AuthBootstrapScreenState();
}

class _AuthBootstrapScreenState extends ConsumerState<AuthBootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).ensureBootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(authControllerProvider).bootstrapStatus;
    final showRetry = status == AuthBootstrapStatus.bootstrapNetworkError;

    return HomeFoundationScope(
      child: Scaffold(
      appBar: FoundationAppBar(title: l10n.appTitle),
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
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).retryBootstrap(),
                ),
              ] else
                const CircularProgressIndicator.adaptive(),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
