# Recurrence

A custom recurrence rules implementation for [flow](https://github.com/flow-mn/flow)

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  recurrence: ^0.0.7
```

## Usage

### Daily Recurrence

```dart
final daily = DailyRecurrenceRule();

// Get next occurrence
final next = daily.nextOccurrence(DateTime.now()); // 
// Get previous occurrence
final previous = daily.previousOccurrence(DateTime.now());
```

### Weekly Recurrence

```dart
// Create a rule for Mondays
final weekly = WeekdayRecurrence(data: DateTime.monday);

// Get next Monday
final nextMonday = weekly.nextOccurrence(DateTime.now());
// Get previous Monday
final previousMonday = weekly.previousOccurrence(DateTime.now());
```

### Monthly Recurrence

```dart
// Create a rule for the 15th of each month
final monthly = MonthlyRecurrenceRule(data: 15);

// Get next occurrence on the 15th
final next = monthly.nextOccurrence(DateTime.now());
// Get previous occurrence on the 15th
final previous = monthly.previousOccurrence(DateTime.now());
```

### Yearly Recurrence

```dart
// Create a rule for March 15th
final yearly = YearlyRecurrence(month: 3, day: 15);

// Get next occurrence on March 15th
final next = yearly.nextOccurrence(DateTime.now());
// Get previous occurrence on March 15th
final previous = yearly.previousOccurrence(DateTime.now());
```

### Interval Recurrence

```dart
// Create a rule for every 2 days
final interval = IntervalRecurrenceRule(data: Duration(days: 2));

// Get next occurrence
final next = interval.nextOccurrence(DateTime.now());
// Get previous occurrence
final previous = interval.previousOccurrence(DateTime.now());
```

### Working with Time Ranges

```dart
final daily = DailyRecurrenceRule();
final range = CustomTimeRange(
  DateTime(2024, 3, 15),
  DateTime(2024, 3, 20),
);

// Get all occurrences within the range
final occurrences = daily.occurrences(range: range);

// Get next occurrence within the range
final next = daily.nextOccurrence(DateTime.now(), range: range);
```

## Additional information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

If you find any issues or have suggestions for improvements, please file them in
the GitHub issue tracker.

### License

This package is licensed under the MIT License - see the LICENSE file for details.

> Majority of this file is AI generated
