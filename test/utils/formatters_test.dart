import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/utils/formatters.dart';

// Formatters.ron uses a non-breaking space (U+00A0) between the number and RON.
const _nbsp = ' ';

void main() {
  group('Formatters.ron', () {
    test('formats amount under 1000 with no separator', () {
      expect(Formatters.ron(500), '500${_nbsp}RON');
    });

    test('formats 1000 with thousands separator', () {
      expect(Formatters.ron(1000), '1,000${_nbsp}RON');
    });

    test('formats 1500 correctly', () {
      expect(Formatters.ron(1500), '1,500${_nbsp}RON');
    });

    test('formats 10000 correctly', () {
      expect(Formatters.ron(10000), '10,000${_nbsp}RON');
    });

    test('formats 1000000 with two commas', () {
      expect(Formatters.ron(1000000), '1,000,000${_nbsp}RON');
    });

    test('rounds double upward', () {
      expect(Formatters.ron(1499.9), '1,500${_nbsp}RON');
    });

    test('rounds double downward', () {
      expect(Formatters.ron(1500.4), '1,500${_nbsp}RON');
    });

    test('formats zero', () {
      expect(Formatters.ron(0), '0${_nbsp}RON');
    });
  });

  group('Formatters.priceRange', () {
    test('formats range with unit', () {
      expect(Formatters.priceRange(320, 480, 'RON/person'),
          '320 – 480 RON/person');
    });

    test('formats range with thousands separators', () {
      expect(Formatters.priceRange(1200, 3500, 'RON'), '1,200 – 3,500 RON');
    });

    test('uses en-dash separator', () {
      final result = Formatters.priceRange(100, 200, 'RON');
      expect(result.contains('–'), isTrue);
    });
  });

  group('Formatters.shortDateRangeUpper', () {
    test('same month collapses to day range with single month', () {
      final start = DateTime(2025, 6, 14);
      final end = DateTime(2025, 6, 15);
      expect(Formatters.shortDateRangeUpper(start, end), '14–15 JUN');
    });

    test('same day same month shows collapsed form', () {
      final date = DateTime(2025, 12, 31);
      expect(Formatters.shortDateRangeUpper(date, date), '31–31 DEC');
    });

    test('different months shows both month abbreviations', () {
      final start = DateTime(2025, 6, 28);
      final end = DateTime(2025, 7, 1);
      expect(Formatters.shortDateRangeUpper(start, end), '28 JUN – 1 JUL');
    });

    test('month abbreviations are uppercase', () {
      final start = DateTime(2025, 1, 5);
      final end = DateTime(2025, 1, 10);
      final result = Formatters.shortDateRangeUpper(start, end);
      expect(result, equals(result.toUpperCase()));
    });

    test('all 12 month abbreviations are correct for same-month case', () {
      const expectedAbbrs = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
      ];
      for (var month = 1; month <= 12; month++) {
        final date = DateTime(2025, month, 1);
        final result = Formatters.shortDateRangeUpper(date, date);
        expect(result.contains(expectedAbbrs[month - 1]), isTrue,
            reason: 'Month $month should abbreviate to ${expectedAbbrs[month - 1]}');
      }
    });
  });

  group('Formatters.longDate', () {
    test('formats a full date correctly', () {
      expect(Formatters.longDate(DateTime(2025, 6, 14)), '14 June 2025');
    });

    test('formats January correctly', () {
      expect(Formatters.longDate(DateTime(2024, 1, 1)), '1 January 2024');
    });

    test('formats December correctly', () {
      expect(Formatters.longDate(DateTime(2024, 12, 31)), '31 December 2024');
    });

    test('all 12 full month names are correct', () {
      const expected = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      for (var month = 1; month <= 12; month++) {
        final result = Formatters.longDate(DateTime(2025, month, 15));
        expect(result.contains(expected[month - 1]), isTrue,
            reason: 'Month $month should be ${expected[month - 1]}');
      }
    });
  });
}
