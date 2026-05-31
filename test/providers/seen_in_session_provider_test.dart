import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/providers/seen_in_session_provider.dart';

void main() {
  group('SeenInSessionNotifier', () {
    late ProviderContainer container;
    late SeenInSessionNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(seenInSessionProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initial state is empty', () {
      expect(container.read(seenInSessionProvider), isEmpty);
    });

    test('markSeen adds a vendor id', () {
      notifier.markSeen('v_01');
      expect(container.read(seenInSessionProvider), contains('v_01'));
    });

    test('markSeen multiple different ids', () {
      notifier.markSeen('v_01');
      notifier.markSeen('v_02');
      notifier.markSeen('v_03');
      final state = container.read(seenInSessionProvider);
      expect(state.length, 3);
      expect(state, containsAll(['v_01', 'v_02', 'v_03']));
    });

    test('markSeen is idempotent — duplicate does not grow the set', () {
      notifier.markSeen('v_01');
      notifier.markSeen('v_01');
      expect(container.read(seenInSessionProvider).length, 1);
    });

    test('markSeen on already-seen id does not trigger a state change', () {
      notifier.markSeen('v_01');
      final stateAfterFirst = container.read(seenInSessionProvider);
      notifier.markSeen('v_01');
      final stateAfterSecond = container.read(seenInSessionProvider);
      expect(identical(stateAfterFirst, stateAfterSecond), isTrue);
    });

    test('reset clears all seen ids', () {
      notifier.markSeen('v_01');
      notifier.markSeen('v_02');
      notifier.reset();
      expect(container.read(seenInSessionProvider), isEmpty);
    });

    test('reset on empty state is a no-op', () {
      notifier.reset();
      expect(container.read(seenInSessionProvider), isEmpty);
    });

    test('can markSeen again after reset', () {
      notifier.markSeen('v_01');
      notifier.reset();
      notifier.markSeen('v_01');
      expect(container.read(seenInSessionProvider), contains('v_01'));
    });
  });
}
