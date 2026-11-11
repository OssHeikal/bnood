import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeSectionCounts {
  const HomeSectionCounts({
    this.clientsCount,
    this.craftsmenCount,
    this.suppliersCount,
  });

  final int? clientsCount;
  final int? craftsmenCount;
  final int? suppliersCount;
}

final homeSectionCountsProvider = StateProvider<HomeSectionCounts>((ref) => const HomeSectionCounts());
