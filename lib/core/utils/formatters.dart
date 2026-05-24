class Formatters {
  const Formatters._();
  static String ron(num amount) => '${_groupedThousands(amount.round())} RON';

  static String priceRange(int min, int max, String unit) {
    return '${_groupedThousands(min)} – ${_groupedThousands(max)} $unit';
  }

  static String shortDateRangeUpper(DateTime start, DateTime end) {
    if (_sameMonth(start, end)) {
      return '${start.day}–${end.day} ${_monthShort(start.month).toUpperCase()}';
    }
    return '${start.day} ${_monthShort(start.month).toUpperCase()} – '
        '${end.day} ${_monthShort(end.month).toUpperCase()}';
  }

  static String longDate(DateTime date) {
    return '${date.day} ${_monthLong(date.month)} ${date.year}';
  }

  static String _groupedThousands(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  static bool _sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static const List<String> _monthsLong = [
    'ianuarie', 'februarie', 'martie', 'aprilie', 'mai', 'iunie',
    'iulie', 'august', 'septembrie', 'octombrie', 'noiembrie', 'decembrie',
  ];

  static const List<String> _monthsShort = [
    'ian', 'feb', 'mar', 'apr', 'mai', 'iun',
    'iul', 'aug', 'sep', 'oct', 'noi', 'dec',
  ];

  static String _monthLong(int m) => _monthsLong[m - 1];
  static String _monthShort(int m) => _monthsShort[m - 1];
}
