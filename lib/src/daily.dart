import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';

/// [satisfies] always returns true
class DailyRecurrenceRule extends RecurrenceRule<Null> {
  @override
  final Null data;

  const DailyRecurrenceRule()
      : data = null,
        super();

  @override
  DateTime? nextOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime candidate = from.add(const Duration(days: 1));

    if (range != null && !range.contains(candidate)) {
      return null;
    }

    return candidate;
  }

  @override
  DateTime? previousOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime candidate = from.subtract(const Duration(days: 1));

    if (range != null && !range.contains(candidate)) {
      return null;
    }

    return candidate;
  }

  @override
  bool satisfies(DateTime date, {TimeRange? range}) =>
      range == null || range.contains(date);
}
