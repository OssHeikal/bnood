import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps previous [T] on silent reload; drops stale overlapping responses.
abstract class SilentAsyncNotifier<T> extends AsyncNotifier<T> {
  int _reloadSeq = 0;

  Future<T> fetch();

  @override
  Future<T> build() async => fetch();

  Future<void> refreshSilently() async {
    final previous = state.valueOrNull;
    final seq = ++_reloadSeq;
    if (previous != null) {
      state = AsyncValue<T>.loading().copyWithPrevious(AsyncValue.data(previous));
    } else if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    try {
      final next = await fetch();
      if (seq != _reloadSeq) return;
      state = AsyncValue.data(next);
    } catch (error, stackTrace) {
      if (seq != _reloadSeq) return;
      if (previous != null) {
        state = AsyncValue<T>.error(error, stackTrace).copyWithPrevious(AsyncValue.data(previous));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}
