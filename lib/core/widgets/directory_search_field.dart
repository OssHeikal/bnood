import 'package:flutter/material.dart';

import 'custom_text_field.dart';

/// Search field for directory list screens with explicit focus ownership.
class DirectorySearchField extends StatefulWidget {
  const DirectorySearchField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  State<DirectorySearchField> createState() => _DirectorySearchFieldState();
}

class _DirectorySearchFieldState extends State<DirectorySearchField> {
  final _focusNode = FocusNode();

  @override
  void deactivate() {
    _focusNode.unfocus();
    super.deactivate();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void unfocus() => _focusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    return CustomTextField.search(
      controller: widget.controller,
      focusNode: _focusNode,
      placeholder: widget.placeholder,
      onChanged: widget.onChanged,
    );
  }
}