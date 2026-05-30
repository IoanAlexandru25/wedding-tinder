import 'dart:convert';

import 'package:http/http.dart' as http;

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
  VendorRepository({
    String? apiUrl,
    http.Client? client,
  })  : _apiUrl = apiUrl ?? _defaultApiUrl,
        _client = client;

  static const String _defaultApiUrl =
      String.fromEnvironment(
        'VENDORS_API_URL',
        defaultValue:
            'https://us-central1-wedding-tinder-7fa8b.cloudfunctions.net/vendors',
      );

  final String _apiUrl;
  final http.Client? _client;
  List<Vendor>? _cache;

  Future<List<Vendor>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final uri = Uri.parse(_apiUrl);
    final response = _client == null
        ? await http.get(uri)
        : await _client!.get(uri);
    if (response.statusCode != 200) {
      throw VendorLoadException(
        'Failed to load vendors from $_apiUrl.',
        cause: 'HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw VendorLoadException('Vendor API returned an invalid payload.');
    }

    final vendors = decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw VendorLoadException('Vendor API returned invalid vendor data.');
      }
      return Vendor.fromJson(item);
    }).toList(growable: false);

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
