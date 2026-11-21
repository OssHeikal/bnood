import 'package:flutter/material.dart';

/// Tab body inside [ShellScaffold] — outer shell owns keyboard resize.
class ShellTabScaffold extends StatelessWidget {
  const ShellTabScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: body,
    );
  }
}
