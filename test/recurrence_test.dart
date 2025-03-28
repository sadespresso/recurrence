import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/src/recurrence.dart';
import 'package:recurrence/src/rules/interval.dart';
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
}
