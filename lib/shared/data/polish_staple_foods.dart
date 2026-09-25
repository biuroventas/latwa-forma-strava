/// Średnie wartości na 100 g dla produktów, których ludzie szukają po nazwie,
/// bez kodu kreskowego. To nie są marki sklepowe — te dopisuje zdjęcie etykiety.
class PolishStapleFoods {
  static List<Map<String, dynamic>> search(String query, {int limit = 8}) {
    final folded = _fold(query.trim());
    if (folded.length < 2) return const [];
    final starts = <Map<String, dynamic>>[];
    final contains = <Map<String, dynamic>>[];
    for (final item in _items) {
      final name = _fold(item['name'] as String);
      if (name.startsWith(folded)) {
        starts.add(item);
      } else if (name.contains(folded)) {
        contains.add(item);
      }
      if (starts.length >= limit) break;
    }
    return [...starts, ...contains].take(limit).toList();
  }

  static String _fold(String value) {
    const from = 'ąęłńóśźż';
    const to = 'aelnoszz';
    var out = value.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      out = out.replaceAll(from[i], to[i]);
    }
    return out;
  }

  /// kcal, białko, tłuszcz, węglowodany na 100 g oraz typowa porcja w gramach.
  static Map<String, dynamic> _s(
    String id,
    String name,
    double kcal,
    double protein,
    double fat,
    double carbs,
    double portionG,
  ) {
    return {
      'name': name,
      'barcode': 'staple:$id',
      'calories': kcal,
      'proteinG': protein,
      'fatG': fat,
      'carbsG': carbs,
      'weightG': portionG,
      'brand': null,
      'source': 'staple',
    };
  }

  static final List<Map<String, dynamic>> _items = [
    _s('jajko', 'Jajko kurze', 143, 12.6, 9.5, 0.7, 50),
    _s('bialko-jajka', 'Białko jajka', 52, 11, 0.2, 0.7, 33),
    _s('zoltko', 'Żółtko jajka', 322, 16, 27, 3.6, 17),
    _s('mleko-2', 'Mleko 2%', 50, 3.3, 2, 4.8, 250),
    _s('mleko-32', 'Mleko 3,2%', 61, 3.2, 3.2, 4.7, 250),
    _s('mleko-bezlaktozowe', 'Mleko bez laktozy 1,5%', 46, 3.3, 1.5, 4.8, 250),
    _s('kefir', 'Kefir 2%', 51, 3.3, 2, 4.5, 250),
    _s('maslanka', 'Maślanka', 40, 3.3, 1, 4.7, 250),
    _s('jogurt-naturalny', 'Jogurt naturalny', 60, 4.3, 2, 5.2, 150),
    _s('jogurt-grecki', 'Jogurt grecki 2%', 73, 9, 2, 4, 150),
    _s('skyr', 'Skyr naturalny', 63, 11, 0.2, 4, 150),
    _s('twarog-chudy', 'Twaróg chudy', 98, 19.5, 0.5, 3.5, 150),
    _s('twarog-poltlusty', 'Twaróg półtłusty', 133, 18, 5, 3.5, 150),
    _s('ser-gouda', 'Ser żółty gouda', 356, 25, 27, 2, 30),
    _s('ser-feta', 'Ser feta', 264, 14, 21, 4, 40),
    _s('mozzarella', 'Mozzarella', 280, 22, 22, 2, 40),
    _s('smietana-18', 'Śmietana 18%', 184, 2.5, 18, 3.5, 30),
    _s('smietana-12', 'Śmietana 12%', 133, 2.8, 12, 4, 30),
    _s('maslo', 'Masło', 740, 0.7, 82, 0.6, 10),
    _s('olej', 'Olej rzepakowy', 884, 0, 100, 0, 10),
    _s('chleb-pszenny', 'Chleb pszenny', 262, 8.5, 3.2, 49, 35),
    _s('chleb-zytni', 'Chleb żytni', 235, 6.5, 1.5, 48, 40),
    _s('chleb-razowy', 'Chleb razowy', 220, 8, 2, 42, 40),
    _s('kajzerka', 'Bułka kajzerka', 280, 8, 3, 54, 50),
    _s('bagietka', 'Bagietka', 270, 9, 2, 55, 40),
    _s('tortilla', 'Tortilla pszenna', 310, 8, 7, 52, 40),
    _s('platki-owsiane', 'Płatki owsiane', 379, 13, 7, 68, 40),
    _s('platki-kukurydziane', 'Płatki kukurydziane', 370, 7, 1, 84, 30),
    _s('granola', 'Granola', 450, 10, 18, 64, 40),
    _s('ryz-gotowany', 'Ryż biały gotowany', 130, 2.7, 0.3, 28, 150),
    _s('ryz-brazowy', 'Ryż brązowy gotowany', 123, 2.7, 1, 26, 150),
    _s('ryz-suchy', 'Ryż biały suchy', 360, 7, 0.6, 79, 60),
    _s('makaron-gotowany', 'Makaron gotowany', 131, 5, 1.1, 25, 180),
    _s('makaron-suchy', 'Makaron suchy', 371, 13, 1.5, 75, 80),
    _s('kasza-gryczana', 'Kasza gryczana gotowana', 110, 3.4, 0.6, 22, 150),
    _s('kasza-jaglana', 'Kasza jaglana gotowana', 119, 3.5, 1, 23, 150),
    _s('maka', 'Mąka pszenna', 364, 10, 1, 76, 50),
    _s('ziemniaki', 'Ziemniaki gotowane', 77, 2, 0.1, 17, 200),
    _s('batat', 'Batat pieczony', 90, 2, 0.2, 21, 150),
    _s('frytki', 'Frytki', 312, 3.4, 15, 41, 120),
    _s('kurczak-piers', 'Pierś z kurczaka', 110, 23, 1.2, 0, 150),
    _s('kurczak-udko', 'Udko z kurczaka bez skóry', 150, 20, 8, 0, 120),
    _s('indyk', 'Pierś z indyka', 111, 24, 1, 0, 150),
    _s('schab', 'Schab wieprzowy', 174, 21, 10, 0, 120),
    _s('karkowka', 'Karkówka wieprzowa', 250, 17, 20, 0, 120),
    _s('mielone', 'Mięso mielone wołowe', 215, 20, 15, 0, 120),
    _s('wolowina', 'Wołowina chuda', 150, 22, 7, 0, 120),
    _s('boczek', 'Boczek', 518, 9, 53, 0, 30),
    _s('szynka', 'Szynka', 110, 18, 4, 1, 40),
    _s('kielbasa', 'Kiełbasa śląska', 280, 14, 24, 1, 50),
    _s('parowki', 'Parówki', 250, 11, 22, 2, 40),
    _s('watrobka', 'Wątróbka drobiowa', 136, 19, 5, 1, 100),
    _s('losos', 'Łosoś', 208, 20, 13, 0, 120),
    _s('dorsz', 'Dorsz', 82, 18, 0.7, 0, 150),
    _s('tunczyk', 'Tuńczyk w wodzie', 116, 26, 1, 0, 80),
    _s('sledz', 'Śledź', 160, 18, 9, 0, 80),
    _s('makrela', 'Makrela', 205, 19, 14, 0, 80),
    _s('tofu', 'Tofu', 76, 8, 4.8, 1.9, 100),
    _s('groch', 'Groch gotowany', 118, 8, 0.4, 21, 150),
    _s('fasola', 'Fasola biała gotowana', 127, 8.7, 0.5, 23, 150),
    _s('soczewica', 'Soczewica gotowana', 116, 9, 0.4, 20, 150),
    _s('jablko', 'Jabłko', 52, 0.3, 0.2, 14, 150),
    _s('banan', 'Banan', 89, 1.1, 0.3, 23, 120),
    _s('pomarancza', 'Pomarańcza', 47, 0.9, 0.1, 12, 150),
    _s('truskawki', 'Truskawki', 32, 0.7, 0.3, 7.7, 150),
    _s('borowki', 'Borówki', 57, 0.7, 0.3, 14, 100),
    _s('awokado', 'Awokado', 160, 2, 15, 9, 70),
    _s('pomidor', 'Pomidor', 18, 0.9, 0.2, 3.9, 120),
    _s('ogorek', 'Ogórek', 15, 0.7, 0.1, 3.6, 100),
    _s('marchew', 'Marchew', 35, 0.9, 0.2, 8, 80),
    _s('brokul', 'Brokuł', 34, 2.8, 0.4, 7, 150),
    _s('kalafior', 'Kalafior', 25, 1.9, 0.3, 5, 150),
    _s('szpinak', 'Szpinak', 23, 2.9, 0.4, 3.6, 80),
    _s('papryka', 'Papryka', 31, 1, 0.3, 6, 100),
    _s('cebula', 'Cebula', 40, 1.1, 0.1, 9, 50),
    _s('czosnek', 'Czosnek', 149, 6.4, 0.5, 33, 5),
    _s('orzechy-wloskie', 'Orzechy włoskie', 654, 15, 65, 14, 20),
    _s('migdaly', 'Migdały', 579, 21, 50, 22, 20),
    _s('maslo-orzechowe', 'Masło orzechowe', 588, 25, 50, 20, 20),
    _s('cukier', 'Cukier', 400, 0, 0, 100, 10),
    _s('miod', 'Miód', 304, 0.3, 0, 82, 15),
    _s('dzem', 'Dżem', 250, 0.4, 0.1, 62, 20),
    _s('ketchup', 'Ketchup', 112, 1.3, 0.2, 26, 15),
    _s('majonez', 'Majonez', 680, 1, 75, 2, 15),
    _s('musztarda', 'Musztarda', 66, 4, 3, 6, 10),
    _s('czekolada-mleczna', 'Czekolada mleczna', 535, 7, 30, 59, 20),
    _s('czekolada-gorzka', 'Czekolada gorzka 70%', 598, 8, 43, 46, 20),
    _s('chipsy', 'Chipsy solone', 530, 6, 35, 50, 30),
    _s('lody', 'Lody waniliowe', 207, 3.5, 11, 24, 80),
    _s('pizza', 'Pizza margherita', 250, 11, 9, 30, 150),
    _s('pierogi', 'Pierogi ruskie', 200, 6, 6, 30, 180),
    _s('schabowy', 'Kotlet schabowy', 280, 18, 18, 12, 150),
    _s('nalesnik', 'Naleśnik', 190, 6, 7, 26, 80),
    _s('placki', 'Placki ziemniaczane', 220, 4, 12, 25, 150),
    _s('rosol', 'Rosół', 35, 2, 1.5, 2, 300),
    _s('zupa-pomidorowa', 'Zupa pomidorowa', 40, 1, 1, 6, 300),
    _s('kawa', 'Kawa czarna', 2, 0.1, 0, 0, 250),
    _s('herbata', 'Herbata bez cukru', 1, 0, 0, 0.2, 250),
    _s('sok-pomaranczowy', 'Sok pomarańczowy', 45, 0.7, 0.2, 10, 200),
    _s('cola', 'Napój typu cola', 42, 0, 0, 10.6, 250),
    _s('piwo', 'Piwo jasne', 43, 0.5, 0, 3.5, 500),
    _s('wino', 'Wino czerwone', 85, 0.1, 0, 2.6, 150),
    _s('woda', 'Woda', 0, 0, 0, 0, 250),
  ];
}
