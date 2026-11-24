import 'dart:io';

bool get platformSupportsLocalNotifications =>
    Platform.isAndroid || Platform.isIOS;

bool get platformCanRequestExactAlarms => Platform.isAndroid;
