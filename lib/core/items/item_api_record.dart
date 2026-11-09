class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String iconKey;
  final String colorKey;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  static CatalogItem fromDataJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: (json['icon_key'] as String?) ?? 'category',
      colorKey: (json['color_key'] as String?) ?? 'teal',
      isDefault: json['is_default'] == true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
    );
  }
}

class ItemsListPage {
  const ItemsListPage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<CatalogItem> items;
  final int page;
  final int perPage;
  final int total;

  bool get hasMore => page * perPage < total;
}

class ItemColorOption {
  const ItemColorOption({required this.key, required this.hex});

  final String key;
  final String hex;

  factory ItemColorOption.fromJson(Map<String, dynamic> json) {
    return ItemColorOption(
      key: json['key'] as String,
      hex: json['hex'] as String? ?? '',
    );
  }
}

class ItemIconsCatalog {
  const ItemIconsCatalog({
    required this.colors,
    required this.iconKeys,
  });

  final List<ItemColorOption> colors;
  final List<String> iconKeys;

  factory ItemIconsCatalog.fromJson(Map<String, dynamic> json) {
    final colorsRaw = json['colors'];
    final iconsRaw = json['icons'];
    final colors = colorsRaw is List
        ? colorsRaw
            .whereType<Map<String, dynamic>>()
            .map(ItemColorOption.fromJson)
            .toList()
        : <ItemColorOption>[];
    final icons = iconsRaw is List ? iconsRaw.map((e) => e.toString()).toList() : <String>[];
    return ItemIconsCatalog(colors: colors, iconKeys: icons);
  }
}
