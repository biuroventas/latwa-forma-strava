import 'open_food_facts_service.dart';
import 'supabase_service.dart';

/// Jedno miejsce wejścia do danych produktów: najpierw Supabase (własna baza), potem fallback na Open Food Facts API.
class ProductService {
  final _supabase = SupabaseService();
  final _off = OpenFoodFactsService();

  /// Pobiera produkt po kodzie kreskowym. Najpierw Supabase, przy braku wyniku – OFF API.
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final fromDb = await _supabase.getProductByBarcode(barcode);
    if (fromDb != null) return fromDb;
    return _off.getProductByBarcode(barcode);
  }

  /// Wyszukuje produkty po nazwie. Najpierw Supabase, przy pustej liście – OFF API.
  Future<List<Map<String, dynamic>>> searchProducts(String query, {int pageSize = 24}) async {
    final fromDb = await _supabase.searchProducts(query, limit: pageSize);
    if (fromDb.isNotEmpty) return fromDb;
    return _off.searchProducts(query, pageSize: pageSize);
  }
}
