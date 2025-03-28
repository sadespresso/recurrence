import "package:moment_dart/moment_dart.dart";
import "package:recurrence/src/base.dart";

class YearlyRecurrenceMonthDay {
  final int month;
  final int day;

  const YearlyRecurrenceMonthDay(this.month, this.day)
      : assert(month >= 1 && month <= 12, "Month must be in range [1,12]"),
        assert(day >= 1 && day <= 31, "Day must be in range [1,31]"),
        super();
}

class YearlyRecurrence extends RecurrenceRule<YearlyRecurrenceMonthDay> {
  @override
  final YearlyRecurrenceMonthDay data;

  YearlyRecurrence({required int month, required int day})
      : data = YearlyRecurrenceMonthDay(month, day);

  const YearlyRecurrence.withData({required this.data});

  @override
  DateTime? nextOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime currentYearCandidate = DateTimeConstructors.dateWithTimezone(
      from.year,
      1,
      1,
      from.isUtc,
    ).setClampedMonth(data.month).setClampedDay(data.day);

    if (currentYearCandidate.isAfter(from)) {
      return currentYearCandidate;
    }

    final DateTime nextYearCandidate = DateTimeConstructors.dateWithTimezone(
      from.year + 1,
      1,
      1,
      from.isUtc,
    ).setClampedMonth(data.month).setClampedDay(data.day);

    if (range != null && !range.contains(nextYearCandidate)) {
      return null;
    }

    return nextYearCandidate;
  }

  @override
  DateTime? previousOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime currentYearCandidate = DateTimeConstructors.dateWithTimezone(
      from.year,
    ).setClampedMonth(data.month).setClampedDay(data.day);

    if (currentYearCandidate.isBefore(from)) {
      return currentYearCandidate;
    }

    final DateTime previousYearCandidate =
        DateTimeConstructors.dateWithTimezone(
      from.year - 1,
      1,
      1,
      from.isUtc,
    ).setClampedMonth(data.month).setClampedDay(data.day);

    if (range != null && !range.contains(previousYearCandidate)) {
      return null;
    }

    return previousYearCandidate;
  }

  @override
  bool satisfies(DateTime date, {TimeRange? range}) =>
      date.month == data.month &&
      date.day == data.day &&
      (range == null || range.contains(date));
}
