import 'package:flutter/foundation.dart' show debugPrint;

import '../data/polish_staple_foods.dart';
import 'open_food_facts_service.dart';
import 'supabase_service.dart';
import 'turso_service.dart';

/// Jedno miejsce wejścia do danych produktów: Turso (gdy skonfigurowane) → Supabase → Open Food Facts API.
class ProductService {
  final _turso = TursoService();
  final _supabase = SupabaseService();
  final _off = OpenFoodFactsService();

  /// Sortuje wyniki: najpierw nazwa zaczyna się od [query], potem alfabetycznie.
  static List<Map<String, dynamic>> _sortByRelevance(
      List<Map<String, dynamic>> list, String query) {
    if (query.isEmpty) return list;
    final lower = query.toLowerCase();
    list.sort((a, b) {
      final an = (a['name'] as String? ?? '').toLowerCase();
      final bn = (b['name'] as String? ?? '').toLowerCase();
      final aStarts = an.startsWith(lower);
      final bStarts = bn.startsWith(lower);
      if (aStarts != bStarts) return aStarts ? -1 : 1;
      return an.compareTo(bn);
    });
    return list;
  }

  /// Pobiera produkt po kodzie kreskowym. Turso → Supabase → OFF API.
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    if (TursoService.isConfigured) {
      final fromTurso = await _turso.getProductByBarcode(barcode);
      if (fromTurso != null) return fromTurso;
    }
    final fromSupabase = await _supabase.getProductByBarcode(barcode);
    if (fromSupabase != null) return fromSupabase;
    return _off.getProductByBarcode(barcode);
  }

  /// Wyszukuje produkty po nazwie. Turso → Supabase → OFF API, plus polskie podstawy.
  Future<List<Map<String, dynamic>>> searchProducts(String query, {int pageSize = 20}) async {
    var remote = <Map<String, dynamic>>[];
    if (TursoService.isConfigured) {
      try {
        remote = await _turso.searchProducts(query, limit: pageSize);
      } catch (e) {
        debugPrint('ProductService: Turso search error: $e');
      }
    }
    if (remote.isEmpty) {
      try {
        remote = await _supabase.searchProducts(query, limit: pageSize);
      } catch (e) {
        debugPrint('ProductService: Supabase search error: $e');
      }
    }
    if (remote.isEmpty) {
      try {
        remote = await _off.searchProducts(query, pageSize: pageSize);
      } catch (e) {
        debugPrint('ProductService: OFF search error: $e');
      }
    }
    return _withStaples(_sortByRelevance(remote, query.trim()), query, pageSize);
  }

  /// Zapisuje produkt z etykiety do wspólnej bazy Turso.
  Future<bool> saveProduct({
    required String barcode,
    required String name,
    String? brand,
    required double caloriesPer100g,
    required double proteinG,
    required double fatG,
    required double carbsG,
  }) {
    return _turso.upsertProduct(
      barcode: barcode,
      name: name,
      brand: brand,
      caloriesPer100g: caloriesPer100g,
      proteinG: proteinG,
      fatG: fatG,
      carbsG: carbsG,
    );
  }

  List<Map<String, dynamic>> _withStaples(
    List<Map<String, dynamic>> remote,
    String query,
    int pageSize,
  ) {
    final staples = PolishStapleFoods.search(query);
    if (staples.isEmpty) return remote;
    final seen = remote
        .map((item) => (item['name'] as String? ?? '').toLowerCase())
        .toSet();
    final extra = staples.where((item) {
      final name = (item['name'] as String).toLowerCase();
      return seen.add(name);
    });
    final merged = [...extra, ...remote];
    if (merged.length <= pageSize) return merged;
    return merged.take(pageSize).toList();
  }
}
