import 'package:flutter/material.dart';

class WeddingDates {
  const WeddingDates._();

  static const int defaultStartMonth = DateTime.june;
  static const int defaultStartDay = 12;

  static DateTimeRange defaultRange({DateTime? now}) {
    final today = dateOnly(now ?? DateTime.now());
    final oneMonthBefore =
        DateTime(today.year, defaultStartMonth - 1, defaultStartDay);
    final year = today.isBefore(oneMonthBefore) ? today.year : today.year + 1;
    final start = DateTime(year, defaultStartMonth, defaultStartDay);
    return DateTimeRange(start: start, end: start.add(const Duration(days: 1)));
  }

  static DateTimeRange pickerInitialRange(
    DateTime start,
    DateTime end, {
    DateTime? now,
  }) {
    final today = firstSelectableDate(now: now);
    if (dateOnly(start).isBefore(today) || end.isBefore(start)) {
      return defaultRange(now: now);
    }
    return DateTimeRange(start: dateOnly(start), end: dateOnly(end));
  }

  static DateTime firstSelectableDate({DateTime? now}) =>
      dateOnly(now ?? DateTime.now());

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
