import 'package:flutter/material.dart';

import '../../config/extensions/text_style_extensions.dart';
import '../../config/theme/app_size.dart';
import '../../config/theme/app_colors.dart';
import '../animated_slide_text.dart';

class AppInputSupportingRow extends StatelessWidget {
  const AppInputSupportingRow({
    super.key,
    required this.message,
    required this.isError,
    required this.messageColor,
    required this.counter,
    required this.counterColor,
    required this.reserve,
  });

  final String? message;
  final bool isError;
  final Color messageColor;
  final String? counter;
  final Color counterColor;
  final bool reserve;

  @override
  Widget build(BuildContext context) {
    final hasMessage = message != null && message!.isNotEmpty;
    final hasCounter = counter != null;
    if (!hasMessage && !hasCounter && !reserve) {
      return const SizedBox.shrink();
    }
    final style = context.text.supporting;
    return Padding(
      padding: const EdgeInsets.only(top: AppSize.spaceXS),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.spaceLG),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _message(style)),
              if (hasCounter) ...[
                const SizedBox(width: AppSize.gap),
                Text(counter!, style: style.setColor(counterColor)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _message(TextStyle style) {
    final text = AnimatedSlideText(
      isVisible: message != null && message!.isNotEmpty,
      text: message,
      textStyle: style.setColor(messageColor),
      paddingTop: 0,
      paddingStart: 0,
    );
    if (!isError) {
      return text;
    }
    return Semantics(liveRegion: true, child: text);
  }
}
