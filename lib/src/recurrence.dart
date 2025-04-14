import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/src/rules/base.dart';

/// Use this class to define a recurrence pattern.
///
/// [range] is very important as its [TimeRange.from] property is used to
/// calculate the next occurrence.
///
/// Use [toJson] and [fromJson] to serialize and deserialize a recurrence.
///
/// For two rules to be equal, they must have the same [range] and the same
/// [rules] (with the same order)
class Recurrence {
  /// Its `.from` will be used as anchor for the next occurrence.
  final TimeRange range;
  final List<RecurrenceRule> rules;

  const Recurrence({required this.range, required this.rules});

  /// Creates a recurrence that starts at the given [start] date and ends at the
  /// [Moment.maxValue]
  ///
  /// [start] - defaults to [Moment.now] in a local time zone
  factory Recurrence.fromIndefinitely({
    required List<RecurrenceRule> rules,
    DateTime? start,
  }) =>
      Recurrence(
        range: (start ?? Moment.now()).rangeToMax(),
        rules: rules,
      );

  /// Creates a recurrence that starts at [Moment.minValue] and ends
  /// at [Moment.maxValue].
  factory Recurrence.forever({required List<RecurrenceRule> rules}) =>
      Recurrence(range: Moment.minValue.rangeToMax(), rules: rules);

  Recurrence copyWith({
    TimeRange? range,
    List<RecurrenceRule>? rules,
  }) =>
      Recurrence(
        range: range ?? this.range,
        rules: rules ?? this.rules,
      );

  List<DateTime> occurrences({required TimeRange range}) {
    final Set<DateTime> result = {};

    for (final rule in rules) {
      result.addAll(rule.occurrences(range: range));
    }

    return result.toList()..sort((a, b) => a.compareTo(b));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Recurrence) return false;

    if (other.range != range) return false;

    if (other.rules.length != rules.length) return false;

    for (int i = 0; i < rules.length; i++) {
      if (other.rules[i] != rules[i]) return false;
    }

    return true;
  }

  @override
  String toString() {
    return "Recurrence(range: $range, rules: $rules)";
  }

  /// Serializes the rule into a string.
  ///
  /// You can use [Recurrence.deserialize] to deserialize it.
  String serialize() =>
      "${rules.map((rule) => rule.serialize()).join("&")}->${range.encodeShort()}";

  /// Deserializes a string into a [Recurrence] object.
  ///
  /// The string must be in the format of
  /// `rule1&rule2->range`, where `rule1` and `rule2` are the serialized
  /// representations of the rules [RecurrenceRule], and `range` is the serialized representation
  /// of the range ([TimeRange]).
  static Recurrence deserialize(String serialized) {
    final parts = serialized.split("->");
    final range = TimeRange.parse(parts[1]);
    final rules =
        parts[0].split("&").map((rule) => RecurrenceRule.parse(rule)).toList();
    return Recurrence(range: range, rules: rules);
  }

  /// Synonym for [deserialize]
  static Recurrence parse(String serialized) => deserialize(serialized);

  /// Synonym for [deserialize], but returns null if the string is not valid
  static Recurrence? tryParse(String serialized) {
    try {
      return parse(serialized);
    } catch (e) {
      return null;
    }
  }

  /// Serializes the rule into a JSON object.
  Map<String, dynamic> toJson() {
    return {
      "range": range.encodeShort(),
      "rules": rules.map((rule) => rule.toString()).toList(),
    };
  }

  /// Deserializes a JSON object into a [Recurrence] object.
  ///
  /// The JSON object must have the following structure:
  factory Recurrence.fromJson(Map<String, dynamic> json) {
    return Recurrence(
      range: TimeRange.parse(json["range"]),
      rules: (json["rules"] as Iterable)
          .map((rule) => RecurrenceRule.parse(rule))
          .toList(),
    );
  }

  @override
  int get hashCode => Object.hashAll([range, rules]);
}
