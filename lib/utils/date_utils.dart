extension DateFormatting on DateTime {
  String toDateKey() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  bool isWithinLast(Duration duration) =>
      isAfter(DateTime.now().subtract(duration));
}
