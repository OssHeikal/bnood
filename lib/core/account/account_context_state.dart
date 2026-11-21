import 'account_scope.dart';

class AccountContextState {
  const AccountContextState({
    required this.scope,
    this.restoredFromDisk = false,
  });

  const AccountContextState.personal({this.restoredFromDisk = false})
    : scope = const AccountScope.personal();

  final AccountScope scope;
  final bool restoredFromDisk;

  String? get officeId => scope.officeId;

  bool get isPersonal => scope.isPersonal;

  AccountContextState copyWith({
    AccountScope? scope,
    bool? restoredFromDisk,
  }) {
    return AccountContextState(
      scope: scope ?? this.scope,
      restoredFromDisk: restoredFromDisk ?? this.restoredFromDisk,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AccountContextState &&
      other.scope == scope &&
      other.restoredFromDisk == restoredFromDisk;

  @override
  int get hashCode => Object.hash(scope, restoredFromDisk);
}