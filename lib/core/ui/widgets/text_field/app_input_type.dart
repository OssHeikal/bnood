import 'package:flutter/material.dart';

enum AppInputType {
  text,
  email,
  password,
  phone,
  number,
  integer,
  currency,
  percentage,
  url,
  multiline,
  search,
}

extension AppInputTypeBehavior on AppInputType {
  TextInputType get keyboardType {
    return switch (this) {
      AppInputType.text || AppInputType.search => TextInputType.text,
      AppInputType.email => TextInputType.emailAddress,
      AppInputType.password => TextInputType.visiblePassword,
      AppInputType.phone => TextInputType.phone,
      AppInputType.number || AppInputType.currency || AppInputType.percentage =>
        const TextInputType.numberWithOptions(decimal: true),
      AppInputType.integer => const TextInputType.numberWithOptions(),
      AppInputType.url => TextInputType.url,
      AppInputType.multiline => TextInputType.multiline,
    };
  }

  TextInputAction get textInputAction {
    return switch (this) {
      AppInputType.multiline => TextInputAction.newline,
      AppInputType.search => TextInputAction.search,
      _ => TextInputAction.done,
    };
  }

  bool get isNumeric {
    return switch (this) {
      AppInputType.number ||
      AppInputType.integer ||
      AppInputType.currency ||
      AppInputType.percentage => true,
      _ => false,
    };
  }

  bool get isObscured => this == AppInputType.password;

  bool get directsItself {
    return switch (this) {
      AppInputType.password || AppInputType.phone || AppInputType.url => false,
      _ => true,
    };
  }
}

enum AppInputCounterPolicy { none, hard, soft }

enum AppInputVariant { field, bare }
