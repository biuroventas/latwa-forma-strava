import '../../core/constants/store_product_ids.dart';

/// Stub web / brak IAP.
Future<void> initializeRevenueCat() async {}

Future<void> logInRevenueCat(String userId) async {}

Future<void> logOutRevenueCat() async {}

Future<bool> purchaseRevenueCatPlan({required StorePremiumPlan plan}) async =>
    false;

Future<bool> restoreRevenueCatPurchases() async => false;

Future<void> presentAppleOfferCodeSheet() async {}

Future<IapPlanPrices?> loadRevenueCatPlanPrices() async => null;

bool get isRevenueCatSupported => false;
