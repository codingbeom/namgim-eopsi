import 'package:timezone/timezone.dart' as tz;

/// IANA `Etc/GMT` signs are reversed: Korea (UTC+9) is `Etc/GMT-9`.
///
/// Whole hours only. Minute offsets fall back to UTC when the device timezone
/// name could not be read.
String fallbackTimeZoneName(Duration offset) {
  final minutes = offset.inMinutes;
  if (minutes == 0) return 'Etc/GMT';
  if (minutes % 60 != 0) return 'UTC';
  final hours = minutes ~/ 60;
  final sign = hours > 0 ? '-' : '+';
  return 'Etc/GMT$sign${hours.abs()}';
}

/// Wall-clock fields in [tz.local], without shifting them through UTC.
tz.TZDateTime zonedWallClock(DateTime wall) {
  return tz.TZDateTime(
    tz.local,
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
  );
}
