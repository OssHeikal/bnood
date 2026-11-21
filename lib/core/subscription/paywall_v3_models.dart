import 'app_subscription.dart';
import 'paywall_money_display.dart';

/// Query values for `GET /v1/subscription?paywall_trigger=…`.
enum PaywallFetchTrigger {
  defaultTrigger,
  limitReached,
  upgradeFromCurrent,
}

extension PaywallFetchTriggerX on PaywallFetchTrigger {
  String get queryParameter => switch (this) {
        PaywallFetchTrigger.defaultTrigger => 'default',
        PaywallFetchTrigger.limitReached => 'limit_reached',
        PaywallFetchTrigger.upgradeFromCurrent => 'upgrade_from_current',
      };

}

PaywallFetchTrigger paywallTriggerForEntitlements(AppSubscriptionEntitlements ent) {
  final isPaid = ent.isPremium && !ent.isExpiredPremium && ent.packageSlug != 'free';
  if (isPaid) return PaywallFetchTrigger.upgradeFromCurrent;
  return PaywallFetchTrigger.defaultTrigger;
}

class AppPaywallHeader {
  const AppPaywallHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  static AppPaywallHeader fromJson(Object? raw, {String fallbackTitle = '', String fallbackSubtitle = ''}) {
    if (raw is Map<String, dynamic>) {
      return AppPaywallHeader(
        title: raw['title'] as String? ?? fallbackTitle,
        subtitle: raw['subtitle'] as String? ?? fallbackSubtitle,
      );
    }
    return AppPaywallHeader(title: fallbackTitle, subtitle: fallbackSubtitle);
  }
}

class AppPaywallBenefitItem {
  const AppPaywallBenefitItem({required this.icon, required this.text});

  final String icon;
  final String text;

  static AppPaywallBenefitItem? fromJson(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final text = raw['text'] as String?;
      if (text == null || text.isEmpty) return null;
      return AppPaywallBenefitItem(icon: raw['icon'] as String? ?? 'spark', text: text);
    }
    if (raw is String && raw.isNotEmpty) {
      return AppPaywallBenefitItem(icon: 'spark', text: raw);
    }
    return null;
  }
}

class AppPaywallSocialProof {
  const AppPaywallSocialProof({required this.text});

  final String text;

  static AppPaywallSocialProof? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final text = raw['text'] as String?;
    if (text == null || text.isEmpty) return null;
    return AppPaywallSocialProof(text: text);
  }
}

class AppPaywallOfferBanner {
  const AppPaywallOfferBanner({
    required this.text,
    this.endsAt,
    this.showCountdown = false,
    this.discountPercent,
  });

  final String text;
  final DateTime? endsAt;
  final bool showCountdown;
  final int? discountPercent;

  static AppPaywallOfferBanner? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final text = raw['text'] as String? ?? raw['banner_text'] as String?;
    if (text == null || text.isEmpty) return null;
    DateTime? ends;
    final endsRaw = raw['ends_at'];
    if (endsRaw is String && endsRaw.isNotEmpty) {
      ends = DateTime.tryParse(endsRaw)?.toLocal();
    }
    int? percent;
    final dp = raw['discount_percent'];
    if (dp is int) {
      percent = dp;
    } else if (dp is num) {
      percent = dp.round();
    }
    return AppPaywallOfferBanner(
      text: text,
      endsAt: ends,
      showCountdown: raw['show_countdown'] == true,
      discountPercent: percent ?? _readOptionalInt(raw['discount_percent']),
    );
  }
}

class AppPaywallBilling {
  const AppPaywallBilling({
    required this.monthlyLabel,
    required this.yearlyLabel,
    this.yearlySavingsPercent,
  });

  final String monthlyLabel;
  final String yearlyLabel;
  final int? yearlySavingsPercent;

  static AppPaywallBilling fromJson(Object? raw, {required String localeCode}) {
    if (raw is Map<String, dynamic>) {
      return AppPaywallBilling(
        monthlyLabel: raw['monthly_label'] as String? ?? (localeCode == 'ar' ? 'شهري' : 'Monthly'),
        yearlyLabel: raw['yearly_label'] as String? ?? (localeCode == 'ar' ? 'سنوي' : 'Yearly'),
        yearlySavingsPercent: _readOptionalInt(raw['yearly_savings_percent']),
      );
    }
    return AppPaywallBilling(
      monthlyLabel: localeCode == 'ar' ? 'شهري' : 'Monthly',
      yearlyLabel: localeCode == 'ar' ? 'سنوي' : 'Yearly',
    );
  }
}

class AppPaywallPeriodOffer {
  const AppPaywallPeriodOffer({
    required this.discountPercent,
    this.endsAt,
    this.showCountdown = false,
    this.promoText,
  });

  final int discountPercent;
  final DateTime? endsAt;
  final bool showCountdown;
  final String? promoText;

  static AppPaywallPeriodOffer? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final percent = _readOptionalInt(raw['discount_percent']);
    if (percent == null) return null;
    DateTime? ends;
    final endsRaw = raw['ends_at'];
    if (endsRaw is String && endsRaw.isNotEmpty) {
      ends = DateTime.tryParse(endsRaw)?.toLocal();
    }
    return AppPaywallPeriodOffer(
      discountPercent: percent,
      endsAt: ends,
      showCountdown: raw['show_countdown'] == true,
      promoText: raw['promo_text'] as String?,
    );
  }
}

class AppPaywallPeriodPricing {
  const AppPaywallPeriodPricing({
    required this.originalMinor,
    required this.discountedMinor,
    required this.perMonthEquivalentMinor,
    this.billedTotalMinor,
    this.hasDiscount = false,
    this.offer,
    this.displayPerMonthMajor,
    this.displayBilledYearlyMajor,
    this.displayOriginalBilledYearlyMajor,
  });

  final int originalMinor;
  final int discountedMinor;
  final int perMonthEquivalentMinor;
  final int? billedTotalMinor;
  final bool hasDiscount;
  final AppPaywallPeriodOffer? offer;
  final int? displayPerMonthMajor;
  final int? displayBilledYearlyMajor;
  final int? displayOriginalBilledYearlyMajor;

  static AppPaywallPeriodPricing? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final original = _readOptionalInt(raw['original_minor']) ?? 0;
    final discounted = _readOptionalInt(raw['discounted_minor']) ?? original;
    final perMonth = _readOptionalInt(raw['per_month_equivalent_minor']) ?? discounted;
    if (original <= 0 && discounted <= 0) return null;
    return AppPaywallPeriodPricing(
      originalMinor: original,
      discountedMinor: discounted,
      perMonthEquivalentMinor: perMonth,
      billedTotalMinor: _readOptionalInt(raw['billed_total_minor']),
      hasDiscount: raw['has_discount'] == true || discounted < original,
      offer: AppPaywallPeriodOffer.fromJson(raw['offer']),
      displayPerMonthMajor: _readOptionalInt(raw['display_per_month_major']),
      displayBilledYearlyMajor: _readOptionalInt(raw['display_billed_yearly_major']),
      displayOriginalBilledYearlyMajor: _readOptionalInt(raw['display_original_billed_yearly_major']),
    );
  }

  int resolvedPerMonthMajor({required bool arabic}) =>
      displayPerMonthMajor ?? PaywallMoneyDisplay.wholeMajorFromMinor(perMonthEquivalentMinor);

  int? resolvedBilledYearlyMajor() =>
      displayBilledYearlyMajor ??
      (billedTotalMinor != null ? PaywallMoneyDisplay.wholeMajorFromMinor(billedTotalMinor!) : null);

  int? resolvedOriginalBilledYearlyMajor() {
    if (!hasDiscount || originalMinor <= discountedMinor) return null;
    return displayOriginalBilledYearlyMajor ?? PaywallMoneyDisplay.wholeMajorFromMinor(originalMinor);
  }

  int? resolvedOriginalPerMonthMajor({required bool yearlyPeriod}) {
    if (!hasDiscount || originalMinor <= discountedMinor) return null;
    if (yearlyPeriod) {
      return PaywallMoneyDisplay.wholeMajorPerMonthFromYearly(originalMinor);
    }
    return PaywallMoneyDisplay.wholeMajorFromMinor(originalMinor);
  }
}

class AppPaywallPackagePricing {
  const AppPaywallPackagePricing({this.monthly, this.yearly});

  final AppPaywallPeriodPricing? monthly;
  final AppPaywallPeriodPricing? yearly;

  AppPaywallPeriodPricing? forPeriod(String period) => period == 'yearly' ? yearly : monthly;
}

class AppPaywallPackageCtaLabels {
  const AppPaywallPackageCtaLabels({
    this.monthly,
    this.yearly,
    this.contact,
    this.upgrade,
  });

  final String? monthly;
  final String? yearly;
  final String? contact;
  final String? upgrade;

  String? forPeriod(String period) => switch (period) {
        'yearly' => yearly,
        _ => monthly,
      };
}

class AppPaywallPackage {
  const AppPaywallPackage({
    required this.slug,
    required this.name,
    this.slugShort,
    this.tagline,
    this.activeProjectCap,
    this.badgeType,
    this.badgeLabel,
    this.isRecommended = false,
    this.isCurrentPlan = false,
    required this.purchaseMode,
    this.contactUrl,
    this.contactCtaText,
    this.yearlyOnly = false,
    this.yearlyOnlyLabel,
    this.monthlyEnabled = false,
    this.yearlyEnabled = false,
    required this.pricing,
    this.yearlySavingsPercent,
    required this.ctaLabels,
    this.highlightBenefits = const [],
    this.comparisonValues = const {},
  });

  final String slug;
  final String name;
  final String? slugShort;
  final String? tagline;
  final int? activeProjectCap;
  final String? badgeType;
  final String? badgeLabel;
  final bool isRecommended;
  final bool isCurrentPlan;
  final String purchaseMode;
  final String? contactUrl;
  final String? contactCtaText;
  final bool yearlyOnly;
  final String? yearlyOnlyLabel;
  final bool monthlyEnabled;
  final bool yearlyEnabled;
  final AppPaywallPackagePricing pricing;
  final int? yearlySavingsPercent;
  final AppPaywallPackageCtaLabels ctaLabels;
  final List<AppPaywallBenefitItem> highlightBenefits;
  final Map<String, String> comparisonValues;

  bool get isContact => purchaseMode == 'contact';

  bool periodEnabled(String period) => period == 'yearly' ? yearlyEnabled : monthlyEnabled;

  /// Whether this package can be chosen while [billingPeriod] is selected on the paywall.
  bool selectableForBillingPeriod(String billingPeriod) {
    if (isContact) return true;
    return switch (billingPeriod) {
      'monthly' => monthlyEnabled,
      'yearly' => yearlyEnabled,
      _ => yearlyEnabled || monthlyEnabled,
    };
  }

  String? effectivePeriodWhen(String period) {
    if (isContact) return null;
    if (period == 'monthly' && !monthlyEnabled && yearlyEnabled) return 'yearly';
    if (period == 'yearly' && !yearlyEnabled && monthlyEnabled) return 'monthly';
    if (!periodEnabled(period)) return null;
    return period;
  }

  String resolveCta(String period) {
    if (isContact) {
      return contactCtaText ?? ctaLabels.contact ?? name;
    }
    final effective = effectivePeriodWhen(period) ?? period;
  return ctaLabels.forPeriod(effective) ?? name;
  }

  static AppPaywallPackage? fromJson(Map<String, dynamic> raw) {
    final slug = raw['slug'] as String?;
    final name = raw['name'] as String?;
    if (slug == null || name == null) return null;

    final pricingRaw = raw['pricing'];
    final pricingMap = pricingRaw is Map ? Map<String, dynamic>.from(pricingRaw) : const <String, dynamic>{};
    final highlightsRaw = raw['highlight_benefits'];
    final highlights = highlightsRaw is List
        ? highlightsRaw.map(AppPaywallBenefitItem.fromJson).whereType<AppPaywallBenefitItem>().toList()
        : <AppPaywallBenefitItem>[];

    final comparisonRaw = raw['comparison_values'];
    final comparison = <String, String>{};
    if (comparisonRaw is Map) {
      for (final entry in comparisonRaw.entries) {
        final v = entry.value;
        if (v == null) continue;
        comparison['${entry.key}'] = v.toString();
      }
    }

    final ctaRaw = raw['cta_labels'] as Map<String, dynamic>? ?? const {};
    return AppPaywallPackage(
      slug: slug,
      name: name,
      slugShort: raw['slug_short'] as String?,
      tagline: raw['tagline'] as String?,
      activeProjectCap: _readOptionalInt(raw['active_project_cap']),
      badgeType: raw['badge_type'] as String?,
      badgeLabel: raw['badge_label'] as String?,
      isRecommended: raw['is_recommended'] == true,
      isCurrentPlan: raw['is_current_plan'] == true,
      purchaseMode: raw['purchase_mode'] as String? ?? 'checkout',
      contactUrl: raw['contact_url'] as String?,
      contactCtaText: raw['contact_cta_text'] as String?,
      yearlyOnly: raw['yearly_only'] == true,
      yearlyOnlyLabel: raw['yearly_only_label'] as String?,
      monthlyEnabled: raw['monthly_enabled'] == true,
      yearlyEnabled: raw['yearly_enabled'] == true,
      pricing: AppPaywallPackagePricing(
        monthly: AppPaywallPeriodPricing.fromJson(pricingMap['monthly']),
        yearly: AppPaywallPeriodPricing.fromJson(pricingMap['yearly']),
      ),
      yearlySavingsPercent: _readOptionalInt(raw['yearly_savings_percent']),
      ctaLabels: AppPaywallPackageCtaLabels(
        monthly: ctaRaw['monthly'] as String?,
        yearly: ctaRaw['yearly'] as String?,
        contact: ctaRaw['contact'] as String?,
        upgrade: ctaRaw['upgrade'] as String?,
      ),
      highlightBenefits: highlights,
      comparisonValues: comparison,
    );
  }

  static AppPaywallPackage fromLegacyPlanMap(Map<String, dynamic> pkg, AppPaywallOffer? globalOffer) {
    final slug = pkg['slug'] as String? ?? 'premium';
    final name = pkg['name'] as String? ?? slug;
    final monthlyEnabled = pkg['monthly_enabled'] != false && pkg['price_monthly_minor'] != null;
    final yearlyEnabled = pkg['yearly_enabled'] != false && pkg['price_yearly_minor'] != null;

    final monthlyOriginal = _readOptionalInt(pkg['price_monthly_minor']) ?? 0;
    final yearlyOriginal = _readOptionalInt(pkg['price_yearly_minor']) ?? 0;
    final monthlyDiscounted = _readOptionalInt(pkg['price_monthly_discounted_minor']) ?? monthlyOriginal;
    final yearlyDiscounted =
        _readOptionalInt(pkg['price_yearly_discounted_minor']) ?? _readOptionalInt(pkg['yearly_billed_total_minor']) ?? yearlyOriginal;
    final yearlyPerMonth = _readOptionalInt(pkg['yearly_monthly_equivalent_minor']) ??
        (yearlyDiscounted > 0 ? (yearlyDiscounted / 12).round() : null);

    AppPaywallPeriodPricing? monthlyPricing;
    if (monthlyEnabled && monthlyOriginal > 0) {
      monthlyPricing = AppPaywallPeriodPricing(
        originalMinor: monthlyOriginal,
        discountedMinor: monthlyDiscounted,
        perMonthEquivalentMinor: monthlyDiscounted,
        hasDiscount: monthlyDiscounted < monthlyOriginal,
      );
    }

    AppPaywallPeriodPricing? yearlyPricing;
    if (yearlyEnabled && yearlyOriginal > 0) {
      yearlyPricing = AppPaywallPeriodPricing(
        originalMinor: yearlyOriginal,
        discountedMinor: yearlyDiscounted,
        perMonthEquivalentMinor: yearlyPerMonth ?? (yearlyDiscounted / 12).round(),
        billedTotalMinor: yearlyDiscounted,
        hasDiscount: yearlyDiscounted < yearlyOriginal,
      );
    }

    final benefitsRaw = pkg['benefits'];
    final highlights = benefitsRaw is List
        ? benefitsRaw
            .map((e) => AppPaywallBenefitItem.fromJson(e))
            .whereType<AppPaywallBenefitItem>()
            .toList()
        : <AppPaywallBenefitItem>[];

    return AppPaywallPackage(
      slug: slug,
      name: name,
      slugShort: slug.toUpperCase(),
      tagline: pkg['tagline'] as String?,
      badgeLabel: pkg['plan_badge'] as String? ?? pkg['badge_text'] as String?,
      isRecommended: pkg['is_recommended'] == true,
      purchaseMode: pkg['purchase_mode'] as String? ?? 'checkout',
      contactUrl: pkg['contact_url'] as String?,
      monthlyEnabled: monthlyEnabled,
      yearlyEnabled: yearlyEnabled,
      yearlyOnly: yearlyEnabled && !monthlyEnabled,
      pricing: AppPaywallPackagePricing(monthly: monthlyPricing, yearly: yearlyPricing),
      ctaLabels: AppPaywallPackageCtaLabels(
        contact: pkg['contact_cta_text'] as String?,
      ),
      highlightBenefits: highlights,
    );
  }

  /// Legacy single-object `plans` premium map (no slug list).
  static AppPaywallPackage fromLegacyPremiumObject(Map<String, dynamic> pkg, AppPaywallOffer? offer) {
    final withSlug = Map<String, dynamic>.from(pkg);
    withSlug['slug'] ??= 'premium';
    withSlug['name'] ??= 'Premium';
    withSlug['monthly_enabled'] ??= pkg['price_monthly_minor'] != null;
    withSlug['yearly_enabled'] ??= pkg['price_yearly_minor'] != null;
    if (offer != null) {
      if (offer.monthlyDiscountedMinor != null) {
        withSlug['price_monthly_discounted_minor'] ??= offer.monthlyDiscountedMinor;
        withSlug['price_monthly_minor'] ??= offer.monthlyOriginalMinor;
      }
      if (offer.yearlyDiscountedMinor != null) {
        withSlug['price_yearly_discounted_minor'] ??= offer.yearlyDiscountedMinor;
        withSlug['price_yearly_minor'] ??= offer.yearlyOriginalMinor;
      }
    }
    return fromLegacyPlanMap(withSlug, offer);
  }
}

int? _parseSortOrder(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  return null;
}

int _compareBySortOrder<T extends Object>(T a, T b) {
  final orderA = switch (a) {
    AppPaywallComparisonColumn c => c.sortOrder ?? 999,
    AppPaywallComparisonRow r => r.sortOrder ?? 999,
    _ => 999,
  };
  final orderB = switch (b) {
    AppPaywallComparisonColumn c => c.sortOrder ?? 999,
    AppPaywallComparisonRow r => r.sortOrder ?? 999,
    _ => 999,
  };
  final byOrder = orderA.compareTo(orderB);
  if (byOrder != 0) return byOrder;
  final keyA = switch (a) {
    AppPaywallComparisonColumn c => c.slug,
    AppPaywallComparisonRow r => r.key,
    _ => '',
  };
  final keyB = switch (b) {
    AppPaywallComparisonColumn c => c.slug,
    AppPaywallComparisonRow r => r.key,
    _ => '',
  };
  return keyA.compareTo(keyB);
}

class AppPaywallComparisonColumn {
  const AppPaywallComparisonColumn({
    required this.slug,
    required this.name,
    this.sortOrder,
  });

  final String slug;
  final String name;
  final int? sortOrder;

  static AppPaywallComparisonColumn? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final slug = raw['slug'] as String?;
    final name = raw['name'] as String?;
    if (slug == null || name == null) return null;
    return AppPaywallComparisonColumn(
      slug: slug,
      name: name,
      sortOrder: _parseSortOrder(raw['sort_order']),
    );
  }
}

class AppPaywallComparisonRow {
  const AppPaywallComparisonRow({
    required this.key,
    required this.label,
    this.sortOrder,
  });

  final String key;
  final String label;
  final int? sortOrder;

  static AppPaywallComparisonRow? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final key = raw['key'] as String?;
    final label = raw['label'] as String?;
    if (key == null || label == null) return null;
    return AppPaywallComparisonRow(
      key: key,
      label: label,
      sortOrder: _parseSortOrder(raw['sort_order']),
    );
  }
}

class AppPaywallComparisonTable {
  const AppPaywallComparisonTable({
    required this.columns,
    required this.rows,
    required this.cells,
  });

  final List<AppPaywallComparisonColumn> columns;
  final List<AppPaywallComparisonRow> rows;
  final Map<String, Map<String, String>> cells;

  static AppPaywallComparisonTable? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final columnsRaw = raw['columns'];
    final rowsRaw = raw['rows'];
  if (columnsRaw is! List || rowsRaw is! List) return null;

    final columns = columnsRaw.map(AppPaywallComparisonColumn.fromJson).whereType<AppPaywallComparisonColumn>().toList();
    if (columns.any((c) => c.sortOrder != null)) {
      columns.sort(_compareBySortOrder);
    }
    final rows = rowsRaw.map(AppPaywallComparisonRow.fromJson).whereType<AppPaywallComparisonRow>().toList();
    if (rows.any((r) => r.sortOrder != null)) {
      rows.sort(_compareBySortOrder);
    }
    if (columns.isEmpty || rows.isEmpty) return null;

    final cells = <String, Map<String, String>>{};
    final cellsRaw = raw['cells'];
    if (cellsRaw is Map) {
      for (final pkgEntry in cellsRaw.entries) {
        final map = <String, String>{};
        if (pkgEntry.value is Map) {
          for (final cell in (pkgEntry.value as Map).entries) {
            if (cell.value != null) map['${cell.key}'] = cell.value.toString();
          }
        }
        cells['${pkgEntry.key}'] = map;
      }
    }

    return AppPaywallComparisonTable(columns: columns, rows: rows, cells: cells);
  }
}

class AppPaywallFooter {
  const AppPaywallFooter({
    this.reassurance,
    this.termsUrl,
    this.privacyUrl,
    this.restorePurchaseVisible = false,
  });

  final String? reassurance;
  final String? termsUrl;
  final String? privacyUrl;
  final bool restorePurchaseVisible;

  static AppPaywallFooter fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return const AppPaywallFooter();
    return AppPaywallFooter(
      reassurance: raw['reassurance'] as String?,
      termsUrl: raw['terms_url'] as String?,
      privacyUrl: raw['privacy_url'] as String?,
      restorePurchaseVisible: raw['restore_purchase_visible'] == true,
    );
  }
}

class AppPaywallContext {
  const AppPaywallContext({
    required this.currentPackageSlug,
    required this.currentPackageName,
    this.freeContextTemplate,
    this.detailText,
    this.contextLine,
  });

  final String currentPackageSlug;
  final String currentPackageName;
  final String? freeContextTemplate;
  final String? detailText;
  final String? contextLine;

  String? resolvedLine() {
    final direct = contextLine?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    return formattedContextLine();
  }

  String? formattedContextLine({String? detailOverride}) {
    final detail = (detailOverride ?? detailText ?? '').trim();
    final template = freeContextTemplate;
    if (template == null || template.isEmpty) {
      if (detail.isEmpty) return currentPackageName;
      return '$currentPackageName · $detail';
    }
    var line = template.replaceAll('{plan}', currentPackageName);
    if (detail.isEmpty) {
      line = line
          .replaceAll('· {detail}', '')
          .replaceAll('{detail}', '')
          .replaceAll(RegExp(r'\s*·\s*$'), '')
          .trim();
      return line.isEmpty ? null : line;
    }
    return line.replaceAll('{detail}', detail);
  }

  static AppPaywallContext? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return AppPaywallContext(
      currentPackageSlug: raw['current_package_slug'] as String? ?? 'free',
      currentPackageName: raw['current_package_name'] as String? ?? 'Free',
      freeContextTemplate: raw['free_context_template'] as String?,
      detailText: raw['detail_text'] as String?,
      contextLine: raw['context_line'] as String?,
    );
  }
}

class AppPaywallV3Data {
  const AppPaywallV3Data({
    required this.trigger,
    required this.header,
    required this.benefitItems,
    this.socialProof,
    this.offerBanner,
    required this.billing,
    required this.packages,
    this.comparisonTable,
    required this.footer,
    this.context,
    this.recommendedPackageSlug,
    this.primaryCta,
    this.continueFreeCta,
  });

  final String trigger;
  final AppPaywallHeader header;
  final List<AppPaywallBenefitItem> benefitItems;
  final AppPaywallSocialProof? socialProof;
  final AppPaywallOfferBanner? offerBanner;
  final AppPaywallBilling billing;
  final List<AppPaywallPackage> packages;
  final AppPaywallComparisonTable? comparisonTable;
  final AppPaywallFooter footer;
  final AppPaywallContext? context;
  final String? recommendedPackageSlug;
  final String? primaryCta;
  final String? continueFreeCta;

  AppPaywallPackage? packageBySlug(String slug) {
    for (final pkg in packages) {
      if (pkg.slug == slug) return pkg;
    }
    return null;
  }

  String initialPackageSlug() {
    final recommended = recommendedPackageSlug;
    if (recommended != null && packageBySlug(recommended) != null) return recommended;
    for (final pkg in packages) {
      if (!pkg.isCurrentPlan) return pkg.slug;
    }
    return packages.isNotEmpty ? packages.first.slug : '';
  }

  String initialBillingPeriod() {
    for (final pkg in packages) {
      if (pkg.yearlyEnabled) return 'yearly';
    }
    for (final pkg in packages) {
      if (pkg.monthlyEnabled) return 'monthly';
    }
    return 'yearly';
  }

  /// First package slug selectable for [billingPeriod], preferring [recommendedPackageSlug].
  String? firstSelectablePackageSlugForPeriod(String billingPeriod) {
    final candidates = <String>[];
    final rec = recommendedPackageSlug;
    if (rec != null) {
      final pkg = packageBySlug(rec);
      if (pkg != null && pkg.selectableForBillingPeriod(billingPeriod)) {
        candidates.add(rec);
      }
    }
    for (final pkg in packages) {
      if (pkg.selectableForBillingPeriod(billingPeriod) && !candidates.contains(pkg.slug)) {
        candidates.add(pkg.slug);
      }
    }
    return candidates.isEmpty ? null : candidates.first;
  }

  List<AppPaywallBenefitItem> benefitsForPackage(AppPaywallPackage pkg) {
    if (pkg.highlightBenefits.isNotEmpty) return pkg.highlightBenefits;
    return benefitItems;
  }

  static AppPaywallV3Data? parse(Map<String, dynamic> raw, {String localeCode = 'ar'}) {
    final offer = AppPaywallOffer.fromJson(raw['offer']);
    final packages = _parsePackages(raw, offer);
    if (packages.isEmpty) return null;

    final header = AppPaywallHeader.fromJson(
      raw['header'],
      fallbackTitle: raw['title'] as String? ?? '',
      fallbackSubtitle: raw['subtitle'] as String? ?? '',
    );
    if (header.title.isEmpty) return null;

    final benefitItems = _parseBenefitItems(raw);
    final offerBanner =
        AppPaywallOfferBanner.fromJson(raw['offer_banner']) ?? AppPaywallOfferBanner.fromJson(raw['offer']);

    return AppPaywallV3Data(
      trigger: raw['trigger'] as String? ?? 'default',
      header: header,
      benefitItems: benefitItems,
      socialProof: AppPaywallSocialProof.fromJson(raw['social_proof']),
      offerBanner: offerBanner,
      billing: AppPaywallBilling.fromJson(raw['billing'], localeCode: localeCode),
      packages: packages,
      comparisonTable: AppPaywallComparisonTable.fromJson(raw['comparison_table']),
      footer: AppPaywallFooter.fromJson(raw['footer']),
      context: AppPaywallContext.fromJson(raw['context']),
      recommendedPackageSlug: raw['recommended_package_slug'] as String?,
      primaryCta:
          raw['primary_cta'] as String? ??
          raw['cta_subscribe_label'] as String? ??
          raw['subscribe_cta'] as String?,
      continueFreeCta: raw['cta_continue_free_label'] as String? ?? raw['continue_free_cta'] as String?,
    );
  }

  static List<AppPaywallPackage> _parsePackages(Map<String, dynamic> raw, AppPaywallOffer? offer) {
    final packagesRaw = raw['packages'];
    if (packagesRaw is List) {
      return packagesRaw
          .whereType<Map<String, dynamic>>()
          .map(AppPaywallPackage.fromJson)
          .whereType<AppPaywallPackage>()
          .toList();
    }

    final plansRaw = raw['plans'];
    if (plansRaw is List) {
      return plansRaw
          .whereType<Map<String, dynamic>>()
          .where(_isPremiumPackageMap)
          .map((m) => AppPaywallPackage.fromLegacyPlanMap(m, offer))
          .toList();
    }
    if (plansRaw is Map<String, dynamic> && _isPremiumPackageMap(plansRaw)) {
      return [AppPaywallPackage.fromLegacyPremiumObject(plansRaw, offer)];
    }
    return const [];
  }

  static List<AppPaywallBenefitItem> _parseBenefitItems(Map<String, dynamic> raw) {
    final itemsRaw = raw['benefit_items'];
    if (itemsRaw is List) {
      return itemsRaw.map(AppPaywallBenefitItem.fromJson).whereType<AppPaywallBenefitItem>().toList();
    }
    final legacy = raw['benefits'];
    if (legacy is List) {
      return legacy.map(AppPaywallBenefitItem.fromJson).whereType<AppPaywallBenefitItem>().toList();
    }
    return const [];
  }
}

bool _isPremiumPackageMap(Map<String, dynamic> json) {
  final id = json['id'] as String? ?? json['slug'] as String?;
  if (id == 'yearly' || id == 'monthly') return false;
  if (json['price_monthly_minor'] != null || json['price_yearly_minor'] != null) {
    return true;
  }
  return id == 'premium' || json.containsKey('purchase_mode');
}

int? _readOptionalInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return null;
}