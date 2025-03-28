import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

class MonthlyRecurrenceRule extends RecurrenceRule<int> {
  /// Allowed range is [1,31], this is not enforced, expect unexpected behavior
  /// for illegal values.
  @override
  final int data;

  const MonthlyRecurrenceRule({required int day})
      : assert(day >= 1 && day <= 31),
        data = day,
        super();

  @override
  DateTime? nextOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime currentMonthCandidate =
        DateTimeConstructors.dateWithTimezone(
      from.year,
      from.month,
      from.day,
      from.isUtc,
    ).setClampedDay(data);

    if (currentMonthCandidate.isAfter(from)) {
      return currentMonthCandidate;
    }

    final DateTime nextMonthCandidate = DateTimeConstructors.dateWithTimezone(
      from.year,
      from.month + 1,
      1,
      from.isUtc,
    ).setClampedDay(data);

    if (range != null && !range.contains(nextMonthCandidate)) {
      return null;
    }

    return nextMonthCandidate;
  }

  @override
  DateTime? previousOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime lastMonthCandidate = DateTimeConstructors.dateWithTimezone(
      from.year,
      from.month,
      1,
      from.isUtc,
    ).setClampedDay(data);

    if (lastMonthCandidate.isBefore(from)) {
      return lastMonthCandidate;
    }

    final DateTime previousMonthCandidate =
        DateTimeConstructors.dateWithTimezone(
      from.year,
      from.month - 1,
      1,
      from.isUtc,
    ).setClampedDay(data);

    if (range != null && !range.contains(previousMonthCandidate)) {
      return null;
    }

    return previousMonthCandidate;
  }

  @override
  bool satisfies(DateTime date, {TimeRange? range}) =>
      date.day == data && (range == null || range.contains(date));
}
