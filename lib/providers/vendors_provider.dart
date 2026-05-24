import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/categories.dart';
import '../models/vendor.dart';
import '../services/vendor_repository.dart';
import 'filters_provider.dart';
import 'seen_in_session_provider.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository();
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  return ref.read(vendorRepositoryProvider).loadAll();
});

final vendorCountsProvider = FutureProvider<Map<VendorCategory, int>>((ref) {
  return ref.read(vendorRepositoryProvider).countsByCategory();
});

final filteredVendorsProvider = Provider<List<Vendor>>((ref) {
  final all = ref.watch(vendorsProvider).asData?.value ?? const <Vendor>[];
  final filters = ref.watch(filtersProvider);
  final seen = ref.watch(seenInSessionProvider);

  return all.where((v) {
    if (filters.category != null && v.category != filters.category) {
      return false;
    }
    if (filters.judet != null && v.judet != filters.judet) return false;
    if (filters.priceMin != null && v.priceMax < filters.priceMin!) {
      return false;
    }
    if (filters.priceMax != null && v.priceMin > filters.priceMax!) {
      return false;
    }
    if (seen.contains(v.id)) return false;
    return true;
  }).toList(growable: false);
});

final vendorByIdProvider = Provider.family<Vendor?, String>((ref, id) {
  final all = ref.watch(vendorsProvider).asData?.value ?? const <Vendor>[];
  for (final v in all) {
    if (v.id == id) return v;
  }
  return null;
});
