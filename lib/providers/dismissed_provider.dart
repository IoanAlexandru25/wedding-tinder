import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'service_providers.dart';
import 'session_provider.dart';

class DismissedNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    ref.listen<String?>(currentWeddingIdProvider, (prev, next) {
      if (next != null && next != prev) _loadFromBackend(next);
    });
    final weddingId = ref.read(currentWeddingIdProvider);
    if (weddingId != null) _loadFromBackend(weddingId);
    return const {};
  }

  Future<void> dismiss(String vendorId) async {
    if (state.contains(vendorId)) return;
    state = {...state, vendorId};
    final weddingId = ref.read(currentWeddingIdProvider);
    if (weddingId == null) return;
    await ref.read(dismissedServiceProvider).dismiss(weddingId, vendorId);
  }

  void resetSession() => state = const {};

  Future<void> _loadFromBackend(String weddingId) async {
    final ids =
        await ref.read(dismissedServiceProvider).listDismissed(weddingId);
    state = ids.toSet();
  }
}

final dismissedProvider =
    NotifierProvider<DismissedNotifier, Set<String>>(DismissedNotifier.new);
