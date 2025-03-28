import "package:moment_dart/moment_dart.dart";

abstract class RecurrenceRule<T> {
  const RecurrenceRule();

  T get data;

  /// Returns the next occurrence after [from]
  ///
  /// If [from] is a valid occurence, still ignores it and gives the next one.
  ///
  /// If [range] isn't null, and the next occurrence is outside of the range (the range is inclusive),
  /// returns null
  ///
  /// This function does not check for time zones (utc, local), and resulting value will be in same time zone as [from].
  DateTime? nextOccurrence(DateTime from, {TimeRange? range});

  /// Returns the previous occurrence before [from]
  ///
  /// If [from] is a valid occurence, still ignores it and gives the previous one.
  ///
  /// If [range] isn't null, and the previous occurrence is outside of the range (the range is inclusive),
  /// returns null
  ///
  /// This function does not check for time zones (utc, local), and resulting value will be in same time zone as [from].
  DateTime? previousOccurrence(DateTime from, {TimeRange? range});

  /// This function does not check for time zones (utc, local)
  bool satisfies(DateTime date, {TimeRange? range});

  /// Returns all occurrences within [range] (inclusive)
  ///
  /// This function does not check for time zones (utc, local), and resulting value will be in same time zone as [range.from].
  List<DateTime> occurrences({required TimeRange range}) {
    final List<DateTime> result = [];

    if (satisfies(range.from, range: range)) {
      result.add(range.from);
    }

    for (;;) {
      final next = nextOccurrence(
        result.isEmpty ? range.from : result.last,
        range: range,
      );

      if (next == null) {
        break;
      }

      result.add(next);
    }

    return result;
  }
}
