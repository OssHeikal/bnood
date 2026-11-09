import 'package:flutter/material.dart';

import '../money/remote_money_units.dart';
import 'subscription_colors.dart';

class AppSubscriptionEntitlements {
  const AppSubscriptionEntitlements({
    required this.packageSlug,
    required this.packageName,
    required this.isPremium,
    this.premiumAvatarFlag,
    this.premiumAvatarColorHex,
    this.expiresAt,
    this.daysRemaining,
    required this.subscriptionStatus,
    required this.activeProjectsCount,
    required this.activeProjectCap,
    required this.canCreateActiveProject,
    required this.canMutateFinancialTransactions,
    required this.canArchiveClient,
    required this.showPaywallSurfaces,
    required this.isExpiredPremium,
  });

  final String packageSlug;
  final String packageName;
  final bool isPremium;
  final bool? premiumAvatarFlag;
  final String? premiumAvatarColorHex;
  final DateTime? expiresAt;
  final int? daysRemaining;
  final String subscriptionStatus;
  final int activeProjectsCount;
  final int? activeProjectCap;
  final bool canCreateActiveProject;
  final bool canMutateFinancialTransactions;
  final bool canArchiveClient;
  final bool showPaywallSurfaces;
  final bool isExpiredPremium;

  bool get showPremiumAvatar => premiumAvatarFlag == true || (isPremium && !isExpiredPremium);

  Color get premiumAvatarColor => SubscriptionColors.parsePremiumAvatar(premiumAvatarColorHex);

  static AppSubscriptionEntitlements fromJson(Map<String, dynamic> json) {
    DateTime? expires;
    final rawExpiry = json['expires_at'];
    if (rawExpiry is String && rawExpiry.isNotEmpty) {
      expires = DateTime.tryParse(rawExpiry)?.toLocal();
    }
    int? daysRemaining;
    final rawDays = json['days_remaining'];
    if (rawDays is int) {
      daysRemaining = rawDays;
    } else if (rawDays is num) {
      daysRemaining = rawDays.round();
    }

    int readInt(Object? v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is num) return v.round();
      return fallback;
    }

    bool readBool(Object? v, {bool fallback = false}) {
      if (v is bool) return v;
      return fallback;
    }

    bool? premiumAvatarFlag;
    String? premiumAvatarColorHex;
    final rawPremiumAvatar = json['premium_avatar'];
    if (rawPremiumAvatar is bool) {
      premiumAvatarFlag = rawPremiumAvatar;
    } else if (rawPremiumAvatar is String && rawPremiumAvatar.trim().isNotEmpty) {
      premiumAvatarColorHex = rawPremiumAvatar.trim();
      premiumAvatarFlag = true;
    }

    return AppSubscriptionEntitlements(
      packageSlug: json['package_slug'] as String? ?? 'free',
      packageName: json['package_name'] as String? ?? 'Free',
      isPremium: readBool(json['is_premium']),
      premiumAvatarFlag: premiumAvatarFlag,
      premiumAvatarColorHex: premiumAvatarColorHex,
      expiresAt: expires,
      daysRemaining: daysRemaining,
      subscriptionStatus: json['subscription_status'] as String? ?? 'free',
      activeProjectsCount: readInt(json['active_projects_count']),
      activeProjectCap: json['active_project_cap'] is int
          ? json['active_project_cap'] as int
          : json['active_project_cap'] is num
          ? (json['active_project_cap'] as num).round()
          : null,
      canCreateActiveProject: readBool(json['can_create_active_project'], fallback: true),
      canMutateFinancialTransactions: readBool(json['can_mutate_financial_transactions'], fallback: true),
      canArchiveClient: readBool(json['can_archive_client'], fallback: true),
      showPaywallSurfaces: readBool(json['show_paywall_surfaces'], fallback: true),
      isExpiredPremium: readBool(json['is_expired_premium']),
    );
  }
}

class AppPaywallOffer {
  const AppPaywallOffer({
    required this.title,
    this.subtitle,
    this.yearlySavingsBadge,
    this.monthlyOriginalMinor,
    this.monthlyDiscountedMinor,
    this.yearlyOriginalMinor,
    this.yearlyDiscountedMinor,
  });

  final String title;
  final String? subtitle;
  final String? yearlySavingsBadge;
  final int? monthlyOriginalMinor;
  final int? monthlyDiscountedMinor;
  final int? yearlyOriginalMinor;
  final int? yearlyDiscountedMinor;

  static AppPaywallOffer? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final title = raw['title'] as String?;
    if (title == null || title.isEmpty) return null;
    return AppPaywallOffer(
      title: title,
      subtitle: raw['subtitle'] as String?,
      yearlySavingsBadge:
          raw['badge_text'] as String? ?? raw['yearly_savings_badge'] as String? ?? raw['savings_badge'] as String?,
      monthlyOriginalMinor: _readOptionalMinor(raw['monthly_original_minor']),
      monthlyDiscountedMinor: _readOptionalMinor(raw['monthly_discounted_minor']),
      yearlyOriginalMinor: _readOptionalMinor(raw['yearly_original_minor']),
      yearlyDiscountedMinor: _readOptionalMinor(raw['yearly_discounted_minor']),
    );
  }
}

int? _readOptionalMinor(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return null;
}

class AppPaywallPlan {
  const AppPaywallPlan({
    required this.id,
    required this.label,
    required this.monthlyEquivalentMinor,
    this.totalBilledMinor,
    this.billedCaption,
    this.originalMonthlyEquivalentMinor,
    this.savingsBadge,
  });

  final String id;
  final String label;
  final int monthlyEquivalentMinor;
  final int? totalBilledMinor;
  final String? billedCaption;
  final int? originalMonthlyEquivalentMinor;
  final String? savingsBadge;

  bool get isYearly => id == 'yearly';

  static AppPaywallPlan fromJson(Map<String, dynamic> json) {
    int? readOptionalMinor(Object? v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.round();
      return null;
    }

    final id = json['id'] as String? ?? json['slug'] as String? ?? 'monthly';
    var monthlyEq =
        readOptionalMinor(json['monthly_equivalent_minor']) ??
        readOptionalMinor(json['price_minor']) ??
        readOptionalMinor(json['display_price_minor']);

    final total =
        readOptionalMinor(json['total_minor']) ??
        readOptionalMinor(json['billed_minor']) ??
        readOptionalMinor(json['yearly_total_minor']);

    if (monthlyEq == null && total != null && id == 'yearly') {
      monthlyEq = (total / 12).round();
    }
    monthlyEq ??= 0;

    return AppPaywallPlan(
      id: id,
      label: json['label'] as String? ?? id,
      monthlyEquivalentMinor: monthlyEq,
      totalBilledMinor: total,
      billedCaption: json['billed_caption'] as String?,
      originalMonthlyEquivalentMinor:
          readOptionalMinor(json['original_monthly_equivalent_minor']) ??
          readOptionalMinor(json['original_price_minor']),
      savingsBadge: json['savings_badge'] as String?,
    );
  }

  String formatMonthlyMajor() => _formatMajor(monthlyEquivalentMinor);

  String? formatOriginalMonthlyMajor() =>
      originalMonthlyEquivalentMinor == null ? null : _formatMajor(originalMonthlyEquivalentMinor!);

  String? formatTotalBilledMajor() => totalBilledMinor == null ? null : _formatMajor(totalBilledMinor!);

  static String _formatMajor(int minor) {
    final major = RemoteMoneyUnits.minorToMajor(minor);
    return major.toString();
  }
}

class AppPaywallContent {
  const AppPaywallContent({
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.subscribeCta,
    required this.continueFreeCta,
    required this.legal,
    required this.plans,
    this.offer,
  });

  final String title;
  final String subtitle;
  final List<String> benefits;
  final String subscribeCta;
  final String continueFreeCta;
  final String legal;
  final List<AppPaywallPlan> plans;
  final AppPaywallOffer? offer;

  AppPaywallPlan? planById(String id) {
    for (final plan in plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  static AppPaywallContent? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final benefitsRaw = raw['benefits'];
    final benefits = benefitsRaw is List
        ? benefitsRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : const <String>[];
    final offer = AppPaywallOffer.fromJson(raw['offer']);
    final plans = _parsePaywallPlans(raw['plans'], offer);

    final title = raw['title'] as String?;
    if (title == null || title.isEmpty) return null;

    return AppPaywallContent(
      title: title,
      subtitle: raw['subtitle'] as String? ?? '',
      benefits: benefits,
      subscribeCta:
          raw['cta_subscribe_label'] as String? ??
          raw['subscribe_cta'] as String? ??
          raw['cta_subscribe'] as String? ??
          '',
      continueFreeCta:
          raw['cta_continue_free_label'] as String? ??
          raw['continue_free_cta'] as String? ??
          raw['cta_continue_free'] as String? ??
          '',
      legal: raw['legal'] as String? ?? '',
      plans: plans,
      offer: offer,
    );
  }
}

List<AppPaywallPlan> _parsePaywallPlans(Object? raw, AppPaywallOffer? offer) {
  if (raw is List) {
    final out = <AppPaywallPlan>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      if (_isPremiumPackageMap(item)) {
        out.addAll(_plansFromPremiumPackage(item, offer));
      } else {
        out.add(AppPaywallPlan.fromJson(item));
      }
    }
    return _orderYearlyThenMonthly(out);
  }
  if (raw is Map<String, dynamic>) {
    if (_isPremiumPackageMap(raw)) {
      return _plansFromPremiumPackage(raw, offer);
    }
    final single = AppPaywallPlan.fromJson(raw);
    return _orderYearlyThenMonthly([single]);
  }
  return const [];
}

bool _isPremiumPackageMap(Map<String, dynamic> json) {
  final id = json['id'] as String? ?? json['slug'] as String?;
  if (id == 'yearly' || id == 'monthly') return false;
  if (json['price_monthly_minor'] != null || json['price_yearly_minor'] != null) {
    return true;
  }
  return id == 'premium';
}

List<AppPaywallPlan> _orderYearlyThenMonthly(List<AppPaywallPlan> plans) {
  AppPaywallPlan? yearly;
  AppPaywallPlan? monthly;
  final rest = <AppPaywallPlan>[];
  for (final plan in plans) {
    if (plan.id == 'yearly' && yearly == null) {
      yearly = plan;
    } else if (plan.id == 'monthly' && monthly == null) {
      monthly = plan;
    } else {
      rest.add(plan);
    }
  }
  return [?yearly, ?monthly, ...rest];
}

List<AppPaywallPlan> _plansFromPremiumPackage(Map<String, dynamic> pkg, AppPaywallOffer? offer) {
  final name = pkg['name'] as String? ?? pkg['slug'] as String? ?? 'Premium';
  final badge = pkg['badge_text'] as String? ?? offer?.yearlySavingsBadge;

  final priceMonthly = _readOptionalMinor(pkg['price_monthly_minor']);
  final priceMonthlyDiscounted = _readOptionalMinor(pkg['price_monthly_discounted_minor']);
  final priceYearly = _readOptionalMinor(pkg['price_yearly_minor']);
  final priceYearlyDiscounted = _readOptionalMinor(pkg['price_yearly_discounted_minor']);
  final yearlyBilledTotal = _readOptionalMinor(pkg['yearly_billed_total_minor']);
  final yearlyMonthlyEqField = _readOptionalMinor(pkg['yearly_monthly_equivalent_minor']);

  final hasMonthlyPromo =
      offer?.monthlyDiscountedMinor != null ||
      (priceMonthlyDiscounted != null && priceMonthly != null && priceMonthlyDiscounted != priceMonthly);
  var monthlyDisplay = offer?.monthlyDiscountedMinor ?? priceMonthlyDiscounted ?? priceMonthly ?? 0;
  int? monthlyOriginal;
  if (hasMonthlyPromo) {
    final list = offer?.monthlyOriginalMinor ?? priceMonthly;
    if (list != null && list != monthlyDisplay) {
      monthlyOriginal = list;
    }
  }

  final yearlyBilled = offer?.yearlyDiscountedMinor ?? priceYearlyDiscounted ?? yearlyBilledTotal ?? priceYearly;
  final hasYearlyPromo =
      offer?.yearlyDiscountedMinor != null ||
      (priceYearlyDiscounted != null && priceYearly != null && priceYearlyDiscounted != priceYearly);

  int yearlyMonthlyDisplay;
  if (offer?.yearlyDiscountedMinor != null) {
    yearlyMonthlyDisplay = (offer!.yearlyDiscountedMinor! / 12).round();
  } else if (priceYearlyDiscounted != null && hasYearlyPromo) {
    yearlyMonthlyDisplay = (priceYearlyDiscounted / 12).round();
  } else if (yearlyMonthlyEqField != null) {
    yearlyMonthlyDisplay = yearlyMonthlyEqField;
  } else if (yearlyBilled != null) {
    yearlyMonthlyDisplay = (yearlyBilled / 12).round();
  } else {
    yearlyMonthlyDisplay = 0;
  }

  int? yearlyMonthlyOriginal;
  if (hasYearlyPromo) {
    final listTotal = offer?.yearlyOriginalMinor ?? priceYearly;
    if (listTotal != null) {
      yearlyMonthlyOriginal = offer?.yearlyOriginalMinor != null
          ? (offer!.yearlyOriginalMinor! / 12).round()
          : (listTotal / 12).round();
      if (yearlyMonthlyOriginal == yearlyMonthlyDisplay) {
        yearlyMonthlyOriginal = null;
      }
    }
  }

  final monthlyPlan = AppPaywallPlan(
    id: 'monthly',
    label: pkg['monthly_label'] as String? ?? 'monthly',
    monthlyEquivalentMinor: monthlyDisplay,
    originalMonthlyEquivalentMinor: monthlyOriginal,
  );

  final yearlyPlan = AppPaywallPlan(
    id: 'yearly',
    label: pkg['yearly_label'] as String? ?? 'yearly',
    monthlyEquivalentMinor: yearlyMonthlyDisplay,
    totalBilledMinor: yearlyBilled,
    originalMonthlyEquivalentMinor: yearlyMonthlyOriginal,
    savingsBadge: badge,
  );

  return [yearlyPlan, monthlyPlan];
}

class AppSubscriptionSnapshot {
  const AppSubscriptionSnapshot({required this.paywallEnabled, required this.entitlements, this.paywall});

  final bool paywallEnabled;
  final AppSubscriptionEntitlements entitlements;
  final AppPaywallContent? paywall;

  bool get showSurfaces => paywallEnabled && entitlements.showPaywallSurfaces;

  bool get shouldShowProfileSubscriptionCard => showSurfaces;

  static AppSubscriptionSnapshot fromDataJson(Map<String, dynamic> json) {
    return AppSubscriptionSnapshot(
      paywallEnabled: json['paywall_enabled'] == true,
      entitlements: AppSubscriptionEntitlements.fromJson((json['entitlements'] as Map<String, dynamic>?) ?? const {}),
      paywall: AppPaywallContent.fromJson(json['paywall']),
    );
  }
}
