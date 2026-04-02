import 'package:flutter_test/flutter_test.dart';
import 'package:papetune/utils/date_utils.dart';

void main() {
  group('DateFormatting', () {
    group('toDateKey', () {
      test('formats standard date', () {
        expect(DateTime(2026, 3, 15).toDateKey(), '2026-03-15');
      });

      test('pads single-digit month', () {
        expect(DateTime(2026, 1, 15).toDateKey(), '2026-01-15');
      });

      test('pads single-digit day', () {
        expect(DateTime(2026, 12, 5).toDateKey(), '2026-12-05');
      });

      test('handles year boundary', () {
        expect(DateTime(2025, 12, 31).toDateKey(), '2025-12-31');
        expect(DateTime(2026, 1, 1).toDateKey(), '2026-01-01');
      });
    });

    group('isWithinLast', () {
      test('returns true for recent timestamp', () {
        final recent = DateTime.now().subtract(const Duration(hours: 1));
        expect(recent.isWithinLast(const Duration(hours: 24)), isTrue);
      });

      test('returns false for old timestamp', () {
        final old = DateTime.now().subtract(const Duration(hours: 25));
        expect(old.isWithinLast(const Duration(hours: 24)), isFalse);
      });

      test('returns true for timestamp at current time', () {
        expect(DateTime.now().isWithinLast(const Duration(hours: 24)), isTrue);
      });

      test('returns false for exactly expired timestamp', () {
        // Slightly older than the duration
        final expired =
            DateTime.now().subtract(const Duration(hours: 24, seconds: 1));
        expect(expired.isWithinLast(const Duration(hours: 24)), isFalse);
      });

      test('works with different durations', () {
        final thirtyMinAgo = DateTime.now().subtract(const Duration(minutes: 30));
        expect(thirtyMinAgo.isWithinLast(const Duration(hours: 1)), isTrue);
        expect(thirtyMinAgo.isWithinLast(const Duration(minutes: 20)), isFalse);
      });
    });
  });
}
