/// Dart mirror of .NET's `DayOfWeek` used by `WorkoutDayDto.ScheduledDay`.
///
/// The backend serializes `DayOfWeek?` as an integer where Sunday = 0 …
/// Saturday = 6. A `null` value means the day is **unscheduled** (not tied to a
/// weekday); model it as a nullable [Weekday] and use [Weekday.fromValue] /
/// [Weekday.value] at the JSON boundary.
library;

enum Weekday {
  sunday(0, 'weekday_sunday'),
  monday(1, 'weekday_monday'),
  tuesday(2, 'weekday_tuesday'),
  wednesday(3, 'weekday_wednesday'),
  thursday(4, 'weekday_thursday'),
  friday(5, 'weekday_friday'),
  saturday(6, 'weekday_saturday');

  const Weekday(this.value, this.labelKey);

  final int value;
  final String labelKey;

  /// Map the wire integer to a [Weekday]. Returns `null` (unscheduled) when
  /// [value] is null or out of range.
  static Weekday? fromValue(int? value) {
    if (value == null) return null;
    for (final d in Weekday.values) {
      if (d.value == value) return d;
    }
    return null;
  }
}
