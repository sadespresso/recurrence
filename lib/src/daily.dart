import 'package:recurrence/src/interval.dart';

/// [satisfies] always returns true
///
/// This is just [IntervalRecurrenceRule] with [data] set to `const Duration(days: 1)`
class DailyRecurrenceRule extends IntervalRecurrenceRule {
  const DailyRecurrenceRule() : super(data: const Duration(days: 1));
}
