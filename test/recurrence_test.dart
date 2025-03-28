import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';
import 'package:recurrence/src/interval.dart';
import 'package:test/test.dart';

void main() {
  group('DailyRecurrenceRule', () {
    final rule = RecurrenceRule.daily();

    test('satisfies always returns true', () {
      expect(rule.satisfies(DateTime.now()), true);
      expect(rule.satisfies(DateTime(2024, 1, 1)), true);
      expect(rule.satisfies(DateTime(2024, 12, 31)), true);
    });

    test('nextOccurrence returns next day', () {
      final now = DateTime(2024, 3, 15);
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2024, 3, 16));
    });

    test('previousOccurrence returns previous day', () {
      final now = DateTime(2024, 3, 15);
      final prev = rule.previousOccurrence(now);
      expect(prev, DateTime(2024, 3, 14));
    });

    test('respects time range', () {
      final now = DateTime(2024, 3, 15);
      final range = CustomTimeRange(
        DateTime(2024, 3, 15),
        DateTime(2024, 3, 16),
      );
      final next = rule.nextOccurrence(now, range: range);
      expect(next, DateTime(2024, 3, 16));
    });
  });

  group('WeeklyRecurrence', () {
    final rule = WeeklyRecurrenceRule(weekday: DateTime.monday);

    test('satisfies checks weekday', () {
      expect(rule.satisfies(DateTime(2024, 3, 18)), true); // Monday
      expect(rule.satisfies(DateTime(2024, 3, 19)), false); // Tuesday
    });

    test('nextOccurrence returns next occurrence of weekday', () {
      final now = DateTime(2024, 3, 15); // Friday
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2024, 3, 18)); // Next Monday
    });

    test('previousOccurrence returns previous occurrence of weekday', () {
      final now = DateTime(2024, 3, 15); // Friday
      final prev = rule.previousOccurrence(now);
      expect(prev, DateTime(2024, 3, 11)); // Previous Monday
    });
  });

  group('MonthlyRecurrenceRule', () {
    final rule = MonthlyRecurrenceRule(day: 15);

    test('satisfies checks day of month', () {
      expect(rule.satisfies(DateTime(2024, 3, 15)), true);
      expect(rule.satisfies(DateTime(2024, 3, 16)), false);
    });

    test('nextOccurrence returns next occurrence of day', () {
      final now = DateTime(2024, 3, 10);
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2024, 3, 15));
    });

    test('previousOccurrence returns previous occurrence of day', () {
      final now = DateTime(2024, 3, 20);
      final prev = rule.previousOccurrence(now);
      expect(prev, DateTime(2024, 3, 15));
    });

    test('handles month boundaries correctly', () {
      final now = DateTime(2024, 3, 20);
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2024, 4, 15));
    });
  });

  group('YearlyRecurrence', () {
    final rule = YearlyRecurrenceRule(month: 3, day: 15);

    test('satisfies checks month and day', () {
      expect(rule.satisfies(DateTime(2024, 3, 15)), true);
      expect(rule.satisfies(DateTime(2024, 3, 16)), false);
      expect(rule.satisfies(DateTime(2024, 4, 15)), false);
    });

    test('nextOccurrence returns next occurrence of date', () {
      final now = DateTime(2024, 3, 10);
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2024, 3, 15));
    });

    test('previousOccurrence returns previous occurrence of date', () {
      final now = DateTime(2024, 3, 20);
      final prev = rule.previousOccurrence(now);
      expect(prev, DateTime(2024, 3, 15));
    });

    test('handles year boundaries correctly', () {
      final now = DateTime(2024, 4, 1);
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2025, 3, 15));
    });
  });

  group('IntervalRecurrenceRule', () {
    final rule = IntervalRecurrenceRule(data: const Duration(days: 2));

    test('satisfies always returns true', () {
      expect(rule.satisfies(DateTime.now()), true);
      expect(rule.satisfies(DateTime(2024, 1, 1)), true);
    });

    test('nextOccurrence returns next interval', () {
      final now = DateTime(2024, 3, 15);
      final next = rule.nextOccurrence(now);
      expect(next, DateTime(2024, 3, 17));
    });

    test('previousOccurrence returns previous interval', () {
      final now = DateTime(2024, 3, 15);
      final prev = rule.previousOccurrence(now);
      expect(prev, DateTime(2024, 3, 13));
    });

    test('respects time range', () {
      final now = DateTime(2024, 3, 15);
      final range = CustomTimeRange(
        DateTime(2024, 3, 15),
        DateTime(2024, 3, 16),
      );
      final next = rule.nextOccurrence(now, range: range);
      expect(next, null);
    });
  });

  group('RecurrenceRule base class', () {
    final rule = DailyRecurrenceRule();

    test('occurrences returns all occurrences in range', () {
      final range = CustomTimeRange(
        DateTime(2024, 3, 15),
        DateTime(2024, 3, 17),
      );
      final occurrences = rule.occurrences(range: range);
      expect(occurrences, [
        DateTime(2024, 3, 15),
        DateTime(2024, 3, 16),
        DateTime(2024, 3, 17),
      ]);
    });
  });
}
