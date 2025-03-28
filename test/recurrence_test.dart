import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/src/recurrence.dart';
import 'package:recurrence/src/rules/base.dart';
import 'package:recurrence/src/rules/interval.dart';
import 'package:recurrence/src/rules/weekly.dart';
import 'package:recurrence/src/rules/monthly.dart';
import 'package:recurrence/src/rules/yearly.dart';
import 'package:test/test.dart';

void main() {
  group("Generic parsing cases", () {
    test("Everyday in Jan 2025", () {
      final String serialized =
          "interval;13owbuo0->MonthTimeRange@2025-01-01T00:00:00.000";

      expect(
          Recurrence.parse(serialized),
          Recurrence(
              range: MonthTimeRange(2025, 1),
              rules: [IntervalRecurrenceRule(data: const Duration(days: 1))]));
    });

    test("Random case 1", () {
      final rule = IntervalRecurrenceRule(data: const Duration(days: 1));
      final range = MonthTimeRange(2025, 1);

      final recurrence = Recurrence(range: range, rules: [rule]);

      expect(
        Recurrence.parse(recurrence.serialize()),
        recurrence,
      );
    });
  });

  group("Multiple rules", () {
    test("Every Monday and Wednesday in Jan 2025", () {
      final List<RecurrenceRule> rules = [
        WeeklyRecurrenceRule(weekday: DateTime.monday),
        WeeklyRecurrenceRule(weekday: DateTime.wednesday),
      ];
      final range = MonthTimeRange(2025, 1);
      final recurrence = Recurrence(range: range, rules: rules);

      expect(
        Recurrence.parse(recurrence.serialize()),
        recurrence,
      );
    });
  });

  group("Different time ranges", () {
    test("Daily in a specific month", () {
      final rule = IntervalRecurrenceRule(data: const Duration(days: 1));
      final range = MonthTimeRange(2025, 1);
      final recurrence = Recurrence(range: range, rules: [rule]);

      expect(
        Recurrence.parse(recurrence.serialize()),
        recurrence,
      );
    });

    test("Monthly on 15th in a specific year", () {
      final rule = MonthlyRecurrenceRule(day: 15);
      final range = YearTimeRange(2025);
      final recurrence = Recurrence(range: range, rules: [rule]);

      expect(
        Recurrence.parse(recurrence.serialize()),
        recurrence,
      );
    });
  });

  group("JSON conversion", () {
    test("Convert to and from JSON", () {
      final rule = YearlyRecurrenceRule(month: 12, day: 25);
      final range = YearTimeRange(2025);
      final recurrence = Recurrence(range: range, rules: [rule]);

      final json = recurrence.toJson();
      final fromJson = Recurrence.fromJson(json);

      expect(fromJson, recurrence);
    });
  });

  group("Error handling", () {
    test("tryParse returns null for invalid input", () {
      expect(Recurrence.tryParse("invalid"), null);
    });

    test("parse throws for invalid input", () {
      expect(() => Recurrence.parse("invalid"), throwsArgumentError);
    });
  });

  group("Complex cases", () {
    test("Multiple rules with different types", () {
      final List<RecurrenceRule> rules = [
        IntervalRecurrenceRule(data: const Duration(days: 1)),
        WeeklyRecurrenceRule(weekday: DateTime.monday),
        MonthlyRecurrenceRule(day: 1),
        YearlyRecurrenceRule(month: 1, day: 1),
      ];
      final range = YearTimeRange(2025);
      final recurrence = Recurrence(range: range, rules: rules);

      expect(
        Recurrence.parse(recurrence.serialize()),
        recurrence,
      );
    });

    test("Custom interval duration", () {
      final rule = IntervalRecurrenceRule(data: const Duration(hours: 12));
      final range = MonthTimeRange(2025, 1);
      final recurrence = Recurrence(range: range, rules: [rule]);

      expect(
        Recurrence.parse(recurrence.serialize()),
        recurrence,
      );
    });
  });
}
