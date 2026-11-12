import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/content/content_page_record.dart';

class RegisterLegalLinks extends StatelessWidget {
  const RegisterLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyle = context.text.caption.copyWith(color: context.colors.onSurfaceMuted);
    final linkStyle = textStyle.copyWith(
      color: context.colors.primary,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: '${l10n.authRegisterLegalPrefix} '),
          TextSpan(
            text: l10n.settingsContentTerms,
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () => context.push(ContentPaths.terms),
          ),
          TextSpan(text: ' ${l10n.authRegisterLegalMiddle} '),
          TextSpan(
            text: l10n.settingsContentPrivacy,
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () => context.push(ContentPaths.privacy),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
