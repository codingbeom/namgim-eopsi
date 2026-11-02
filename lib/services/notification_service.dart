import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Skeleton for expiry notifications.
///
/// TODO(week5): schedule with workmanager once a day, then
/// `zonedSchedule` per storage location.
/// Fridge and freezer: a few days before, plus the morning of expiry.
/// Pantry: two weeks before, then one week before.
/// TODO(week5): notification actions 먹음 / 버림 should update Drift without
/// opening the app (ActionBroadcastReceiver is already in the Android manifest).
/// TODO(week5): the 메뉴 보기 action should deep link to /recipes.
/// TODO(week7): home_widget for the imminent list. Not started.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool initialized = false;
  String? initNote;

  Future<void> initialize() async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      initialized = await _plugin.initialize(settings: settings) ?? false;
      initNote = initialized
          ? '알림 플러그인은 준비됐어요. 예약은 5주차에 붙여요.'
          : '이 환경에서는 알림 플러그인을 쓰지 않아요.';
    } catch (error) {
      initialized = false;
      initNote = '알림 초기화는 건너뛰었어요. 재료 기록은 그대로 동작해요.';
      debugPrint('notification init skipped: $error');
    }
  }
}
