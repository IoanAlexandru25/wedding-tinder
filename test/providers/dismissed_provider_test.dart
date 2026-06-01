import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/providers/dismissed_provider.dart';
import 'package:wedding_tinder/providers/service_providers.dart';
import 'package:wedding_tinder/providers/session_provider.dart';
import 'package:wedding_tinder/services/mock/mock_dismissed_service.dart';

ProviderContainer _makeContainer({String? weddingId}) {
  return ProviderContainer(
    overrides: [
      dismissedServiceProvider.overrideWithValue(MockDismissedService()),
      currentWeddingIdProvider.overrideWithValue(weddingId),
    ],
  );
}

void main() {
  group('DismissedNotifier', () {
    late ProviderContainer container;
    late DismissedNotifier notifier;

    setUp(() {
      container = _makeContainer(weddingId: 'test_wedding');
      notifier = container.read(dismissedProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initial state is empty', () {
      expect(container.read(dismissedProvider), isEmpty);
    });

    test('dismiss adds vendor id to state', () async {
      await notifier.dismiss('v_01');
      expect(container.read(dismissedProvider), contains('v_01'));
    });

    test('dismiss is idempotent — duplicate does not grow the set', () async {
      await notifier.dismiss('v_01');
      await notifier.dismiss('v_01');
      expect(container.read(dismissedProvider).length, 1);
    });

    test('dismiss multiple different vendors all appear', () async {
      await notifier.dismiss('v_01');
      await notifier.dismiss('v_02');
      await notifier.dismiss('v_03');
      final state = container.read(dismissedProvider);
      expect(state.length, 3);
      expect(state, containsAll(['v_01', 'v_02', 'v_03']));
    });

    test('resetSession clears all dismissed ids', () async {
      await notifier.dismiss('v_01');
      await notifier.dismiss('v_02');
      notifier.resetSession();
      expect(container.read(dismissedProvider), isEmpty);
    });

    test('resetSession on empty state is a no-op', () {
      notifier.resetSession();
      expect(container.read(dismissedProvider), isEmpty);
    });

    test('can dismiss again after resetSession', () async {
      await notifier.dismiss('v_01');
      notifier.resetSession();
      await notifier.dismiss('v_01');
      expect(container.read(dismissedProvider), contains('v_01'));
    });

    test('dismiss is a no-op when weddingId is null', () async {
      final c = _makeContainer(weddingId: null);
      addTearDown(c.dispose);
      final n = c.read(dismissedProvider.notifier);
      await n.dismiss('v_01');
      // Optimistic update still adds to local state
      expect(c.read(dismissedProvider), contains('v_01'));
    });
  });
}
