import "package:moment_dart/moment_dart.dart";
import "package:recurrence/src/rules/base.dart";

class YearlyRecurrenceMonthDay {
  final int month;
  final int day;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! YearlyRecurrenceMonthDay) return false;

    if (other.month != month) return false;

    if (other.day != day) return false;

    return true;
  }

  @override
  int get hashCode => Object.hashAll([month, day]);

  const YearlyRecurrenceMonthDay(this.month, this.day)
      : assert(month >= 1 && month <= 12, "Month must be in range [1,12]"),
        assert(day >= 1 && day <= 31, "Day must be in range [1,31]"),
        super();
}

class YearlyRecurrenceRule extends RecurrenceRule<YearlyRecurrenceMonthDay> {
  @override
  final YearlyRecurrenceMonthDay data;

  YearlyRecurrenceRule({required int month, required int day})
      : data = YearlyRecurrenceMonthDay(month, day);

  const YearlyRecurrenceRule.withData({required this.data});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! YearlyRecurrenceRule) return false;

    if (other.data != data) return false;

    return true;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String serialize() => "yearly;${data.month};${data.day}";

  static YearlyRecurrenceRule parse(String data) {
    final parts = data.split(";");

    if (parts.length != 3) {
      throw ArgumentError.value(
        data,
        "data",
        "Data must have exactly two semicolons",
      );
    }

    final month = int.parse(parts[1]);

    if (month < DateTime.january || month > DateTime.december) {
      throw ArgumentError.value(
        data,
        "data",
        "Month must be in range [1,12]",
      );
    }

    final day = int.parse(parts[2]);

    if (day < 1 || day > 31) {
      throw ArgumentError.value(
        data,
        "data",
        "Day must be in range [1,31]",
      );
    }

    return YearlyRecurrenceRule(month: month, day: day);
  }

  static YearlyRecurrenceRule? tryParse(String data) {
    try {
      return parse(data);
    } catch (_) {
      return null;
    }
  }

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
