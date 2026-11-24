import 'notification_platform_stub.dart'
    if (dart.library.io) 'notification_platform_io.dart'
    as platform;

bool get platformSupportsLocalNotifications =>
    platform.platformSupportsLocalNotifications;

bool get platformCanRequestExactAlarms =>
    platform.platformCanRequestExactAlarms;
