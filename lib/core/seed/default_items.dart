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
  DefaultItemSeed(
      arabicName: 'هدم وإزالة', colorKey: 'brick', iconName: 'construction'),
  DefaultItemSeed(
      arabicName: 'محارة', colorKey: 'olive', iconName: 'format_paint'),
  DefaultItemSeed(arabicName: 'أرضيات', colorKey: 'gold', iconName: 'layers'),
  DefaultItemSeed(
      arabicName: 'سيراميك وحمامات', colorKey: 'blue', iconName: 'bathtub'),
  DefaultItemSeed(
      arabicName: 'سباكة', colorKey: 'turquoise', iconName: 'plumbing'),
  DefaultItemSeed(
      arabicName: 'كهرباء',
      colorKey: 'orange',
      iconName: 'electrical_services'),
  DefaultItemSeed(
      arabicName: 'جبس بورد', colorKey: 'purple', iconName: 'dashboard'),
  DefaultItemSeed(arabicName: 'دهانات', colorKey: 'pink', iconName: 'brush'),
  DefaultItemSeed(
      arabicName: 'نجارة وأبواب',
      colorKey: 'brick',
      iconName: 'door_front_door'),
  DefaultItemSeed(arabicName: 'مطبخ', colorKey: 'teal', iconName: 'kitchen'),
  DefaultItemSeed(
      arabicName: 'ألوميتال وشتر', colorKey: 'blue', iconName: 'window'),
  DefaultItemSeed(arabicName: 'تكييف', colorKey: 'green', iconName: 'ac_unit'),
  DefaultItemSeed(arabicName: 'إضاءة', colorKey: 'gold', iconName: 'light'),
  DefaultItemSeed(
      arabicName: 'أيدي عاملة', colorKey: 'olive', iconName: 'engineering'),
  DefaultItemSeed(
      arabicName: 'نقل ومهمات', colorKey: 'orange', iconName: 'local_shipping'),
  DefaultItemSeed(
      arabicName: 'متنوعات', colorKey: 'purple', iconName: 'category'),
];
