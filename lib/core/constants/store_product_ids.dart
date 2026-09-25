/// Identyfikatory produktów IAP (Play / App Store / RevenueCat).
/// Muszą być zgodne z docs/REVENUECAT.md.
class StoreProductIds {
  StoreProductIds._();

  static const monthly = 'premium_monthly';
  static const yearly = 'premium_yearly';

  /// Rok jednorazowo (bez auto-odnawiania). Web: Stripe/BLIK. Mobile: IAP sklepu.
  static const yearlyOnce = 'premium_yearly_once';

  /// Entitlement w RevenueCat.
  static const premiumEntitlement = 'premium';

  /// Ceny Premium wszędzie – 69,99 / 194,99 zł.
  static const monthlyPriceLabel = '69,99 zł';
  static const yearlyPriceLabel = '194,99 zł';
  static const yearlyPerMonthLabel =
      'w przeliczeniu ok. 16,25 zł / mies. (płatność raz na rok)';
}

/// Plan zakupu IAP (mobile).
enum StorePremiumPlan { monthly, yearly, yearlyOnce }

/// Ceny pakietów z oferty RevenueCat (lokalizacja sklepu).
class IapPlanPrices {
  const IapPlanPrices({
    required this.monthlyLabel,
    required this.yearlyLabel,
    this.yearlyOnceLabel,
    this.yearlyPerMonthLabel,
  });

  final String monthlyLabel;
  final String yearlyLabel;
  final String? yearlyOnceLabel;
  final String? yearlyPerMonthLabel;
}
