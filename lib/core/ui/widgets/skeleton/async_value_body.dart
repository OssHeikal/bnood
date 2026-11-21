import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'skeleton.dart';

/// Shows [data] whenever a value exists (including silent reload). Skeleton only with no data yet.
class AsyncValueBody<T> extends StatelessWidget {
  const AsyncValueBody({
    super.key,
    required this.value,
    required this.loadingPlaceholder,
    required this.data,
    required this.error,
  });

  final AsyncValue<T> value;
  final Widget loadingPlaceholder;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace) error;

  @override
  Widget build(BuildContext context) {
    final cached = value.valueOrNull;
    if (cached != null) {
      return data(cached);
    }
    return value.when(
      data: data,
      loading: () => Skeleton(child: loadingPlaceholder),
      error: error,
    );
  }
}
