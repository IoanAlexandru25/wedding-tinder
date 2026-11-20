import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/utils/text_normalizer.dart';

void main() {
  group('TextNormalizer.normalize', () {
    test('lowercases and strips Romanian diacritics', () {
      expect(TextNormalizer.normalize('Brașov Țară Mâine În Ăla'),
          'brasov tara maine in ala');
    });

    test('handles legacy cedilla characters', () {
      expect(TextNormalizer.normalize('Ştefan Ţepeş'), 'stefan tepes');
    });

    test('returns an empty string for null or empty input', () {
      expect(TextNormalizer.normalize(null), '');
      expect(TextNormalizer.normalize(''), '');
    });

    test('leaves plain text unchanged apart from case', () {
      expect(TextNormalizer.normalize('Cluj-Napoca'), 'cluj-napoca');
    });
  });

  group('TextNormalizer.sameCounty', () {
    test('matches a county with and without diacritics', () {
      expect(TextNormalizer.sameCounty('Brașov', 'Brasov'), isTrue);
      expect(TextNormalizer.sameCounty('Iași', 'Iasi'), isTrue);
      expect(TextNormalizer.sameCounty('Timiș', 'Timis'), isTrue);
    });

    test('ignores case', () {
      expect(TextNormalizer.sameCounty('CLUJ', 'cluj'), isTrue);
    });

    test('does not match different counties or partial names', () {
      expect(TextNormalizer.sameCounty('Cluj', 'Bucharest'), isFalse);
      expect(TextNormalizer.sameCounty('Brasov', 'Bra'), isFalse);
    });
  });
}
