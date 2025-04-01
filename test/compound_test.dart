import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';
import 'package:test/test.dart';

void main() {
  test("Two weekdays", () {
    final rule = RecurrenceRule.weekly(DateTime.monday);
    final rule2 = RecurrenceRule.weekly(DateTime.wednesday);

    final range = MonthTimeRange(2025, 1).toUtc();
    final recurrence = Recurrence(range: range, rules: [rule, rule2]);

    expect(
      recurrence.occurrences(range: range),
      [
        DateTime.utc(2025, 1, 1),
        DateTime.utc(2025, 1, 6),
        DateTime.utc(2025, 1, 8),
        DateTime.utc(2025, 1, 13),
        DateTime.utc(2025, 1, 15),
        DateTime.utc(2025, 1, 20),
        DateTime.utc(2025, 1, 22),
        DateTime.utc(2025, 1, 27),
        DateTime.utc(2025, 1, 29),
      ],
    );
  });

  test("Daily and Monthly", () {
    final dailyRule = RecurrenceRule.daily();
    final monthlyRule = RecurrenceRule.monthly(15);

    final range = MonthTimeRange(2025, 1).toUtc();
    final recurrence =
        Recurrence(range: range, rules: [dailyRule, monthlyRule]);

    final occurrences = recurrence.occurrences(range: range);

    expect(occurrences.length, 31);
    expect(
      recurrence.occurrences(range: range),
      [for (int i = 1; i <= 31; i++) DateTime.utc(2025, 1, i)],
    );
  });

  test("Yearly and Interval", () {
    final yearlyRule = RecurrenceRule.yearly(DateTime.january, 1);
    final intervalRule = RecurrenceRule.interval(Duration(days: 10));

    final range = YearTimeRange(2025).toUtc();
    final recurrence =
        Recurrence(range: range, rules: [yearlyRule, intervalRule]);

    final occurrences = recurrence.occurrences(range: range);

    expect(occurrences.length, 37);

    expect(occurrences, [
      for (int i = 0; i < 365; i++)
        if (i % 10 == 0) DateTime.utc(2025, 1, 1).add(Duration(days: i)),
    ]);
  });

  test("Weekly and Yearly", () {
    final weeklyRule = RecurrenceRule.weekly(DateTime.friday);
    final yearlyRule = RecurrenceRule.yearly(DateTime.december, 23);

    final range = YearTimeRange(2025).toUtc();
    final recurrence =
        Recurrence(range: range, rules: [weeklyRule, yearlyRule]);

    expect(
      recurrence.occurrences(range: range).contains(DateTime.utc(2025, 12, 23)),
      true,
    );
  });
}
