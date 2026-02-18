import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String productUrl = '$baseUrl/product';
  static const String searchUrl = '$baseUrl/cgi/search.pl';

  /// Pobiera informacje o produkcie na podstawie kodu kreskowego (EAN)
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$productUrl/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return _parseProduct(data['product']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Błąd pobierania produktu: $e');
      return null;
    }
  }

  /// Parsuje dane produktu z Open Food Facts
  Map<String, dynamic> _parseProduct(Map<String, dynamic> product) {
    // Nutriments (wartości odżywcze)
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    
    // Makroskładniki (na 100g)
    final protein = nutriments['proteins_100g'] as num? ?? 
                   (nutriments['proteins'] as num?);
    final fat = nutriments['fat_100g'] as num? ?? 
               (nutriments['fat'] as num?);
    final carbs = nutriments['carbohydrates_100g'] as num? ?? 
                 (nutriments['carbohydrates'] as num?);
    
    // Kalorie (energia w kcal/100g) - z API, z kJ lub z makroskładników
    var energyKcal = nutriments['energy-kcal_100g'] as num? ?? 
                     (nutriments['energy-kcal'] as num?);
    if (energyKcal == null) {
      final energyKj = nutriments['energy-kj_100g'] as num? ?? nutriments['energy_100g'] as num?;
      if (energyKj != null) energyKcal = energyKj.toDouble() / 4.184;
    }
    if (energyKcal == null && (protein != null || fat != null || carbs != null)) {
      final p = protein?.toDouble() ?? 0.0;
      final f = fat?.toDouble() ?? 0.0;
      final c = carbs?.toDouble() ?? 0.0;
      energyKcal = (p * 4) + (f * 9) + (c * 4);
    }
    
    // Waga produktu (jeśli dostępna)
    final weight = _parseWeight(product['quantity'] as String?);

    return {
      'name': product['product_name'] as String? ?? 
              product['product_name_pl'] as String? ?? 
              product['product_name_en'] as String? ?? 
              'Produkt',
      'barcode': product['code'] as String? ?? '',
      'calories': energyKcal?.toDouble() ?? 0.0,
      'proteinG': protein?.toDouble() ?? 0.0,
      'fatG': fat?.toDouble() ?? 0.0,
      'carbsG': carbs?.toDouble() ?? 0.0,
      'weightG': weight,
      'imageUrl': product['image_url'] as String?,
      'brand': product['brands'] as String?,
      'ingredients': product['ingredients_text_pl'] as String? ?? 
                     product['ingredients_text'] as String?,
    };
  }

  /// Parsuje wagę z stringa (np. "500g" -> 500.0)
  double? _parseWeight(String? quantity) {
    if (quantity == null || quantity.isEmpty) return null;
    
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*g', caseSensitive: false).firstMatch(quantity);
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(',', '.'));
    }
    return null;
  }
}
