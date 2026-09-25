import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/store_product_ids.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

bool _initialized = false;

Future<void> initializeRevenueCat() async {
  if (kIsWeb || _initialized) return;

  final iosKey = (SupabaseConfig.getEnv('REVENUECAT_IOS_API_KEY') ?? '')
      .trim();
  final androidKey = (SupabaseConfig.getEnv('REVENUECAT_ANDROID_API_KEY') ?? '')
      .trim();

  final apiKey = Platform.isIOS
      ? iosKey
      : (Platform.isAndroid ? androidKey : '');
  if (apiKey.isEmpty) {
    debugPrint('⚠️ RevenueCat: brak REVENUECAT_IOS_API_KEY / REVENUECAT_ANDROID_API_KEY');
    return;
  }

  try {
    final configuration = PurchasesConfiguration(apiKey);
    await Purchases.configure(configuration);
    _initialized = true;
    debugPrint('✅ RevenueCat zainicjalizowane');

    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId != null && !(SupabaseConfig.auth.currentUser?.isAnonymous ?? true)) {
      await logInRevenueCat(userId);
    }
  } catch (e, st) {
    debugPrint('❌ RevenueCat init: $e\n$st');
  }
}

Future<void> logInRevenueCat(String userId) async {
  if (!_initialized || userId.isEmpty) return;
  try {
    await Purchases.logIn(userId);
  } catch (e) {
    debugPrint('⚠️ RevenueCat logIn: $e');
  }
}

Future<void> logOutRevenueCat() async {
  if (!_initialized) return;
  try {
    await Purchases.logOut();
  } catch (e) {
    debugPrint('⚠️ RevenueCat logOut: $e');
  }
}

Future<bool> purchaseRevenueCatPlan({required StorePremiumPlan plan}) async {
  if (!_initialized) {
    throw StateError(lookupAppLocalizations(currentAppLocale()).premStoreNotReady);
  }

  final offerings = await Purchases.getOfferings();
  final current = offerings.current;
  if (current == null) {
    throw StateError('Brak oferty RevenueCat (Offerings → Current).');
  }

  final package = _packageForPlan(current, plan);
  if (package == null) {
    throw StateError(
      'Nie znaleziono pakietu (${_productIdForPlan(plan)}). '
      'Dodaj produkt w App Store / Play i w ofercie RevenueCat.',
    );
  }

  final result = await Purchases.purchase(PurchaseParams.package(package));
  return _hasPremium(result.customerInfo);
}

Future<bool> restoreRevenueCatPurchases() async {
  if (!_initialized) return false;
  final info = await Purchases.restorePurchases();
  return _hasPremium(info);
}

/// Pusta karta Apple do wpisania kodu oferty. Kod nie jest podawany przez aplikację.
Future<void> presentAppleOfferCodeSheet() async {
  if (!Platform.isIOS) return;
  await Purchases.presentCodeRedemptionSheet();
}

Future<IapPlanPrices?> loadRevenueCatPlanPrices() async {
  if (!_initialized) return null;
  try {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return null;

    final monthly = _packageForPlan(current, StorePremiumPlan.monthly);
    final yearly = _packageForPlan(current, StorePremiumPlan.yearly);
    final yearlyOnce = _packageForPlan(current, StorePremiumPlan.yearlyOnce);

    final monthlyLabel = monthly?.storeProduct.priceString;
    final yearlyProduct = yearly?.storeProduct;
    final yearlyLabel = yearlyProduct?.priceString;
    final yearlyOnceLabel = yearlyOnce?.storeProduct.priceString;
    if (monthlyLabel == null && yearlyLabel == null && yearlyOnceLabel == null) {
      return null;
    }

    String? yearlyPerMonthLabel;
    if (yearlyProduct != null && yearlyProduct.price > 0) {
      final perMonth = yearlyProduct.price / 12;
      final code = yearlyProduct.currencyCode.toUpperCase();
      final unit = code == 'PLN' ? 'zł' : code;
      final amount = perMonth.toStringAsFixed(2).replaceAll('.', ',');
      final l10n = lookupAppLocalizations(currentAppLocale());
      yearlyPerMonthLabel = l10n.premAboutPerMonth(amount: amount, unit: unit);
    }

    return IapPlanPrices(
      monthlyLabel: monthlyLabel ?? StoreProductIds.monthlyPriceLabel,
      yearlyLabel: yearlyLabel ?? StoreProductIds.yearlyPriceLabel,
      yearlyOnceLabel: yearlyOnceLabel,
      yearlyPerMonthLabel: yearlyPerMonthLabel,
    );
  } catch (e) {
    debugPrint('⚠️ RevenueCat prices: $e');
    return null;
  }
}

bool get isRevenueCatSupported => !kIsWeb && _initialized;

bool _hasPremium(CustomerInfo info) {
  final ent = info.entitlements.all[StoreProductIds.premiumEntitlement];
  return ent?.isActive == true;
}

String _productIdForPlan(StorePremiumPlan plan) {
  switch (plan) {
    case StorePremiumPlan.monthly:
      return StoreProductIds.monthly;
    case StorePremiumPlan.yearly:
      return StoreProductIds.yearly;
    case StorePremiumPlan.yearlyOnce:
      return StoreProductIds.yearlyOnce;
  }
}

Package? _packageForPlan(Offering offering, StorePremiumPlan plan) {
  switch (plan) {
    case StorePremiumPlan.monthly:
      return offering.monthly ??
          offering.getPackage(StoreProductIds.monthly) ??
          _findPackage(offering, StoreProductIds.monthly);
    case StorePremiumPlan.yearly:
      return offering.annual ??
          offering.getPackage(StoreProductIds.yearly) ??
          _findPackage(offering, StoreProductIds.yearly);
    case StorePremiumPlan.yearlyOnce:
      return offering.getPackage(StoreProductIds.yearlyOnce) ??
          offering.getPackage('yearly_once') ??
          _findPackage(offering, StoreProductIds.yearlyOnce);
  }
}

Package? _findPackage(Offering offering, String productId) {
  for (final p in offering.availablePackages) {
    if (p.storeProduct.identifier == productId) return p;
  }
  return null;
}
