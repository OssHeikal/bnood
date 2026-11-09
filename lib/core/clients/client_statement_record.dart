class AppClientStatementItemSpend {
  const AppClientStatementItemSpend({
    required this.id,
    required this.name,
    required this.spentMinor,
    required this.materialsMinor,
    required this.laborMinor,
    required this.colorKey,
    required this.iconKey,
  });

  final String id;
  final String name;
  final int spentMinor;
  final int materialsMinor;
  final int laborMinor;
  final String colorKey;
  final String iconKey;

  static AppClientStatementItemSpend fromDataJson(Map<String, dynamic> json) {
    final materialsMinor = _readMinor(json['materials']);
    final laborMinor = _readMinor(json['labor']);
    final spentRaw = _readMinor(json['spent']);
    final spentMinor = spentRaw != 0 ? spentRaw : materialsMinor + laborMinor;
    return AppClientStatementItemSpend(
      id: json['id'] as String,
      name: json['name'] as String,
      spentMinor: spentMinor,
      materialsMinor: materialsMinor,
      laborMinor: laborMinor,
      colorKey: json['color_key'] as String? ?? 'teal',
      iconKey: json['icon_key'] as String? ?? 'category',
    );
  }
}

class AppClientStatement {
  const AppClientStatement({
    required this.from,
    required this.to,
    required this.receivedMinor,
    required this.spentMinor,
    required this.remainingMinor,
    required this.items,
  });

  final String from;
  final String to;
  final int receivedMinor;
  final int spentMinor;
  final int remainingMinor;
  final List<AppClientStatementItemSpend> items;

  static AppClientStatement fromDataJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .map((e) => AppClientStatementItemSpend.fromDataJson(e as Map<String, dynamic>))
            .toList()
        : const <AppClientStatementItemSpend>[];

    return AppClientStatement(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      receivedMinor: _readMinor(json['received']),
      spentMinor: _readMinor(json['spent']),
      remainingMinor: _readMinor(json['remaining']),
      items: items,
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
