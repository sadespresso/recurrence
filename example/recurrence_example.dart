// ignore_for_file: unused_local_variable
import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/recurrence.dart';
import 'package:recurrence/src/interval.dart';

void main() {
  final CustomTimeRange aYearFromNow = CustomTimeRange(
    Moment.now(),
    Moment.now().add(
      Duration(days: 365),
    ),
  );

  final everyOtherWeekStartingToday = IntervalRecurrenceRule(
    data: Duration(days: 14),
  ).occurrences(
    range: aYearFromNow,
  );

  final nextMonday =
      WeeklyRecurrenceRule(weekday: DateTime.monday).nextOccurrence(
    Moment.now(),
  );

  final allFirstOfMayThisCentury = YearlyRecurrenceRule(
    month: DateTime.may,
    day: 1,
  ).occurrences(
    range: CustomTimeRange(
      DateTime(2000),
      DateTime(2099).endOfYear(),
    ),
  );
}
