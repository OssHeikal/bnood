import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeSectionCounts {
  const HomeSectionCounts({
    this.clientsCount,
    this.projectsCount,
    this.craftsmenCount,
    this.suppliersCount,
  });

  final int? clientsCount;
  final int? projectsCount;
  final int? craftsmenCount;
  final int? suppliersCount;

  HomeSectionCounts copyWith({
    int? clientsCount,
    int? projectsCount,
    int? craftsmenCount,
    int? suppliersCount,
  }) {
    return HomeSectionCounts(
      clientsCount: clientsCount ?? this.clientsCount,
      projectsCount: projectsCount ?? this.projectsCount,
      craftsmenCount: craftsmenCount ?? this.craftsmenCount,
      suppliersCount: suppliersCount ?? this.suppliersCount,
    );
  }
}

final homeSectionCountsProvider = StateProvider<HomeSectionCounts>(
  (ref) => const HomeSectionCounts(),
);
