/// Opcje „Jem na mieście” – szybkie dodawanie posiłków z restauracji.
class EatingOutOption {
  final String id;
  final String name;
  final String label; // np. "~600-900 kcal"
  final int minKcal;
  final int maxKcal;
  final int defaultKcal; // wartość domyślna (średnia)
  final String icon; // emoji lub nazwa ikony
  /// true = kalorie są na kawałek (np. pizza), można podać ilość kawałków
  final bool supportsSlices;

  const EatingOutOption({
    required this.id,
    required this.name,
    required this.label,
    required this.minKcal,
    required this.maxKcal,
    required this.defaultKcal,
    required this.icon,
    this.supportsSlices = false,
  });

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
    name: 'Pizza',
    label: '~250–450 kcal / kawałek',
    minKcal: 250,
    maxKcal: 450,
    defaultKcal: 350,
    icon: '🍕',
    supportsSlices: true,
  ),
  // Ogólne
  EatingOutOption(
    id: 'kebab',
    name: 'Kebab',
    label: '~600–900 kcal',
    minKcal: 600,
    maxKcal: 900,
    defaultKcal: 750,
    icon: '🍖',
  ),
  EatingOutOption(
    id: 'burger',
    name: 'Burger (ogólnie)',
    label: '~500–800 kcal',
    minKcal: 500,
    maxKcal: 800,
    defaultKcal: 650,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'chinese',
    name: 'Chińczyk',
    label: '~500–900 kcal',
    minKcal: 500,
    maxKcal: 900,
    defaultKcal: 700,
    icon: '🥢',
  ),
  // McDonald's
  EatingOutOption(
    id: 'mcd_cheeseburger',
    name: "McDonald's – Cheeseburger",
    label: '~300 kcal',
    minKcal: 270,
    maxKcal: 330,
    defaultKcal: 303,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_2foryou',
    name: "McDonald's – 2forYou (Cheeseburger + frytki)",
    label: '~530 kcal',
    minKcal: 480,
    maxKcal: 580,
    defaultKcal: 530,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_bigmac',
    name: "McDonald's – Big Mac",
    label: '~590 kcal',
    minKcal: 550,
    maxKcal: 630,
    defaultKcal: 590,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_mcdouble',
    name: "McDonald's – McDouble",
    label: '~400 kcal',
    minKcal: 370,
    maxKcal: 430,
    defaultKcal: 400,
    icon: '🍔',
  ),
  EatingOutOption(
    id: 'mcd_fries',
    name: "McDonald's – małe frytki",
    label: '~230 kcal',
    minKcal: 200,
    maxKcal: 260,
    defaultKcal: 230,
    icon: '🍟',
  ),
  EatingOutOption(
    id: 'mcd_medium_fries',
    name: "McDonald's – średnie frytki",
    label: '~340 kcal',
    minKcal: 300,
    maxKcal: 380,
    defaultKcal: 340,
    icon: '🍟',
  ),
  // KFC
  EatingOutOption(
    id: 'kfc_drumstick',
    name: 'KFC – udko/nóżka',
    label: '~200 kcal / szt.',
    minKcal: 150,
    maxKcal: 250,
    defaultKcal: 200,
    icon: '🍗',
    supportsSlices: true,
  ),
  EatingOutOption(
    id: 'kfc_tenders',
    name: 'KFC – Strips / Tenders',
    label: '~400–600 kcal',
    minKcal: 350,
    maxKcal: 650,
    defaultKcal: 500,
    icon: '🍗',
  ),
  // Subway
  EatingOutOption(
    id: 'subway_6in',
    name: "Subway – 6'' sub",
    label: '~300–500 kcal',
    minKcal: 280,
    maxKcal: 550,
    defaultKcal: 400,
    icon: '🥖',
  ),
  EatingOutOption(
    id: 'subway_footlong',
    name: "Subway – Footlong",
    label: '~600–900 kcal',
    minKcal: 550,
    maxKcal: 950,
    defaultKcal: 750,
    icon: '🥖',
  ),
];
