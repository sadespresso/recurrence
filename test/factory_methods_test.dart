import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';
import 'package:test/test.dart';

void main() {
  group('Recurrence factory constructors', () {
    test('fromIndefinitely creates recurrence with start date to max value',
        () {
      final rule = RecurrenceRule.weekly(DateTime.monday);
      final start = DateTime(2025, 1, 1);

      final recurrence = Recurrence.fromIndefinitely(
        rules: [rule],
        start: start,
      );

      expect(recurrence.range.from, equals(start));
      expect(recurrence.range.to, equals(Moment.maxValue));
      expect(recurrence.rules, equals([rule]));

      // Test with default start (now)
      final nowRecurrence = Recurrence.fromIndefinitely(
        rules: [rule],
      );

      // Verify start time is close to now (within 2 seconds)
      final timeDifference =
          nowRecurrence.range.from.difference(DateTime.now()).inSeconds.abs();
      expect(timeDifference, lessThan(2));
      expect(nowRecurrence.range.to, equals(Moment.maxValue));
      expect(nowRecurrence.rules, equals([rule]));
    });

    test('forever creates recurrence from min value to max value', () {
      final rule = RecurrenceRule.monthly(15);

      final recurrence = Recurrence.forever(
        rules: [rule],
      );

      expect(recurrence.range.from, equals(Moment.minValue));
      expect(recurrence.range.to, equals(Moment.maxValue));
      expect(recurrence.rules, equals([rule]));
    });

    test('copyWith creates new instance with optional updates', () {
      final originalRule = RecurrenceRule.daily();
      final newRule = RecurrenceRule.weekly(DateTime.friday);
      final originalRange = MonthTimeRange(2025, 1);
      final newRange = YearTimeRange(2025);

      final original = Recurrence(
        range: originalRange,
        rules: [originalRule],
      );

      // Update just the rules
      final updatedRules = original.copyWith(
        rules: [newRule],
      );

      expect(updatedRules.range, equals(originalRange));
      expect(updatedRules.rules, equals([newRule]));

      // Update just the range
      final updatedRange = original.copyWith(
        range: newRange,
      );

      expect(updatedRange.range, equals(newRange));
      expect(updatedRange.rules, equals([originalRule]));

      // Update both
      final updatedBoth = original.copyWith(
        range: newRange,
        rules: [newRule],
      );

      expect(updatedBoth.range, equals(newRange));
      expect(updatedBoth.rules, equals([newRule]));

      // Ensure original wasn't modified
      expect(original.range, equals(originalRange));
      expect(original.rules, equals([originalRule]));
    });
  });

  group('Practical usage scenarios', () {
    test('indefinite weekly recurrence with occurrences check', () {
      final rule = RecurrenceRule.weekly(DateTime.monday);
      final start = DateTime(2025, 1, 1);

      final recurrence = Recurrence.fromIndefinitely(
        rules: [rule],
        start: start,
      );

      // Check occurrences for a month
      final checkRange = MonthTimeRange(2025, 1);
      final occurrences = recurrence.occurrences(subrange: checkRange);

      // Calculate expected Mondays in January 2025
      final expectedMondays = [
        DateTime(2025, 1, 6),
        DateTime(2025, 1, 13),
        DateTime(2025, 1, 20),
        DateTime(2025, 1, 27),
      ];

      expect(occurrences, containsAll(expectedMondays));
      expect(occurrences.length, equals(expectedMondays.length));
    });

    test('forever recurrence with custom range query', () {
      final rule = RecurrenceRule.yearly(DateTime.january, 1);

      final recurrence = Recurrence.forever(
        rules: [rule],
      );

      // Check New Year's days for a specific decade
      final checkRange = CustomTimeRange(
        DateTime(2020, 1, 1),
        DateTime(2029, 12, 31),
      ).toUtc();

      final occurrences = recurrence.occurrences(subrange: checkRange);

      final expectedDates = [
        for (int year = 2020; year <= 2029; year++) DateTime.utc(year, 1, 1)
      ];

      expect(occurrences, equals(expectedDates));
    });

    test('copyWith to add an additional rule', () {
      // Start with just Mondays
      final mondayRule = RecurrenceRule.weekly(DateTime.monday);
      final originalRange = MonthTimeRange(2025, 1).toUtc();

      final original = Recurrence(
        range: originalRange,
        rules: [mondayRule],
      );

      // Add Fridays as well
      final fridayRule = RecurrenceRule.weekly(DateTime.friday);
      final updated = original.copyWith(
        rules: [mondayRule, fridayRule],
      );

      final occurrences = updated.occurrences(subrange: originalRange);

      // Expected Mondays and Fridays in January 2025
      final expectedDates = [
        DateTime.utc(2025, 1, 3),
        DateTime.utc(2025, 1, 6),
        DateTime.utc(2025, 1, 10),
        DateTime.utc(2025, 1, 13),
        DateTime.utc(2025, 1, 17),
        DateTime.utc(2025, 1, 20),
        DateTime.utc(2025, 1, 24),
        DateTime.utc(2025, 1, 27),
        DateTime.utc(2025, 1, 31),
      ];

      expect(occurrences, equals(expectedDates));
    });
  });
}
