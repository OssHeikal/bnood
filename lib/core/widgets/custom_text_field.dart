import 'dart:async';
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/extensions/text_style_extensions.dart';
import '../config/theme/app_motion.dart';
import '../config/theme/app_size.dart';
import '../config/theme/app_colors.dart';
import '../l10n/field_placeholders.dart';
import '../utils/extensions/bidi_isolate.dart';
import 'foundation_icon.dart';
import 'text_field/app_input_direction.dart';
import 'text_field/app_input_formatters.dart';
import 'text_field/app_input_frame.dart';
import 'text_field/app_input_style.dart';
import 'text_field/app_input_supporting_row.dart';
import 'text_field/app_input_type.dart';

export 'text_field/app_input_frame.dart' show AppInputIconAction;
export 'text_field/app_input_type.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.type = AppInputType.text,
    this.multilineHeight,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.helperText,
    this.errorMessage,
    this.leading,
    this.trailing,
    this.prefix,
    this.suffix,
    this.clearable = true,
    this.maxLength,
    this.counterPolicy,
    this.reserveSupportingSpace = false,
    this.width,
    this.variant = AppInputVariant.field,
    this.focusNode,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
    this.onTap,
    this.onFocus,
    this.onBlur,
    this.onClear,
    this.formatters,
    this.textCapitalization = TextCapitalization.none,
    this.autoSelectOnFocus,
    this.enableAutoDirection = true,
    this.allowNegative = false,
    this.maxDecimalPlaces = 2,
    this.minValue,
    this.maxValue,
    this.enablePaste = false,
    this.enableFocus = true,
    this.autofocus = false,
    this.showPasswordLeading = true,
    this.fieldHeight,
    this.ltrValue = false,
    this.textInputAction,
    this.autofillHints,
  }) : search = false,
       assert(controller == null || initialValue == null, 'Pass a controller or an initial value, not both.');

  const CustomTextField.search({
    super.key,
    required TextEditingController this.controller,
    this.placeholder,
    this.onChanged,
  }) : initialValue = null,
       label = null,
       type = AppInputType.search,
       search = true,
       multilineHeight = null,
       disabled = false,
       readOnly = false,
       invalid = false,
       helperText = null,
       errorMessage = null,
       leading = null,
       trailing = null,
       prefix = null,
       suffix = null,
       clearable = true,
       maxLength = null,
       counterPolicy = null,
       reserveSupportingSpace = false,
       width = null,
       variant = AppInputVariant.field,
       focusNode = null,
       validator = null,
       autovalidateMode = null,
       onTap = null,
       onFocus = null,
       onBlur = null,
       onClear = null,
       formatters = null,
       textCapitalization = TextCapitalization.none,
       autoSelectOnFocus = null,
       enableAutoDirection = true,
       allowNegative = false,
       maxDecimalPlaces = 2,
       minValue = null,
       maxValue = null,
       enablePaste = false,
       enableFocus = true,
       autofocus = false,
       showPasswordLeading = true,
       fieldHeight = null,
       ltrValue = false,
       textInputAction = null,
       autofillHints = null;

  final String? label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final AppInputType type;
  final double? multilineHeight;
  final bool disabled;
  final bool readOnly;
  final bool invalid;
  final String? helperText;
  final String? errorMessage;
  final Widget? leading;
  final Widget? trailing;
  final Widget? prefix;
  final Widget? suffix;
  final bool clearable;
  final int? maxLength;
  final AppInputCounterPolicy? counterPolicy;
  final bool reserveSupportingSpace;
  final double? width;
  final AppInputVariant variant;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onFocus;
  final VoidCallback? onBlur;
  final VoidCallback? onClear;
  final List<TextInputFormatter>? formatters;
  final TextCapitalization textCapitalization;
  final bool? autoSelectOnFocus;
  final bool enableAutoDirection;
  final bool allowNegative;
  final int maxDecimalPlaces;
  final num? minValue;
  final num? maxValue;
  final bool enablePaste;
  final bool enableFocus;
  final bool autofocus;
  final bool showPasswordLeading;
  final double? fieldHeight;
  final bool ltrValue;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool search;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;
  FormFieldState<String>? _field;
  Timer? _debounce;
  late bool _obscure;
  bool _focused = false;

  TextEditingController get _controller => widget.controller ?? _ownedController!;

  FocusNode get _focus => widget.focusNode ?? _ownedFocus!;

  bool get _picker => widget.readOnly && widget.onTap != null;

  bool get _multiline => widget.type == AppInputType.multiline;

  bool get _selectOnTap => widget.autoSelectOnFocus ?? !widget.type.isObscured;

  AppInputCounterPolicy get _policy {
    if (widget.counterPolicy != null) {
      return widget.counterPolicy!;
    }
    if (widget.maxLength == null) {
      return AppInputCounterPolicy.none;
    }
    return AppInputCounterPolicy.hard;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: widget.initialValue);
    }
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _obscure = widget.type.isObscured;
    _controller.addListener(_onText);
    _focus.addListener(_onFocus);
    _syncPickerFocus();
    _focused = _focus.hasFocus;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(_onText);
      if (widget.controller == null) {
        _ownedController ??= TextEditingController(text: widget.initialValue ?? '');
      } else if (oldWidget.controller == null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      _controller.addListener(_onText);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocus)?.removeListener(_onFocus);
      if (widget.focusNode == null) {
        _ownedFocus ??= FocusNode();
      } else if (oldWidget.focusNode == null) {
        _ownedFocus?.dispose();
        _ownedFocus = null;
      }
      _focus.addListener(_onFocus);
    }
    if (oldWidget.type.isObscured != widget.type.isObscured) {
      _obscure = widget.type.isObscured;
    }
    _syncPickerFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _ownedController?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _syncPickerFocus() {
    if (_picker || !widget.enableFocus) {
      _focus.canRequestFocus = false;
      _focus.skipTraversal = true;
      return;
    }
    if (_ownedFocus != null) {
      _focus.canRequestFocus = true;
      _focus.skipTraversal = false;
    }
  }

  void _onText() {
    _field?.didChange(cleanAppInputValue(_controller.text, widget.type));
    if (mounted) {
      setState(() {});
    }
  }

  void _onFocus() {
    final next = _focus.hasFocus;
    if (next == _focused) {
      return;
    }
    setState(() => _focused = next);
    if (next) {
      widget.onFocus?.call();
    } else {
      widget.onBlur?.call();
    }
  }

  void _changed(String value) {
    final cleaned = cleanAppInputValue(value, widget.type);
    if (!widget.search) {
      widget.onChanged?.call(cleaned);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(AppMotion.searchDebounce, () => widget.onChanged?.call(cleaned));
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focus.requestFocus();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) {
      return;
    }
    _controller.text = text;
    _changed(text);
  }

  void _handleTap() {
    if (!widget.enableFocus) {
      return;
    }
    if (_picker) {
      widget.onTap?.call();
      return;
    }
    widget.onTap?.call();
    if (!_focus.hasFocus) {
      _focus.requestFocus();
    }
    if (!_selectOnTap || _controller.text.isEmpty) {
      return;
    }
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
  }

  void _toggleObscure() {
    setState(() => _obscure = !_obscure);
  }

  bool _softOverflow(String text) {
    final max = widget.maxLength;
    if (max == null || _policy != AppInputCounterPolicy.soft) {
      return false;
    }
    return text.characters.length > max;
  }

  String? _counter(String text) {
    final max = widget.maxLength;
    if (max == null || _policy == AppInputCounterPolicy.none) {
      return null;
    }
    return LtrIsolate.isolate('${text.characters.length} / $max');
  }

  TextInputType get _keyboard {
    if (!widget.type.isNumeric) {
      return widget.type.keyboardType;
    }
    return TextInputType.numberWithOptions(decimal: widget.type != AppInputType.integer, signed: widget.allowNegative);
  }

  TextDirection _textDirection(BuildContext context) {
    if (widget.ltrValue || widget.type.isObscured) {
      return TextDirection.ltr;
    }
    final ambient = Directionality.of(context);
    if (widget.type.isNumeric) {
      return ambient;
    }
    if (!widget.enableAutoDirection || !widget.type.directsItself) {
      return ambient;
    }
    return inferTextDirection(_controller.text, ambient);
  }

  String _placeholder() {
    final given = widget.placeholder;
    if (given != null) {
      return given;
    }
    return switch (widget.type) {
      AppInputType.text => FieldPlaceholders.text,
      AppInputType.email => FieldPlaceholders.email,
      AppInputType.password => FieldPlaceholders.password,
      AppInputType.phone => FieldPlaceholders.phone,
      AppInputType.number => FieldPlaceholders.number,
      AppInputType.integer => FieldPlaceholders.integer,
      AppInputType.currency => FieldPlaceholders.currency,
      AppInputType.percentage => FieldPlaceholders.percentage,
      AppInputType.url => FieldPlaceholders.url,
      AppInputType.multiline => FieldPlaceholders.text,
      AppInputType.search => FieldPlaceholders.search,
    };
  }

  Widget? get _leading {
    if (widget.leading != null) {
      return widget.leading;
    }
    if (widget.search) {
      return FoundationIcon(Icons.search);
    }
    // if (widget.type.isObscured && widget.showPasswordLeading) {
    //   return _TintedSvg(Assets.icons.lock);
    // }
    return null;
  }

  Widget _contextMenu(BuildContext context, EditableTextState editable) {
    final items = editable.contextMenuButtonItems.where((item) {
      return item.type == ContextMenuButtonType.copy || item.type == ContextMenuButtonType.selectAll;
    }).toList();
    return AdaptiveTextSelectionToolbar.buttonItems(anchors: editable.contextMenuAnchors, buttonItems: items);
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.autovalidateMode ?? AutovalidateMode.onUnfocus;
    return FormField<String>(
      initialValue: cleanAppInputValue(_controller.text, widget.type),
      enabled: !widget.disabled,
      autovalidateMode: mode,
      validator: (value) {
        if (widget.errorMessage != null) {
          return widget.errorMessage;
        }
        return widget.validator?.call(value);
      },
      builder: (field) {
        _field = field;
        return _body(context, field);
      },
    );
  }

  Widget _body(BuildContext context, FormFieldState<String> field) {
    final text = _controller.text;
    final shownError = widget.errorMessage ?? field.errorText;
    final invalid = widget.invalid || shownError != null || _softOverflow(text);
    final style = AppInputStyle.resolve(
      context.colors,
      AppInputState(disabled: widget.disabled, invalid: invalid, focused: _focused),
    );
    final floated = widget.label == null || _focused || text.isNotEmpty;
    final resolvedHeight = widget.fieldHeight ??
        (_multiline
            ? widget.multilineHeight ?? AppSize.multilineFieldHeight
            : widget.search
                ? AppSize.searchFieldHeight
                : AppSize.fieldHeight);
    final showClear =
        widget.clearable && !_multiline && _focused && text.isNotEmpty && !widget.disabled && !widget.readOnly;
    final frame = AppInputFrame(
      style: style,
      variant: widget.variant,
      multiline: _multiline,
      height: resolvedHeight,
      floated: floated,
      label: widget.search || widget.variant == AppInputVariant.bare ? null : widget.label,
      field: _input(context, style, floated, shownError, invalid),
      onSurfaceTap: _handleTap,
      suffixAtStart: widget.type.isNumeric && Directionality.of(context) == TextDirection.rtl,
      leading: _leading,
      trailing: widget.trailing,
      prefix: widget.prefix,
      suffix: widget.suffix,
      clear: showClear
          ? AppInputIconAction(
              icon: FoundationIcon(Icons.close),
              semanticLabel: FieldPlaceholders.clearField,
              onPressed: _clear,
            )
          : null,
      passwordToggle: widget.type.isObscured && !widget.disabled
          ? AppInputIconAction(
              icon: FoundationIcon(_obscure ? Icons.visibility : Icons.visibility_off),
              semanticLabel: FieldPlaceholders.clearField,
              onPressed: _toggleObscure,
            )
          : null,
      paste: widget.enablePaste && !widget.disabled && !widget.readOnly
          ? AppInputIconAction(
              icon: const Icon(Icons.content_paste),
              semanticLabel: FieldPlaceholders.clearField,
              onPressed: _paste,
            )
          : null,
    );
    final supporting = widget.variant == AppInputVariant.bare
        ? null
        : AppInputSupportingRow(
            message: shownError ?? widget.helperText,
            isError: shownError != null,
            messageColor: shownError != null ? style.error : style.helper,
            counter: _counter(text),
            counterColor: style.counter,
            reserve: widget.reserveSupportingSpace,
          );
    return TextFieldTapRegion(
      child: MouseRegion(
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : widget.enableFocus
            ? SystemMouseCursors.text
            : SystemMouseCursors.basic,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [frame, ?supporting],
          ),
        ),
      ),
    );
  }

  void _unfocusOnTapOutside(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Widget _input(BuildContext context, AppInputStyle style, bool floated, String? shownError, bool invalid) {
    return Semantics(
      label: widget.search ? _placeholder() : widget.label,
      hint: shownError ?? widget.helperText,
      validationResult: invalid ? SemanticsValidationResult.invalid : SemanticsValidationResult.valid,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        canRequestFocus: !_picker && widget.enableFocus,
        enabled: !widget.disabled,
        readOnly: widget.readOnly,
        obscureText: _obscure && widget.type.isObscured,
        keyboardType: _keyboard,
        textInputAction: widget.textInputAction ?? widget.type.textInputAction,
        autofillHints: widget.autofillHints,
        textCapitalization: widget.textCapitalization,
        textAlign: TextAlign.start,
        textDirection: _textDirection(context),
        textAlignVertical: _multiline ? TextAlignVertical.top : TextAlignVertical.center,
        maxLines: _multiline ? null : 1,
        expands: _multiline && widget.variant == AppInputVariant.field,
        cursorColor: style.cursor,
        style: context.text.body.setColor(style.value),
        mouseCursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : widget.enableFocus
            ? SystemMouseCursors.text
            : SystemMouseCursors.basic,
        inputFormatters: buildAppInputFormatters(
          widget.type,
          formatters: widget.formatters,
          maxLength: widget.maxLength,
          policy: _policy,
          allowNegative: widget.allowNegative,
          maxDecimalPlaces: widget.maxDecimalPlaces,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
        ),
        onChanged: _changed,
        onTap: widget.enableFocus ? _handleTap : null,
        onTapOutside: widget.enableFocus && !_picker ? _unfocusOnTapOutside : null,
        contextMenuBuilder: widget.readOnly ? _contextMenu : null,
        decoration: InputDecoration(
          isCollapsed: true,
          filled: false,
          contentPadding: EdgeInsets.zero,
          hintText: floated && _placeholder().isNotEmpty ? _placeholder() : null,
          hintStyle: context.text.body.setColor(style.placeholder),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}

