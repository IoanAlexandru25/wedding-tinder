import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/constants/categories.dart';
import '../models/vendor.dart';

class VendorLoadException implements Exception {
  const VendorLoadException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'VendorLoadException: $message${cause != null ? ' ($cause)' : ''}';
}

class VendorRepository {
  // Pass an http.Client to fetch from the API; omit to load from the
  // bundled asset (used in mock mode and in tests via debugSeed).
  VendorRepository([this._client]);

  static const String _assetPath = 'assets/data/vendors.json';

  final http.Client? _client;
  List<Vendor>? _cache;

  Future<List<Vendor>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final vendors =
        _client != null ? await _loadFromHttp() : await _loadFromAsset();
    _cache = vendors;
    return vendors;
  }

  Future<List<Vendor>> filterBy({
    VendorCategory? category,
    String? judet,
    String? query,
    int? priceMin,
    int? priceMax,
  }) async {
    final all = await loadAll();
    final normalizedQuery = _normalize(query);

    return all.where((v) {
      if (category != null && v.category != category) return false;
      if (judet != null && v.judet != judet) return false;
      if (priceMin != null && v.priceMax < priceMin) return false;
      if (priceMax != null && v.priceMin > priceMax) return false;
      if (normalizedQuery.isNotEmpty) {
        final haystack = _normalize(
          '${v.name} ${v.description} ${v.localitate} ${v.tags.join(' ')}',
        );
        if (!haystack.contains(normalizedQuery)) return false;
      }
      return true;
    }).toList(growable: false);
  }

  Future<Vendor?> findById(String id) async {
    final all = await loadAll();
    for (final v in all) {
      if (v.id == id) return v;
    }
    return null;
  }

  Future<Map<VendorCategory, int>> countsByCategory() async {
    final all = await loadAll();
    final counts = <VendorCategory, int>{
      for (final c in VendorCategory.values) c: 0,
    };
    for (final v in all) {
      counts[v.category] = (counts[v.category] ?? 0) + 1;
    }
    return counts;
  }

  void debugSeed(List<Vendor> vendors) => _cache = List.unmodifiable(vendors);

  // ── Private ────────────────────────────────────────────────────────────────

  Future<List<Vendor>> _loadFromAsset() async {
    final String raw;
    try {
      raw = await rootBundle.loadString(_assetPath);
    } catch (e) {
      throw VendorLoadException('Failed to load vendors asset.', cause: e);
    }
    return _parseList(raw);
  }

  Future<List<Vendor>> _loadFromHttp() async {
    final http.Response response;
    try {
      response = await _client!.get(Uri.parse('$kBaseUrl/vendors'));
    } catch (e) {
      throw VendorLoadException('Failed to fetch vendors from API.', cause: e);
    }
    if (response.statusCode != 200) {
      throw VendorLoadException(
          'Vendors API returned HTTP ${response.statusCode}.');
    }
    return _parseList(response.body);
  }

  static List<Vendor> _parseList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const VendorLoadException('Vendors response has an invalid payload.');
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const VendorLoadException(
            'Vendors response contains invalid item.');
      }
      return Vendor.fromJson(item);
    }).toList(growable: false);
  }

  static String _normalize(String? input) {
    if (input == null || input.isEmpty) return '';
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final code in lower.runes) {
      buffer.writeCharCode(_diacriticMap[code] ?? code);
    }
    return buffer.toString();
  }

  static const Map<int, int> _diacriticMap = {
    0x103: 0x61, // ă
    0x102: 0x61, // Ă
    0xE2: 0x61, // â
    0xC2: 0x61, // Â
    0xEE: 0x69, // î
    0xCE: 0x69, // Î
    0x219: 0x73, // ș
    0x218: 0x73, // Ș
    0x15F: 0x73, // ş (legacy cedilla)
    0x15E: 0x73, // Ş
    0x21B: 0x74, // ț
    0x21A: 0x74, // Ț
    0x163: 0x74, // ţ (legacy cedilla)
    0x162: 0x74, // Ţ
  };
}
