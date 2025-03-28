import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';

/// [satisfies] always returns true
class IntervalRecurrenceRule extends RecurrenceRule<Duration> {
  @override
  final Duration data;

  const IntervalRecurrenceRule({required this.data}) : super();

  @override
  DateTime? nextOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime candidate = from.add(data);

    if (range != null && !range.contains(candidate)) {
      return null;
    }

    return candidate;
  }

  @override
  DateTime? previousOccurrence(DateTime from, {TimeRange? range}) {
    final DateTime candidate = from.subtract(data);

    if (range != null && !range.contains(candidate)) {
      return null;
    }

    return candidate;
  }

  @override
  bool satisfies(DateTime date, {TimeRange? range}) =>
      range == null || range.contains(date);
}
