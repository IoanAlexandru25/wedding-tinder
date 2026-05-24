import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vendor_filters.dart';

final filtersProvider = StateProvider<VendorFilters>((ref) {
  return const VendorFilters();
});
