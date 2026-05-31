import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/utils/invite_code_generator.dart';

void main() {
  group('InviteCodeGenerator.generate', () {
    test('generated code starts with WED-', () {
      expect(InviteCodeGenerator.generate().startsWith('WED-'), isTrue);
    });

    test('generated code is exactly 8 characters', () {
      expect(InviteCodeGenerator.generate().length, 8);
    });

    test('suffix uses only characters from the allowed alphabet', () {
      const alphabet = 'ACDEFGHJKLMNPQRTUVWXY3479';
      for (var i = 0; i < 20; i++) {
        final code = InviteCodeGenerator.generate();
        final suffix = code.substring(4);
        for (final char in suffix.split('')) {
          expect(alphabet.contains(char), isTrue,
              reason: 'Unexpected character "$char" in code "$code"');
        }
      }
    });

    test('alphabet excludes ambiguous characters (0, O, I, 1, 2, 5, 6, 8)', () {
      const alphabet = 'ACDEFGHJKLMNPQRTUVWXY3479';
      const ambiguous = ['0', 'O', 'I', '1', '2', '5', '6', '8'];
      for (final ch in ambiguous) {
        expect(alphabet.contains(ch), isFalse,
            reason: '"$ch" should not appear in the alphabet');
      }
    });

    test('generates varied codes (not all identical)', () {
      final codes = {for (var i = 0; i < 30; i++) InviteCodeGenerator.generate()};
      expect(codes.length, greaterThan(1));
    });
  });

  group('InviteCodeGenerator.isValidFormat', () {
    test('accepts a freshly generated code', () {
      final code = InviteCodeGenerator.generate();
      expect(InviteCodeGenerator.isValidFormat(code), isTrue);
    });

    test('accepts lowercase input (case-insensitive)', () {
      expect(InviteCodeGenerator.isValidFormat('wed-abcd'), isTrue);
    });

    test('accepts mixed-case input', () {
      expect(InviteCodeGenerator.isValidFormat('Wed-AbCd'), isTrue);
    });

    test('accepts code surrounded by whitespace', () {
      expect(InviteCodeGenerator.isValidFormat('  WED-ABCD  '), isTrue);
    });

    test('rejects code without WED- prefix', () {
      expect(InviteCodeGenerator.isValidFormat('ABC-1234'), isFalse);
    });

    test('rejects code with too few suffix characters', () {
      expect(InviteCodeGenerator.isValidFormat('WED-AB'), isFalse);
    });

    test('rejects code with too many suffix characters', () {
      expect(InviteCodeGenerator.isValidFormat('WED-ABCDE'), isFalse);
    });

    test('rejects code with no suffix', () {
      expect(InviteCodeGenerator.isValidFormat('WED-'), isFalse);
    });

    test('rejects empty string', () {
      expect(InviteCodeGenerator.isValidFormat(''), isFalse);
    });

    test('rejects code missing the dash', () {
      expect(InviteCodeGenerator.isValidFormat('WEDABCD'), isFalse);
    });
  });
}
