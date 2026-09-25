import 'package:latwa_forma/l10n/app_localizations.dart';

/// Opcje „Jem na mieście” – szybkie dodawanie posiłków z restauracji.
class EatingOutOption {
  final String id;
  final int minKcal;
  final int maxKcal;
  final int defaultKcal; // wartość domyślna (średnia)
  final String icon; // emoji lub nazwa ikony
  /// true = kalorie są na kawałek (np. pizza), można podać ilość kawałków
  final bool supportsSlices;

  const EatingOutOption({
    required this.id,
    required this.minKcal,
    required this.maxKcal,
    required this.defaultKcal,
    required this.icon,
    this.supportsSlices = false,
  });

  String localizedName(AppLocalizations l10n) {
    switch (id) {
      case 'pizza':
        return l10n.trackEatingOutPizza;
      case 'kebab':
        return l10n.trackEatingOutKebab;
      case 'burger':
        return l10n.trackEatingOutBurger;
      case 'chinese':
        return l10n.trackEatingOutChinese;
      case 'mcd_cheeseburger':
        return l10n.trackEatingOutMcdCheeseburger;
      case 'mcd_2foryou':
        return l10n.trackEatingOutMcd2ForYou;
      case 'mcd_bigmac':
        return l10n.trackEatingOutMcdBigMac;
      case 'mcd_mcdouble':
        return l10n.trackEatingOutMcdMcDouble;
      case 'mcd_fries':
        return l10n.trackEatingOutMcdSmallFries;
      case 'mcd_medium_fries':
        return l10n.trackEatingOutMcdMediumFries;
      case 'kfc_drumstick':
        return l10n.trackEatingOutKfcDrumstick;
      case 'kfc_tenders':
        return l10n.trackEatingOutKfcTenders;
      case 'subway_6in':
        return l10n.trackEatingOutSubway6;
      case 'subway_footlong':
        return l10n.trackEatingOutSubwayFootlong;
      default:
        return id;
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (id) {
      case 'pizza':
        return l10n.trackEatingOutPizzaLabel;
      case 'kebab':
        return l10n.trackEatingOutKebabLabel;
      case 'burger':
        return l10n.trackEatingOutBurgerLabel;
      case 'chinese':
        return l10n.trackEatingOutChineseLabel;
      case 'mcd_cheeseburger':
        return l10n.trackEatingOutMcdCheeseburgerLabel;
      case 'mcd_2foryou':
        return l10n.trackEatingOutMcd2ForYouLabel;
      case 'mcd_bigmac':
        return l10n.trackEatingOutMcdBigMacLabel;
      case 'mcd_mcdouble':
        return l10n.trackEatingOutMcdMcDoubleLabel;
      case 'mcd_fries':
        return l10n.trackEatingOutMcdSmallFriesLabel;
      case 'mcd_medium_fries':
        return l10n.trackEatingOutMcdMediumFriesLabel;
      case 'kfc_drumstick':
        return l10n.trackEatingOutKfcDrumstickLabel;
      case 'kfc_tenders':
        return l10n.trackEatingOutKfcTendersLabel;
      case 'subway_6in':
        return l10n.trackEatingOutSubway6Label;
      case 'subway_footlong':
        return l10n.trackEatingOutSubwayFootlongLabel;
      default:
        return '';
    }
  }

  /// Szacowane makroskładniki (przybliżenie dla typowej porcji).
  Map<String, double> getEstimatedMacros({int slices = 1}) {
    final mult = supportsSlices ? slices : 1;
    switch (id) {
      case 'kebab':
        return {'protein': 35.0 * mult, 'fat': 45.0 * mult, 'carbs': 55.0 * mult};
      case 'pizza':
        return {'protein': 25.0 * mult, 'fat': 35.0 * mult, 'carbs': 90.0 * mult};
      case 'burger':
        return {'protein': 30.0 * mult, 'fat': 40.0 * mult, 'carbs': 50.0 * mult};
      case 'chinese':
        return {'protein': 25.0 * mult, 'fat': 35.0 * mult, 'carbs': 75.0 * mult};
      case 'mcd_cheeseburger':
        return {'protein': 15.0 * mult, 'fat': 12.0 * mult, 'carbs': 33.0 * mult};
      case 'mcd_2foryou':
        return {'protein': 19.0 * mult, 'fat': 29.0 * mult, 'carbs': 77.0 * mult};
      case 'mcd_bigmac':
      case 'mcd_mcdouble':
        return {'protein': 28.0 * mult, 'fat': 32.0 * mult, 'carbs': 45.0 * mult};
      case 'mcd_fries':
      case 'mcd_medium_fries':
        return {'protein': 4.0 * mult, 'fat': 17.0 * mult, 'carbs': 44.0 * mult};
      case 'kfc_drumstick':
      case 'kfc_tenders':
        return {'protein': 35.0 * mult, 'fat': 30.0 * mult, 'carbs': 25.0 * mult};
      case 'subway_6in':
      case 'subway_footlong':
        return {'protein': 25.0 * mult, 'fat': 20.0 * mult, 'carbs': 55.0 * mult};
      default:
        return {'protein': 25.0 * mult, 'fat': 35.0 * mult, 'carbs': 60.0 * mult};
    }
  }
}

const List<EatingOutOption> eatingOutOptions = [
  // Pizza – z kawałkami
  EatingOutOption(
    id: 'pizza',
    minKcal: 250,
    maxKcal: 450,
    defaultKcal: 350,
    icon: '🍕',
    supportsSlices: true,
  ),
  // Ogólne
  EatingOutOption(
    id: 'kebab',
    minKcal: 600,
    maxKcal: 900,
    defaultKcal: 750,
    icon: '🍖',
  ),
  EatingOutOption(
    id: 'burger',
    minKcal: 500,
    maxKcal: 800,
    defaultKcal: 650,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'chinese',
    minKcal: 500,
    maxKcal: 900,
    defaultKcal: 700,
    icon: '🥢',
  ),
  // McDonald's
  EatingOutOption(
    id: 'mcd_cheeseburger',
    minKcal: 270,
    maxKcal: 330,
    defaultKcal: 303,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_2foryou',
    minKcal: 480,
    maxKcal: 580,
    defaultKcal: 530,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_bigmac',
    minKcal: 550,
    maxKcal: 630,
    defaultKcal: 590,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_mcdouble',
    minKcal: 370,
    maxKcal: 430,
    defaultKcal: 400,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_fries',
    minKcal: 200,
    maxKcal: 260,
    defaultKcal: 230,
    icon: '🍟',
  ),
  EatingOutOption(
    id: 'mcd_medium_fries',
    minKcal: 300,
    maxKcal: 380,
    defaultKcal: 340,
    icon: '🍟',
  ),
  // KFC
  EatingOutOption(
    id: 'kfc_drumstick',
    minKcal: 150,
    maxKcal: 250,
    defaultKcal: 200,
    icon: '🍗',
    supportsSlices: true,
  ),
  EatingOutOption(
    id: 'kfc_tenders',
    minKcal: 350,
    maxKcal: 650,
    defaultKcal: 500,
    icon: '🍗',
  ),
  // Subway
  EatingOutOption(
    id: 'subway_6in',
    minKcal: 280,
    maxKcal: 550,
    defaultKcal: 400,
    icon: '🥖',
  ),
  EatingOutOption(
    id: 'subway_footlong',
    minKcal: 550,
    maxKcal: 950,
    defaultKcal: 750,
    icon: '🥖',
  ),
];
