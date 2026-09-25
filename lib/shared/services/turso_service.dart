import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/supabase_config.dart';

/// Klient do bazy produktów Turso (libSQL) przez HTTP API.
/// Działa na wszystkich platformach (w tym web). Czyta TURSO_DATABASE_URL i TURSO_AUTH_TOKEN z env.
class TursoService {
  static String? get _url {
    final u = (SupabaseConfig.getEnv('TURSO_DATABASE_URL') ??
            SupabaseConfig.getEnv('TURSO_URL') ??
            '')
        .trim();
    if (u.isEmpty) return null;
    return u.endsWith('/') ? u.substring(0, u.length - 1) : u;
  }

  static String? get _token =>
      (SupabaseConfig.getEnv('TURSO_AUTH_TOKEN') ?? '').trim();

  /// Czy Turso jest skonfigurowane (URL + token).
  static bool get isConfigured {
    final u = _url;
    final t = _token;
    return u != null && u.isNotEmpty && t != null && t.isNotEmpty;
  }

  static void _log(String message) {
    debugPrint('Turso: $message');
  }

  Future<Map<String, dynamic>?> _executeQuery(
    String sql, [
    List<Object?> args = const [],
  ]) async {
    final baseUrl = _url;
    final token = _token;
    if (baseUrl == null || token == null) {
      _log('pominięte (brak URL lub tokenu)');
      return null;
    }

    final uri = Uri.parse('$baseUrl/v2/pipeline');
    _log('żądanie do $baseUrl');
    final body = <String, dynamic>{
      'requests': [
        if (args.isEmpty)
          {'type': 'execute', 'stmt': {'sql': sql}}
        else
          {
            'type': 'execute',
            'stmt': {
              'sql': sql,
              'args': args.map((a) {
                if (a == null) return {'type': 'null'};
                if (a is int) return {'type': 'integer', 'value': a.toString()};
                if (a is double) return {'type': 'float', 'value': a.toString()};
                return {'type': 'text', 'value': a.toString()};
              }).toList(),
            },
          },
        {'type': 'close'},
      ],
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        _log('błąd HTTP ${response.statusCode}: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      final results = data?['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>?;
      if (first == null) return null;
      final responseData = first['response'] as Map<String, dynamic>?;
      if (responseData == null) return null;

      final result = responseData['result'];
      if (result == null) return null;

      return result as Map<String, dynamic>;
    } catch (e, st) {
      _log('wyjątek: $e');
      debugPrint('Turso stack: $st');
      return null;
    }
  }

  /// Zamienia wynik execute (cols + rows z Turso) na listę map (nazwa kolumny -> wartość).
  static List<Map<String, dynamic>> _resultToRows(Map<String, dynamic> result) {
    final cols = result['cols'] as List<dynamic>?;
    final rows = result['rows'] as List<dynamic>?;
    if (cols == null || rows == null) return [];

    final colNames =
        cols.map((c) => (c as Map<String, dynamic>)['name'] as String?).toList();
    final out = <Map<String, dynamic>>[];

    for (final row in rows) {
      final cells = row as List<dynamic>;
      final map = <String, dynamic>{};
      for (var i = 0; i < colNames.length && i < cells.length; i++) {
        final name = colNames[i];
        if (name == null) continue;
        final cell = cells[i] as Map<String, dynamic>?;
        if (cell == null) {
          map[name] = null;
          continue;
        }
        final type = cell['type'] as String?;
        final raw = cell['value'];
        if (type == 'null' || raw == null) {
          map[name] = null;
        } else if (type == 'integer') {
          map[name] = raw is int
              ? raw
              : (raw is String ? int.tryParse(raw) : null);
        } else if (type == 'float') {
          map[name] = raw is num
              ? raw.toDouble()
              : (raw is String ? double.tryParse(raw) : null);
        } else {
          map[name] = raw is String ? raw : raw.toString();
        }
      }
      out.add(map);
    }
    return out;
  }

  static Map<String, dynamic> _rowToProductMap(Map<String, dynamic> row) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    String? toStr(dynamic v) =>
        v == null ? null : (v is String ? v : v.toString());

    return {
      'name': toStr(row['name']) ?? 'Produkt',
      'barcode': toStr(row['barcode']) ?? '',
      'calories': toDouble(row['calories_per_100g']),
      'proteinG': toDouble(row['protein_g']),
      'fatG': toDouble(row['fat_g']),
      'carbsG': toDouble(row['carbs_g']),
      'weightG': row['weight_g'] != null ? toDouble(row['weight_g']) : null,
      'imageUrl': toStr(row['image_url']),
      'brand': toStr(row['brand']),
      'ingredients': toStr(row['ingredients']),
    };
  }

  /// Pobiera produkt po kodzie kreskowym. Zwraca mapę w formacie UI lub null.
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final result = await _executeQuery(
      'SELECT * FROM products WHERE barcode = ? LIMIT 1',
      [barcode],
    );
    if (result == null) return null;
    final rows = _resultToRows(result);
    if (rows.isEmpty) return null;
    return _rowToProductMap(rows.first);
  }

  /// Wyszukuje produkty po nazwie (LIKE). Zwraca listę map w formacie UI.
  /// Sortowanie: najpierw nazwy zaczynające się od zapytania, potem reszta, wg nazwy.
  Future<List<Map<String, dynamic>>> searchProducts(String query,
      {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    _log('searchProducts(isConfigured=$isConfigured)');
    final trimmed = query.trim();
    final lower = trimmed.toLowerCase();
    final q = '%$lower%';
    final startsWith = '$lower%';
    final result = await _executeQuery(
      '''
      SELECT * FROM products
      WHERE LOWER(name) LIKE ? OR LOWER(COALESCE(name_pl, '')) LIKE ?
      ORDER BY (LOWER(name) LIKE ? OR LOWER(COALESCE(name_pl, '')) LIKE ?) DESC, name
      LIMIT ?
      ''',
      [q, q, startsWith, startsWith, limit],
    );
    if (result == null) return [];
    final rows = _resultToRows(result);
    return rows.map(_rowToProductMap).toList();
  }

  /// Zapisuje produkt z etykiety. Ten sam kod kreskowy nadpisuje starszy wpis.
  Future<bool> upsertProduct({
    required String barcode,
    required String name,
    String? brand,
    required double caloriesPer100g,
    required double proteinG,
    required double fatG,
    required double carbsG,
    String source = 'user',
  }) async {
    final cleanBarcode = barcode.trim();
    final cleanName = name.trim();
    if (!isConfigured || cleanBarcode.isEmpty || cleanName.isEmpty) return false;
    final cleanBrand = brand?.trim();
    final result = await _executeQuery(
      '''
      INSERT INTO products (barcode, name, brand, calories_per_100g, protein_g, fat_g, carbs_g, source)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(barcode) DO UPDATE SET
        name = excluded.name,
        brand = excluded.brand,
        calories_per_100g = excluded.calories_per_100g,
        protein_g = excluded.protein_g,
        fat_g = excluded.fat_g,
        carbs_g = excluded.carbs_g,
        source = excluded.source
      ''',
      [
        cleanBarcode,
        cleanName,
        (cleanBrand == null || cleanBrand.isEmpty) ? null : cleanBrand,
        caloriesPer100g,
        proteinG,
        fatG,
        carbsG,
        source,
      ],
    );
    return result != null;
  }
}
