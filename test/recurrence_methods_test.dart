import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';
import 'package:test/test.dart';

void main() {
  group('Recurrence occurrence methods', () {
    group('nextOccurrence', () {
      test('returns the earliest next occurrence from multiple rules', () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);
        final monthlyRule = RecurrenceRule.monthly(15);

        final recurrence = Recurrence(
          range: CustomTimeRange(
            DateTime(2025, 1, 1),
            DateTime(2025, 12, 31),
          ),
          rules: [dailyRule, weeklyRule, monthlyRule],
        );

        // When from is 2025-01-10 (Friday)
        // - daily rule gives 2025-01-11 (Saturday)
        // - weekly rule gives 2025-01-15 (Wednesday)
        // - monthly rule gives 2025-01-15 (15th of January)
        // The earliest is 2025-01-11 from the daily rule
        final nextOccurrence = recurrence.nextOccurrence(DateTime(2025, 1, 10));
        expect(nextOccurrence, equals(DateTime(2025, 1, 11)));
      });

      test('returns null when all rules return null', () {
        final recurrence = Recurrence(
          range: CustomTimeRange(
            DateTime(2025, 1, 1),
            DateTime(2025, 1, 10),
          ),
          // Empty rules list means no occurrences will be found
          rules: [],
        );

        final nextOccurrence = recurrence.nextOccurrence(DateTime(2025, 1, 1));
        expect(nextOccurrence, isNull);
      });

      test('uses range parameter to filter rule results', () {
        final dailyRule = RecurrenceRule.daily();

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule],
        );

        // When from is 2025-01-15, the rule would give 2025-01-16
        // But if we restrict to February only, the rule result is filtered out
        final restrictedRange = MonthTimeRange(2025, 2);

        // The rule's nextOccurrence will return 2025-01-16, but it's outside the restrictedRange
        // So nextOccurrence should filter it out and pass null to the comparator
        final nextOccurrence = recurrence.nextOccurrence(
          DateTime(2025, 1, 15),
          subrange: restrictedRange,
        );

        // Since the rule's occurrence is outside the range, it becomes null
        // With only one rule, the result would be null
        // With multiple rules, any non-null results would win in the comparator
        expect(nextOccurrence, isNull);
      });

      test('applies time range to each rule before sorting results', () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);

        final recurrence = Recurrence(
          range: CustomTimeRange(
            DateTime(2025, 1, 1),
            DateTime(2025, 12, 31),
          ),
          rules: [dailyRule, weeklyRule],
        );

        // Restrict the time range to just the month of February
        final restrictedRange = MonthTimeRange(2025, 2);

        // When from is 2025-01-31:
        // - dailyRule gives 2025-02-01 (still in restrictedRange)
        // - weeklyRule gives 2025-02-05 (first Wednesday in February)
        final nextOccurrence = recurrence.nextOccurrence(
          DateTime(2025, 1, 31),
          subrange: restrictedRange,
        );
        expect(nextOccurrence, equals(DateTime(2025, 2, 1)));
      });

      test('deduplicates occurrences from different rules', () {
        final mondayRule = RecurrenceRule.weekly(DateTime.monday);
        final dayRule = RecurrenceRule.monthly(6); // 6th of month

        // January 6, 2025 is both Monday and the 6th of the month
        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [mondayRule, dayRule],
        );

        // From January 1, 2025, both rules would give January 6
        // But we should get only one result
        final occurrences = recurrence.rules
            .map((rule) => rule.nextOccurrence(DateTime(2025, 1, 1)))
            .toList();

        expect(occurrences.length, equals(2)); // Two rules, two occurrences

        final nextOccurrence = recurrence.nextOccurrence(DateTime(2025, 1, 1));
        expect(nextOccurrence, equals(DateTime(2025, 1, 6)));
      });
    });

    group('previousOccurrence', () {
      test('returns the latest previous occurrence from multiple rules', () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);
        final monthlyRule = RecurrenceRule.monthly(15);

        final recurrence = Recurrence(
          range: CustomTimeRange(
            DateTime(2025, 1, 1),
            DateTime(2025, 12, 31),
          ),
          rules: [dailyRule, weeklyRule, monthlyRule],
        );

        // When from is 2025-01-20 (Monday)
        // - daily rule gives 2025-01-19 (Sunday)
        // - weekly rule gives 2025-01-15 (Wednesday)
        // - monthly rule gives 2025-01-15 (15th of January)
        // The latest is 2025-01-19 from the daily rule
        final prevOccurrence =
            recurrence.previousOccurrence(DateTime(2025, 1, 20));
        expect(prevOccurrence, equals(DateTime(2025, 1, 19)));
      });

      test('returns null when all rules return null', () {
        final recurrence = Recurrence(
          range: CustomTimeRange(
            DateTime(2025, 1, 10),
            DateTime(2025, 1, 20),
          ),
          // Empty rules list means no occurrences will be found
          rules: [],
        );

        final prevOccurrence =
            recurrence.previousOccurrence(DateTime(2025, 1, 15));
        expect(prevOccurrence, isNull);
      });

      test('uses range parameter to filter rule results', () {
        final dailyRule = RecurrenceRule.daily();

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule],
        );

        // When from is 2025-01-05, the rule would give 2025-01-04
        // But if we restrict to range between Jan 10-20, the rule result is filtered out
        final restrictedRange = CustomTimeRange(
          DateTime(2025, 1, 10),
          DateTime(2025, 1, 20),
        );

        // The rule's previousOccurrence will return 2025-01-04, but it's outside the restrictedRange
        // So previousOccurrence should filter it out and pass null to the comparator
        final prevOccurrence = recurrence.previousOccurrence(
          DateTime(2025, 1, 5),
          range: restrictedRange,
        );

        // Since the rule's occurrence is outside the range, it becomes null
        // With only one rule, the result would be null
        expect(prevOccurrence, isNull);
      });

      test('applies time range to each rule before sorting results', () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);

        final recurrence = Recurrence(
          range: CustomTimeRange(
            DateTime(2025, 1, 1),
            DateTime(2025, 12, 31),
          ),
          rules: [dailyRule, weeklyRule],
        );

        final restrictedRange = MonthTimeRange(2025, 1);

        // When from is 2025-02-05:
        // - dailyRule gives 2025-02-04, which is outside restrictedRange, so null
        // - weeklyRule gives 2025-01-29 (last Wednesday in January)
        final prevOccurrence = recurrence.previousOccurrence(
          DateTime(2025, 2, 5),
          range: restrictedRange,
        );
        expect(prevOccurrence, equals(DateTime(2025, 1, 29)));
      });

      test('deduplicates occurrences from different rules', () {
        final fridayRule = RecurrenceRule.weekly(DateTime.friday);
        final dayRule = RecurrenceRule.monthly(3); // 3rd of month

        // January 3, 2025 is both Friday and the 3rd of the month
        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [fridayRule, dayRule],
        );

        // From January 10, 2025, both rules would give January 3
        // But we should get only one result
        final occurrences = recurrence.rules
            .map((rule) => rule.previousOccurrence(DateTime(2025, 1, 10)))
            .toList();

        expect(occurrences.length, equals(2)); // Two rules, two occurrences

        final prevOccurrence =
            recurrence.previousOccurrence(DateTime(2025, 1, 10));
        expect(prevOccurrence, equals(DateTime(2025, 1, 3)));
      });
    });

    group('nextAbsoluteOccurrence', () {
      test('returns the nearest next occurrence if it fits in the range', () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule, weeklyRule],
        );

        // From 2025-01-10, the next occurrence is 2025-01-11 (from daily rule)
        // This is within the range, so it should be returned
        final nextOccurrence = recurrence.nextAbsoluteOccurrence(
          DateTime(2025, 1, 10),
          subrange: recurrence.range,
        );
        expect(nextOccurrence, equals(DateTime(2025, 1, 11)));
      });

      test(
          'returns null if the nearest next occurrence does not fit in the range',
          () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule, weeklyRule],
        );

        // From 2025-01-10, the next occurrence is 2025-01-11 (from daily rule)
        // But if we restrict to February, this occurrence is outside the range
        final restrictedRange = MonthTimeRange(2025, 2);

        final nextOccurrence = recurrence.nextAbsoluteOccurrence(
          DateTime(2025, 1, 10),
          subrange: restrictedRange,
        );
        // Should return null even though there are occurrences in February
        expect(nextOccurrence, isNull);
      });

      test('ignores range parameter when finding nearest occurrence', () {
        final dailyRule = RecurrenceRule.daily();

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule],
        );

        // The absolute next occurrence from 2025-01-10 is 2025-01-11
        // Even if we provide a range for February, it should still consider January occurrences
        final restrictedRange = MonthTimeRange(2025, 2);

        final candidate = dailyRule.nextOccurrence(DateTime(2025, 1, 10));
        expect(candidate, equals(DateTime(2025, 1, 11)));
        expect(restrictedRange.contains(candidate!), isFalse);

        final nextOccurrence = recurrence.nextAbsoluteOccurrence(
          DateTime(2025, 1, 10),
          subrange: restrictedRange,
        );
        expect(nextOccurrence, isNull);
      });

      test('deduplicates occurrences from different rules', () {
        final mondayRule = RecurrenceRule.weekly(DateTime.monday);
        final dayRule = RecurrenceRule.monthly(6); // 6th of month

        // January 6, 2025 is both Monday and the 6th of the month
        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [mondayRule, dayRule],
        );

        // From January 1, 2025, both rules would give January 6
        final nextOccurrence =
            recurrence.nextAbsoluteOccurrence(DateTime(2025, 1, 1));
        expect(nextOccurrence, equals(DateTime(2025, 1, 6)));
      });
    });

    group('previousAbsoluteOccurrence', () {
      test('returns the nearest previous occurrence if it fits in the range',
          () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule, weeklyRule],
        );

        // From 2025-01-10, the previous occurrence is 2025-01-09 (from daily rule)
        // This is within the range, so it should be returned
        final prevOccurrence = recurrence.previousAbsoluteOccurrence(
          DateTime(2025, 1, 10),
          subrange: recurrence.range,
        );
        expect(prevOccurrence, equals(DateTime(2025, 1, 9)));
      });

      test(
          'returns null if the nearest previous occurrence does not fit in the range',
          () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = RecurrenceRule.weekly(DateTime.wednesday);

        final recurrence = Recurrence(
          range: MonthTimeRange(2025, 2), // February only
          rules: [dailyRule, weeklyRule],
        );

        // From 2025-03-02, the previous occurrence is 2025-03-01 (from daily rule)
        // But our recurrence range is only February, so this is outside the range
        final prevOccurrence = recurrence.previousAbsoluteOccurrence(
          DateTime(2025, 3, 2),
          subrange: recurrence.range,
        );
        // Should return null even though there are occurrences in February
        expect(prevOccurrence, isNull);
      });

      test('ignores range parameter when finding nearest occurrence', () {
        final dailyRule = RecurrenceRule.daily();

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule],
        );

        // The absolute previous occurrence from 2025-03-01 is 2025-02-28
        // Even if we provide a range for January, it should still consider February occurrences
        final restrictedRange = MonthTimeRange(2025, 1);

        final candidate = dailyRule.previousOccurrence(DateTime(2025, 3, 1));
        expect(candidate, equals(DateTime(2025, 2, 28)));
        expect(restrictedRange.contains(candidate!), isFalse);

        final prevOccurrence = recurrence.previousAbsoluteOccurrence(
          DateTime(2025, 3, 1),
          subrange: restrictedRange,
        );
        expect(prevOccurrence, isNull);
      });

      test('deduplicates occurrences from different rules', () {
        final fridayRule = RecurrenceRule.weekly(DateTime.friday);
        final dayRule = RecurrenceRule.monthly(3); // 3rd of month

        // January 3, 2025 is both Friday and the 3rd of the month
        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [fridayRule, dayRule],
        );

        // From January 10, 2025, both rules would give January 3
        final prevOccurrence =
            recurrence.previousAbsoluteOccurrence(DateTime(2025, 1, 10));
        expect(prevOccurrence, equals(DateTime(2025, 1, 3)));
      });
    });

    group('Comparison between standard and absolute methods', () {
      test(
          'nextOccurrence finds an occurrence within range while nextAbsoluteOccurrence returns null',
          () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = WeeklyRecurrenceRule(weekday: DateTime.monday);

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule, weeklyRule],
        );

        final restrictedRange = MonthTimeRange(2025, 2);

        final nextAbsolute = recurrence.nextAbsoluteOccurrence(
          DateTime(2025, 1, 30),
          subrange: restrictedRange,
        );
        expect(nextAbsolute, isNull);

        final next = recurrence.nextOccurrence(
          DateTime(2025, 1, 30),
          subrange: restrictedRange,
        );
        expect(next, equals(DateTime(2025, 2, 3)));
      });

      test(
          'previousOccurrence finds an occurrence within range while previousAbsoluteOccurrence returns null',
          () {
        final dailyRule = RecurrenceRule.daily();
        final weeklyRule = WeeklyRecurrenceRule(weekday: DateTime.monday);

        final recurrence = Recurrence(
          range: YearTimeRange(2025),
          rules: [dailyRule, weeklyRule],
        );

        final restrictedRange = MonthTimeRange(2025, 3);

        final prevAbsolute = recurrence.previousAbsoluteOccurrence(
          DateTime(2025, 4, 2),
          subrange: restrictedRange,
        );
        expect(prevAbsolute, isNull);

        final prev = recurrence.previousOccurrence(
          DateTime(2025, 4, 2),
          range: restrictedRange,
        );
        expect(prev, equals(DateTime(2025, 3, 31)));
      });
    });
  });
}
