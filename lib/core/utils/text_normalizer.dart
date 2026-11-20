class TextNormalizer {
  const TextNormalizer._();

  static String normalize(String? input) {
    if (input == null || input.isEmpty) return '';
    final buffer = StringBuffer();
    for (final code in input.toLowerCase().runes) {
      buffer.writeCharCode(_diacriticMap[code] ?? code);
    }
    return buffer.toString();
  }

  static bool sameCounty(String a, String b) => normalize(a) == normalize(b);

  static const Map<int, int> _diacriticMap = {
    0x103: 0x61, // ă
    0x102: 0x61, // Ă
    0xE2: 0x61, // â
    0xC2: 0x61, // Â
    0xEE: 0x69, // î
    0xCE: 0x69, // Î
    0x219: 0x73, // ș
    0x218: 0x73, // Ș
    0x15F: 0x73, // ş (legacy cedilla)
    0x15E: 0x73, // Ş
    0x21B: 0x74, // ț
    0x21A: 0x74, // Ț
    0x163: 0x74, // ţ (legacy cedilla)
    0x162: 0x74, // Ţ
  };
}
