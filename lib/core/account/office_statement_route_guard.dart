import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_mutation_guards.dart';
import 'account_office_providers.dart';
import 'office_route_guards.dart';

/// Blocks the statement UI when office scope lacks money + client view access.
class OfficeStatementRouteGuard extends ConsumerStatefulWidget {
  const OfficeStatementRouteGuard({
    super.key,
    required this.clientId,
    required this.child,
  });

  final String clientId;
  final Widget child;

  @override
  ConsumerState<OfficeStatementRouteGuard> createState() =>
      _OfficeStatementRouteGuardState();
}

class _OfficeStatementRouteGuardState
    extends ConsumerState<OfficeStatementRouteGuard> {
  var _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _enforce());
  }

  @override
  void didUpdateWidget(covariant OfficeStatementRouteGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clientId != widget.clientId) {
      _checked = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _enforce());
    }
  }

  void _enforce() {
    if (!mounted || _checked) return;
    _checked = true;
    final perms = ref.read(officeAccountPermissionsProvider);
    if (canOpenStatement(perms)) return;
    notifyOfficePermissionDenied(context);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = canOpenStatement(ref.watch(officeAccountPermissionsProvider));
    if (!allowed) {
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}