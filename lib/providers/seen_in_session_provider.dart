import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeenInSessionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void markSeen(String vendorId) {
    if (state.contains(vendorId)) return;
    state = {...state, vendorId};
  }

  void reset() => state = const {};
}

final seenInSessionProvider =
    NotifierProvider<SeenInSessionNotifier, Set<String>>(
  SeenInSessionNotifier.new,
);
