import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/foundation_app_bar.dart';
import '../../home/home_foundation_scope.dart';

class AuthFlowScaffold extends StatelessWidget {
  const AuthFlowScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return HomeFoundationScope(
      child: Scaffold(
      appBar: FoundationAppBar(title: title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSize.screenPadding,
            AppSize.spaceMD,
            AppSize.screenPadding,
            AppSize.spaceLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subtitle != null) ...[
                Text(
                  subtitle!,
                  style: context.text.supporting,
                  textAlign: TextAlign.start,
                ),
                AppSize.spaceLG.gap,
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
              AppSize.spaceMD.gap,
              footer,
            ],
          ),
        ),
      ),
      ),
    );
  }
}
