import 'package:flutter/material.dart';

import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/formatting/person_initials.dart';

/// Subscriber identity circle: primary fill, onPrimary initials (Home, Profile, etc.).
class UserIdentityAvatar extends StatelessWidget {
  const UserIdentityAvatar({
    super.key,
    required this.displayName,
    this.size = 48,
    this.imageUrl,
    this.onTap,
    this.semanticsLabel,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String displayName;
  final double size;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final initials = personInitials(displayName);
    final fontSize = size * 0.38;

    final url = imageUrl?.trim();
    final Widget face = url != null && url.isNotEmpty
        ? Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _initialsFace(text, initials, fontSize, colors),
          )
        : _initialsFace(text, initials, fontSize, colors);

    final avatar = Material(
      color: backgroundColor ?? colors.surfaceSunken,
      shape: AppShape.circle,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: size, height: size, child: face),
    );

    if (onTap == null) return avatar;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(onTap: onTap, customBorder: AppShape.circle, child: avatar),
    );
  }

  Widget _initialsFace(AppText text, String initials, double fontSize, AppColors colors) {
    return Center(
      child: Text(
        initials,
        style: text.bodyEmphasis.copyWith(color: foregroundColor ?? colors.primary, fontSize: fontSize),
      ),
    );
  }
}
