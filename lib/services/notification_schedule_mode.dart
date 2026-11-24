import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Exact alarms crash on Android 12+ when the permission is missing.
/// Inexact alarms still fire, a few minutes off, without that permission.
AndroidScheduleMode scheduleModeFor({required bool exactGranted}) {
  if (exactGranted) return AndroidScheduleMode.exactAllowWhileIdle;
  return AndroidScheduleMode.inexactAllowWhileIdle;
}
