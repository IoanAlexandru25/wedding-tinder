import 'dart:math';

class InviteCodeGenerator {
  const InviteCodeGenerator._();

  static const String _alphabet = 'ACDEFGHJKLMNPQRTUVWXY3479';
  static final Random _rng = Random.secure();

  static String generate() {
    final buffer = StringBuffer('WED-');
    for (var i = 0; i < 4; i++) {
      buffer.write(_alphabet[_rng.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  static bool isValidFormat(String code) {
    final normalized = code.trim().toUpperCase();
    return RegExp(r'^WED-[A-Z0-9]{4}$').hasMatch(normalized);
  }
}
