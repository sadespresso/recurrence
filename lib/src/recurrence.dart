import 'package:moment_dart/moment_dart.dart';
import 'package:recurrence/src/rules/base.dart';

/// Use this class to define a recurrence pattern.
///
/// Use [toJson] and [fromJson] to serialize and deserialize a recurrence.
class Recurrence {
  final TimeRange range;
  final List<RecurrenceRule> rules;

  const Recurrence({required this.range, required this.rules});

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

  String serialize() =>
      "${rules.map((rule) => rule.serialize()).join("&")}->${range.encodeShort()}";

  static Recurrence deserialize(String serialized) {
    final parts = serialized.split("->");
    final range = TimeRange.parse(parts[1]);
    final rules =
        parts[0].split("&").map((rule) => RecurrenceRule.parse(rule)).toList();
    return Recurrence(range: range, rules: rules);
  }

  static Recurrence parse(String serialized) => deserialize(serialized);

  static Recurrence? tryParse(String serialized) {
    try {
      return parse(serialized);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "range": range.encodeShort(),
      "rules": rules.map((rule) => rule.toString()).toList(),
    };
  }

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
