import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/src/base.dart';

class WeeklyRecurrenceRule extends RecurrenceRule<int> {
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
}
