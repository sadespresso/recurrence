import 'package:recurrence/recurrence.dart';

abstract class Alignable<T extends RecurrenceRule> {
  /// Aligns the rule's significant data based on [dateTime].
  ///
  /// e.g., Sets the weekday of a weekly rule to the weekday of [dateTime].
  T alignTo(DateTime dateTime);
}
