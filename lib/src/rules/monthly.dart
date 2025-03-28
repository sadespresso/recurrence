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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! MonthlyRecurrenceRule) return false;

    if (other.data != data) return false;

    return true;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String serialize() => "monthly;$data";

  static MonthlyRecurrenceRule parse(String data) {
    final parts = data.split(";");

    if (parts.length != 2) {
      throw ArgumentError.value(
        data,
        "data",
        "Data must have exactly one semicolon",
      );
    }

    if (parts[0] != "monthly") {
      throw ArgumentError.value(
        data,
        "data",
        "Data must start with 'monthly;'",
      );
    }

    final int day = int.parse(parts[1]);

    if (day < 1 || day > 31) {
      throw ArgumentError.value(
        data,
        "data",
        "Day must be in range [1,31]",
      );
    }

    return MonthlyRecurrenceRule(day: day);
  }

  MonthlyRecurrenceRule? tryParse(String data) {
    try {
      return parse(data);
    } catch (_) {
      return null;
    }
  }

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
