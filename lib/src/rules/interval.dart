import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';

/// This rule does not consider any type of special logic, such as leap years,
/// clamping, or overflow.
///
/// It simply represents [data] offsets from the given range's [TimeRange.from]
/// property.
///
/// [satisfies] always returns true
///
/// e.g., Every 1 hour, every 100 milliseconds, etc.
///
/// If you want to use multiple rules, check out [Recurrence].
class IntervalRecurrenceRule extends RecurrenceRule<Duration> {
  @override
  final Duration data;

  const IntervalRecurrenceRule({required this.data}) : super();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! IntervalRecurrenceRule) return false;

    if (other.data != data) return false;

    return true;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String serialize() => "interval;${data.inMicroseconds.toRadixString(36)}";

  static IntervalRecurrenceRule parse(String data) {
    final parts = data.split(";");

    if (parts.length != 2) {
      throw ArgumentError.value(
        data,
        "data",
        "Data must have exactly one semicolon",
      );
    }

    if (parts[0] != "interval") {
      throw ArgumentError.value(
        data,
        "data",
        "Data must start with 'interval;'",
      );
    }

    final Duration duration =
        Duration(microseconds: int.parse(parts[1], radix: 36));

    return IntervalRecurrenceRule(data: duration);
  }

  static IntervalRecurrenceRule? tryParse(String data) {
    try {
      return parse(data);
    } catch (_) {
      return null;
    }
  }

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
