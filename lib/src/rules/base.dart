import "package:moment_dart/moment_dart.dart";
import "package:recurrence/recurrence.dart";

/// [RecurrenceRule] does not represent any occurrence, or point in time. It
/// simply represents how one should calculate the next occurence based off of
/// an anchor (from).
abstract class RecurrenceRule<T> {
  const RecurrenceRule();

  T get data;

  /// Must be parseable back to the same rule
  String serialize();

  /// Returns the same value as [serialize]
  @override
  String toString() => serialize();

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

  static RecurrenceRule parse(String data) {
    final parts = data.split(";");

    switch (parts[0]) {
      case "daily":
        return const IntervalRecurrenceRule(data: Duration(days: 1));
      case "weekly":
        return WeeklyRecurrenceRule.parse(data);
      case "monthly":
        return MonthlyRecurrenceRule.parse(data);
      case "yearly":
        return YearlyRecurrenceRule.parse(data);
      case "interval":
        return IntervalRecurrenceRule.parse(data);
      default:
        throw ArgumentError.value(
          data,
          "data",
          "Unknown recurrence rule",
        );
    }
  }

  static RecurrenceRule? tryParse(String data) {
    try {
      return parse(data);
    } catch (_) {
      return null;
    }
  }

  /// Just a constant interval, adds or subtracts `const Duration(days: 1)`
  static IntervalRecurrenceRule daily() =>
      const IntervalRecurrenceRule(data: Duration(days: 1));

  static WeeklyRecurrenceRule weekly(int weekday) =>
      WeeklyRecurrenceRule(weekday: weekday);

  /// [day] - gets clamped per each month.
  ///
  /// e.g.,
  /// When day is `31`, it may be clamped to `28` in february, or `30` in november
  static MonthlyRecurrenceRule monthly(int day) =>
      MonthlyRecurrenceRule(day: day);

  /// [month], [day]. Both gets clamped.
  ///
  /// e.g.,
  /// * When month is `4` and day is `31`, the day will be clamped to `30` since april has only `30` days.
  /// * When month is `2` and day is `29`, the day will be clamped to `28` on non-leap years since february has only `28` days in non-leap years.
  ///
  static YearlyRecurrenceRule yearly(int month, int day) =>
      YearlyRecurrenceRule(month: month, day: day);

  /// Just a constant interval based on the [from] date.
  static IntervalRecurrenceRule interval(Duration data) =>
      IntervalRecurrenceRule(data: data);
}
