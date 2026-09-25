import '../../core/constants/store_product_ids.dart';
import 'revenuecat_service_stub.dart'
    if (dart.library.io) 'revenuecat_service_mobile.dart' as impl;

/// Fasada RevenueCat – na webie no-op, na iOS/Android prawdziwy IAP.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  Future<void> initialize() => impl.initializeRevenueCat();

  Future<void> logIn(String userId) => impl.logInRevenueCat(userId);

  Future<void> logOut() => impl.logOutRevenueCat();

  /// Kupno planu IAP. Zwraca true jeśli entitlement premium aktywny.
  Future<bool> purchasePlan({required StorePremiumPlan plan}) =>
      impl.purchaseRevenueCatPlan(plan: plan);

  Future<bool> restorePurchases() => impl.restoreRevenueCatPurchases();

  /// iPhone: systemowa karta Apple. Na pozostałych platformach nic nie robi.
  Future<void> presentAppleOfferCodeSheet() => impl.presentAppleOfferCodeSheet();

  /// Ceny z aktualnej oferty RevenueCat (sklep). Null gdy niedostępne.
  Future<IapPlanPrices?> loadPlanPrices() => impl.loadRevenueCatPlanPrices();

  bool get isSupported => impl.isRevenueCatSupported;
}
