import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/utils/wedding_dates.dart';

void main() {
  group('WeddingDates.defaultRange', () {
    test('is always 12–13 June', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 1, 1));
      expect(range.start.month, DateTime.june);
      expect(range.start.day, 12);
      expect(range.end, DateTime(range.start.year, 6, 13));
    });

    test('uses the current year early in the year', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 1, 15));
      expect(range.start, DateTime(2026, 6, 12));
    });

    test('uses the current year the day before the one-month cutoff', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 5, 11, 23, 59));
      expect(range.start, DateTime(2026, 6, 12));
    });

    test('uses next year from exactly one month before (12 May)', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 5, 12));
      expect(range.start, DateTime(2027, 6, 12));
    });

    test('uses next year in late May', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 5, 30));
      expect(range.start, DateTime(2027, 6, 12));
    });

    test('uses next year after the June date has passed', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 11, 19));
      expect(range.start, DateTime(2027, 6, 12));
      expect(range.end, DateTime(2027, 6, 13));
    });

    test('uses next year on 31 December', () {
      final range = WeddingDates.defaultRange(now: DateTime(2026, 12, 31));
      expect(range.start, DateTime(2027, 6, 12));
    });

    test('is never before the first selectable date', () {
      for (var month = 1; month <= 12; month++) {
        for (final day in [1, 11, 12, 13, 28]) {
          final now = DateTime(2026, month, day, 18);
          final range = WeddingDates.defaultRange(now: now);
          expect(
            range.start.isBefore(WeddingDates.firstSelectableDate(now: now)),
            isFalse,
            reason: 'now = $now',
          );
        }
      }
    });
  });

  group('WeddingDates.pickerInitialRange', () {
    final now = DateTime(2026, 11, 19, 15, 30);

    test('keeps a future range as is', () {
      final range = WeddingDates.pickerInitialRange(
        DateTime(2027, 8, 1),
        DateTime(2027, 8, 2),
        now: now,
      );
      expect(range.start, DateTime(2027, 8, 1));
      expect(range.end, DateTime(2027, 8, 2));
    });

    test('keeps a range that starts today, even late in the day', () {
      final range = WeddingDates.pickerInitialRange(
        DateTime(2026, 11, 19),
        DateTime(2026, 11, 20),
        now: now,
      );
      expect(range.start, DateTime(2026, 11, 19));
    });

    test('falls back to the default range when the start is in the past', () {
      final range = WeddingDates.pickerInitialRange(
        DateTime(2026, 6, 12),
        DateTime(2026, 6, 13),
        now: now,
      );
      expect(range.start, DateTime(2027, 6, 12));
      expect(range.end, DateTime(2027, 6, 13));
    });

    test('falls back to the default range when end is before start', () {
      final range = WeddingDates.pickerInitialRange(
        DateTime(2027, 8, 2),
        DateTime(2027, 8, 1),
        now: now,
      );
      expect(range.start, DateTime(2027, 6, 12));
    });

    test('strips the time of day', () {
      final range = WeddingDates.pickerInitialRange(
        DateTime(2027, 8, 1, 14, 0),
        DateTime(2027, 8, 2, 9, 0),
        now: now,
      );
      expect(range.start, DateTime(2027, 8, 1));
      expect(range.end, DateTime(2027, 8, 2));
    });
  });

  group('WeddingDates.firstSelectableDate', () {
    test('is today at midnight', () {
      expect(
        WeddingDates.firstSelectableDate(now: DateTime(2026, 11, 19, 15, 30)),
        DateTime(2026, 11, 19),
      );
    });
  });
}
