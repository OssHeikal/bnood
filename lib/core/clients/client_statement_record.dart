class AppClientStatementItemSpend {
  const AppClientStatementItemSpend({
    required this.id,
    required this.name,
    required this.spentMinor,
    required this.materialsMinor,
    required this.laborMinor,
    this.colorKey,
    this.iconKey,
  });

  final String id;
  final String name;
  final int spentMinor;
  final int materialsMinor;
  final int laborMinor;
  /// Same keys as items API (`icon_key` / `color_key`); null when omitted.
  final String? colorKey;
  final String? iconKey;

  static AppClientStatementItemSpend fromDataJson(Map<String, dynamic> json) {
    final materialsMinor = _readMinor(json['materials']);
    final laborMinor = _readMinor(json['labor']);
    final spentRaw = _readMinor(json['spent']);
    final spentMinor = spentRaw != 0 ? spentRaw : materialsMinor + laborMinor;
    return AppClientStatementItemSpend(
      id: json['id'].toString(),
      name: json['name'] as String,
      spentMinor: spentMinor,
      materialsMinor: materialsMinor,
      laborMinor: laborMinor,
      colorKey: _readOptionalString(json['color_key']),
      iconKey: _readOptionalString(json['icon_key']),
    );
  }
}

class StatementIssuer {
  const StatementIssuer({
    required this.name,
    required this.contactPhone,
    this.logoUrl,
  });

  final String name;
  final String? logoUrl;
  final String contactPhone;

  static StatementIssuer? fromDataJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final name = (raw['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) return null;
    final phone = raw['contact_phone'];
    if (phone == null) return null;
    final contactPhone = phone.toString();
    final logo = _readOptionalString(raw['logo_url']);
    return StatementIssuer(name: name, logoUrl: logo, contactPhone: contactPhone);
  }
}

class AppClientStatement {
  const AppClientStatement({
    required this.from,
    required this.to,
    required this.openingBalanceMinor,
    required this.receivedMinor,
    required this.spentMinor,
    required this.closingBalanceMinor,
    required this.remainingMinor,
    required this.items,
    this.issuer,
  });

  final String from;
  final String to;
  final int openingBalanceMinor;
  final int receivedMinor;
  final int spentMinor;
  final int closingBalanceMinor;
  /// Same as [closingBalanceMinor] for API compatibility.
  final int remainingMinor;
  final List<AppClientStatementItemSpend> items;
  final StatementIssuer? issuer;

  static AppClientStatement fromDataJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .map((e) => AppClientStatementItemSpend.fromDataJson(e as Map<String, dynamic>))
            .toList()
        : const <AppClientStatementItemSpend>[];

    final remainingFromApi = json.containsKey('remaining') ? _readMinor(json['remaining']) : null;
    final closing = json.containsKey('closing_balance')
        ? _readMinor(json['closing_balance'])
        : (remainingFromApi ?? 0);
    final remaining = remainingFromApi ?? closing;
    final opening = _readMinor(json['opening_balance']);

    return AppClientStatement(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      openingBalanceMinor: opening,
      receivedMinor: _readMinor(json['received']),
      spentMinor: _readMinor(json['spent']),
      closingBalanceMinor: closing,
      remainingMinor: remaining,
      items: items,
      issuer: StatementIssuer.fromDataJson(json['issuer']),
    );
  }
}

class AppClientItemSpend {
  const AppClientItemSpend({required this.items});

  final List<AppClientStatementItemSpend> items;

  static AppClientItemSpend fromDataJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .map((e) => AppClientStatementItemSpend.fromDataJson(e as Map<String, dynamic>))
            .toList()
        : const <AppClientStatementItemSpend>[];
    return AppClientItemSpend(items: items);
  }
}

int _readMinor(Object? raw) {
  if (raw == null) return 0;
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  return 0;
}

String? _readOptionalString(Object? raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  return s.isEmpty ? null : s;
}
