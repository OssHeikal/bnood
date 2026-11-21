/// Active ledger account: personal subscriber vs one office membership.
sealed class AccountScope {
  const AccountScope();

  const factory AccountScope.personal() = AccountScopePersonal;

  factory AccountScope.office(String officeId) {
    final trimmed = officeId.trim();
    if (trimmed.isEmpty) {
      return const AccountScope.personal();
    }
    return AccountScopeOffice(trimmed);
  }

  bool get isPersonal => this is AccountScopePersonal;

  String? get officeId => switch (this) {
    AccountScopePersonal() => null,
    AccountScopeOffice(:final officeId) => officeId,
  };

  /// Stable key for comparing selections (`personal` or office id).
  String get persistenceKey => switch (this) {
    AccountScopePersonal() => 'personal',
    AccountScopeOffice(:final officeId) => officeId,
  };

  @override
  bool operator ==(Object other) =>
      other is AccountScope && persistenceKey == other.persistenceKey;

  @override
  int get hashCode => persistenceKey.hashCode;
}

final class AccountScopePersonal extends AccountScope {
  const AccountScopePersonal();
}

final class AccountScopeOffice extends AccountScope {
  const AccountScopeOffice(this.officeId);

  @override
  final String officeId;
}