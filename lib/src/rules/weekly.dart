import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/src/alignable.dart';
import 'package:recurrence/src/rules/base.dart';

/// Each week's same weekday.
///
/// Concept of "week" is same as [moment_dart](https://pub.dev/packages/moment_dart)'s.
///
/// e.g., Every Monday, every Tuesday, etc.
///
/// If you want to use multiple rules, check out [Recurrence].
class WeeklyRecurrenceRule extends RecurrenceRule<int>
    implements Alignable<WeeklyRecurrenceRule> {
  /// Same number as DateTime defined weekdays.
  ///
  /// * 1 is Monday (same as [DateTime.monday])
  /// * 7 is Sunday (same as [DateTime.sunday])
  @override
  final int data;

  const WeeklyRecurrenceRule({required int weekday})
      : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday),
        data = weekday,
        super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! WeeklyRecurrenceRule) return false;

    if (other.data != data) return false;

    return true;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String serialize() => "weekly;$data";

  static WeeklyRecurrenceRule parse(String data) {
    final parts = data.split(";");

    if (parts.length != 2) {
      throw ArgumentError.value(
        data,
        "data",
        "Invalid data",
      );
    }

    if (parts[0] != "weekly") {
      throw ArgumentError.value(
        data,
        "data",
        "Data must start with 'weekly;'",
      );
    }

    final weekday = int.parse(parts[1]);

    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw ArgumentError.value(
        data,
        "data",
        "Weekday must be in range [1,7]",
      );
    }

    return WeeklyRecurrenceRule(weekday: weekday);
  }

  @override
  DateTime? nextOccurrence(DateTime from, {TimeRange? range}) {
    final next = from.nextWeekday(data);

    if (range != null && !range.contains(next)) {
      return null;
    }

    return next;
  }

  @override
  DateTime? previousOccurrence(DateTime from, {TimeRange? range}) {
    final previous = from.lastWeekday(data);

    if (range != null && !range.contains(previous)) {
      return null;
    }

    return previous;
  }

  @override
  bool satisfies(DateTime date, {TimeRange? range}) =>
      date.weekday == data && (range == null || range.contains(date));

  @override
  WeeklyRecurrenceRule alignTo(DateTime dateTime) =>
      WeeklyRecurrenceRule(weekday: dateTime.weekday);
}
