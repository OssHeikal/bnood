import 'item_api_record.dart';

/// Full item icon catalog (aligned with backend `AppItemIcon` enum).
const itemIconCatalogKeys = <String>[
  'paint_roller',
  'brick_wall',
  'plug_socket',
  'sink',
  'toilet',
  'bathtub',
  'door',
  'windows',
  'smart_ac',
  'lamp',
  'hammer',
  'drill',
  'wrench',
  'tools',
  'shovel',
  'pickaxe',
  'hard_hat',
  'pickup',
  'sofa',
  'sofa_single',
  'bed_single',
  'desk',
  'mirror',
  'refrigerator',
  'grid_table',
  'dashboard_square',
  'layers',
];

/// Picker uses only the canonical catalog (colors still come from the API).
ItemIconsCatalog withFullItemIconCatalog(ItemIconsCatalog catalog) {
  return ItemIconsCatalog(
    colors: catalog.colors,
    iconKeys: List<String>.from(itemIconCatalogKeys),
  );
}
