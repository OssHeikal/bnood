import 'package:flutter/widgets.dart';

/// Answers "is the floating shell dock on screen right now?" at toast show time.
///
/// The shell registers its route and whether it renders a dock (mobile layout).
/// [observer] tracks the root navigator stack so popup routes (sheets, dialogs)
/// are ignored: the dock stays under them and is visible again once they close,
/// while a full page pushed over the shell (details screens) hides the dock.
abstract final class ShellDockPresence {
  static Route<dynamic>? _shellRoute;
  static BuildContext? _shellContext;
  static bool _hasDock = false;

  /// New observer for the root navigator (GoRouter `observers`). A fresh instance per
  /// router avoids attaching one observer to two navigators; it resets the tracked stack.
  static NavigatorObserver createObserver() {
    _stack.clear();
    return _ShellDockRouteObserver();
  }

  static final List<Route<dynamic>> _stack = <Route<dynamic>>[];

  /// Called by the shell during build. [hasDock] is false in the desktop (rail) layout.
  /// Keyboard state is intentionally not part of this; the toaster checks the live inset.
  static void register(BuildContext context, {required bool hasDock}) {
    _shellContext = context;
    _shellRoute = ModalRoute.of(context);
    _hasDock = hasDock;
  }

  /// Whether toasts should clear the dock (ignoring the keyboard).
  static bool get visible {
    final ctx = _shellContext;
    if (!_hasDock || ctx == null || !ctx.mounted) return false;
    final route = _shellRoute;
    if (route == null) return true;
    if (!route.isActive) return false;
    if (route.isCurrent) return true;
    final topPage = _topNonPopupRoute();
    // Without stack data (observer not attached) fall back to the shell being active.
    return topPage == null || identical(topPage, route);
  }

  static Route<dynamic>? _topNonPopupRoute() {
    for (var i = _stack.length - 1; i >= 0; i--) {
      final route = _stack[i];
      if (route is PopupRoute) continue;
      return route;
    }
    return null;
  }

  @visibleForTesting
  static void resetForTesting() {
    _shellRoute = null;
    _shellContext = null;
    _hasDock = false;
    _stack.clear();
  }
}

class _ShellDockRouteObserver extends NavigatorObserver {
  List<Route<dynamic>> get _stack => ShellDockPresence._stack;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stack.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stack.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _stack.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (newRoute == null) {
      if (index >= 0) _stack.removeAt(index);
      return;
    }
    if (index >= 0) {
      _stack[index] = newRoute;
    } else {
      _stack.add(newRoute);
    }
  }
}
