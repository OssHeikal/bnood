class DefaultItemSeed {
  const DefaultItemSeed({
    required this.arabicName,
    required this.colorKey,
    required this.iconName,
  });

  final String arabicName;
  final String colorKey;
  final String iconName;
}

/// Arabic catalog labels seeded on first workspace creation (no demo transactions).
const defaultItemSeeds = <DefaultItemSeed>[
  DefaultItemSeed(arabicName: 'هدم وإزالة', colorKey: 'brick', iconName: 'pickaxe'),
  DefaultItemSeed(arabicName: 'محارة', colorKey: 'olive', iconName: 'brick_wall'),
  DefaultItemSeed(arabicName: 'أرضيات', colorKey: 'gold', iconName: 'layers'),
  DefaultItemSeed(arabicName: 'سيراميك وحمامات', colorKey: 'blue', iconName: 'bathtub'),
  DefaultItemSeed(arabicName: 'سباكة', colorKey: 'turquoise', iconName: 'sink'),
  DefaultItemSeed(arabicName: 'كهرباء', colorKey: 'orange', iconName: 'plug_socket'),
  DefaultItemSeed(arabicName: 'جبس بورد', colorKey: 'purple', iconName: 'dashboard_square'),
  DefaultItemSeed(arabicName: 'دهانات', colorKey: 'pink', iconName: 'paint_roller'),
  DefaultItemSeed(arabicName: 'نجارة وأبواب', colorKey: 'brick', iconName: 'door'),
  DefaultItemSeed(arabicName: 'مطبخ', colorKey: 'teal', iconName: 'refrigerator'),
  DefaultItemSeed(arabicName: 'ألوميتال وشتر', colorKey: 'blue', iconName: 'windows'),
  DefaultItemSeed(arabicName: 'تكييف', colorKey: 'green', iconName: 'smart_ac'),
  DefaultItemSeed(arabicName: 'إضاءة', colorKey: 'gold', iconName: 'lamp'),
  DefaultItemSeed(arabicName: 'أيدي عاملة', colorKey: 'olive', iconName: 'hard_hat'),
  DefaultItemSeed(arabicName: 'نقل ومهمات', colorKey: 'orange', iconName: 'pickup'),
  DefaultItemSeed(arabicName: 'متنوعات', colorKey: 'purple', iconName: 'grid_table'),
];
