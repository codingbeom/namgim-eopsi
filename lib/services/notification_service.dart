import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import '../domain/expiry_reminders.dart';
import '../domain/models.dart';
import '../domain/notification_prefs.dart';
import 'notification_actions.dart';
import 'notification_clock.dart';
import 'notification_platform.dart';
import 'notification_schedule_mode.dart';

const expiryChannelId = 'namgim_expiry';
const expiryChannelName = '유통기한';
const expiryChannelDescription = '보관 중인 재료의 유통기한 알림';
const expiryCategoryId = 'expiry';
const testNotificationId = 900000001;

/// Daily background reschedule. The iOS identifier must match this string.
const expiryRefreshTaskName = 'expiry-refresh';
const expiryRefreshUniqueName = 'kr.namgim.namgim_eopsi.expiryRefresh';

enum NotificationAccess { unknown, granted, denied, unsupported }

typedef NotificationActionHandler = Future<void> Function(
  NotificationActionPlan plan,
);

/// Schedules on-device expiry alerts and keeps them in sync with Drift.
///
/// Web, desktop, and tests no-op. Android 12+ uses an exact alarm only when
/// the permission is already granted, and otherwise schedules an inexact alarm
/// so a missing permission cannot crash the process.
class NotificationService extends ChangeNotifier {
  NotificationService({bool? supported})
    : supported = supported ?? platformSupportsLocalNotifications;

  final bool supported;

  NotificationAccess access = NotificationAccess.unknown;
  bool exactAlarmsApplicable = false;
  bool exactAlarmsGranted = false;
  int scheduledCount = 0;
  String? initNote;
  String? pendingRoute;

  NotificationActionHandler? onAction;

  final StreamController<String> _routes = StreamController<String>.broadcast();

  Stream<String> get routes => _routes.stream;

  FlutterLocalNotificationsPlugin? _pluginField;
  bool _ready = false;
  bool _zonesReady = false;
  Future<void> _chain = Future<void>.value();
  void Function()? _dailyDispatcher;
  DidReceiveBackgroundNotificationResponseCallback? _onBackgroundResponse;

  FlutterLocalNotificationsPlugin get _plugin =>
      _pluginField ??= FlutterLocalNotificationsPlugin();

  String? takePendingRoute() {
    final route = pendingRoute;
    pendingRoute = null;
    return route;
  }

  Future<void> initialize({
    void Function()? dailyDispatcher,
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
    bool registerDailyWork = true,
  }) async {
    if (dailyDispatcher != null) _dailyDispatcher = dailyDispatcher;
    if (onBackgroundResponse != null) {
      _onBackgroundResponse = onBackgroundResponse;
    }
    if (!supported) {
      access = NotificationAccess.unsupported;
      exactAlarmsApplicable = false;
      notifyListeners();
      return;
    }
    try {
      await _ensureReady();
      await refreshStatus(notify: false);
      if (registerDailyWork) await _registerDailyWork();
      await _captureLaunchRoute();
    } catch (error, stack) {
      _ready = false;
      initNote = '알림 초기화는 건너뛰었어요. 재료 기록은 그대로 동작해요.';
      debugPrint('notification init skipped: $error\n$stack');
    }
    notifyListeners();
  }

  Future<void> refreshStatus({bool notify = true}) async {
    if (!supported) {
      access = NotificationAccess.unsupported;
      exactAlarmsApplicable = false;
      if (notify) notifyListeners();
      return;
    }
    try {
      await _ensureReady();
      final android = _android;
      if (android != null) {
        exactAlarmsApplicable = true;
        final enabled = await android.areNotificationsEnabled();
        access = enabled == false
            ? NotificationAccess.denied
            : NotificationAccess.granted;
        await _refreshExact(android);
      }
      final ios = _ios;
      if (ios != null) {
        final options = await ios.checkPermissions();
        access = (options?.isEnabled ?? false)
            ? NotificationAccess.granted
            : NotificationAccess.denied;
        exactAlarmsApplicable = false;
        exactAlarmsGranted = false;
      }
    } catch (error, stack) {
      debugPrint('notification status check failed: $error\n$stack');
    }
    if (notify) notifyListeners();
  }

  Future<String> requestPermission() async {
    if (!supported) {
      access = NotificationAccess.unsupported;
      notifyListeners();
      return '이 환경에서는 알림 권한을 요청하지 않아요.';
    }
    try {
      await _ensureReady();
      final android = _android;
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        final enabled = await android.areNotificationsEnabled();
        access = _accessFrom(granted: granted, enabled: enabled);
        exactAlarmsApplicable = true;
        await _refreshExact(android);
      }
      final ios = _ios;
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        access = granted == true
            ? NotificationAccess.granted
            : NotificationAccess.denied;
        exactAlarmsApplicable = false;
      }
    } catch (error, stack) {
      debugPrint('notification permission request failed: $error\n$stack');
      if (access == NotificationAccess.unknown) {
        access = NotificationAccess.denied;
      }
    }
    notifyListeners();
    return switch (access) {
      NotificationAccess.granted => '알림을 허용했어요.',
      NotificationAccess.denied => '알림 권한이 아직 꺼져 있어요.',
      NotificationAccess.unsupported => '이 환경에서는 알림 권한을 요청하지 않아요.',
      NotificationAccess.unknown => '알림 권한을 확인하지 못했어요.',
    };
  }

  Future<String> requestExactAlarms() async {
    if (!supported || !platformCanRequestExactAlarms) {
      return '이 기기에서는 정확한 알람 권한이 필요 없어요.';
    }
    try {
      await _ensureReady();
      final android = _android;
      await android?.requestExactAlarmsPermission();
      if (android != null) await _refreshExact(android);
    } catch (error, stack) {
      exactAlarmsGranted = false;
      debugPrint('exact alarm permission failed: $error\n$stack');
      notifyListeners();
      return '정확한 알람 설정을 열지 못했어요. 대략적인 시각으로 알려요.';
    }
    notifyListeners();
    if (exactAlarmsGranted) return '정확한 시각으로 알림을 맞출게요.';
    return '정확한 알람 권한이 아직 없어요. 대략적인 시각으로 알려요.';
  }

  Future<String> showTestNotification() async {
    if (!supported) return '이 환경에서는 테스트 알림을 보낼 수 없어요.';
    final permission = await requestPermission();
    if (access != NotificationAccess.granted) return permission;
    try {
      await _ensureReady();
      await _plugin.show(
        id: testNotificationId,
        title: '알림 테스트',
        body: '남김없이가 이 기기로 알림을 보낼 수 있어요. 메뉴 보기는 추천으로 이동해요.',
        notificationDetails: _detailsFor(
          groupKey: 'expiry-test',
          includeStatusActions: false,
        ),
        payload: encodeExpiryPayload(const []),
      );
      return '테스트 알림을 보냈어요.';
    } catch (error, stack) {
      debugPrint('test notification failed: $error\n$stack');
      return '테스트 알림을 보내지 못했어요.';
    }
  }

  Future<void> sync({
    required List<IngredientItem> items,
    required NotificationPrefs prefs,
    DateTime? now,
  }) {
    _chain = _chain
        .then((_) => _sync(items: items, prefs: prefs, now: now))
        .catchError((Object error, StackTrace stack) {
          debugPrint('notification sync failed: $error\n$stack');
        });
    return _chain;
  }

  Future<void> _sync({
    required List<IngredientItem> items,
    required NotificationPrefs prefs,
    DateTime? now,
  }) async {
    if (!supported) return;
    await _ensureReady();
    final reminders = planExpiryReminders(
      items: items,
      prefs: prefs,
      now: now ?? DateTime.now(),
    );
    final mode = await _resolveMode();
    try {
      await _plugin.cancelAllPendingNotifications();
    } catch (error, stack) {
      debugPrint('cancel pending notifications failed: $error\n$stack');
    }
    var scheduled = 0;
    for (final reminder in reminders) {
      if (await _schedule(reminder, mode)) scheduled += 1;
    }
    scheduledCount = scheduled;
    initNote = scheduled == 0
        ? '다가오는 기한 알림은 없어요. 재료를 담으면 설정한 시각에 알려요.'
        : '다가오는 알림 $scheduled건을 이 기기에 예약해 두었어요.';
    notifyListeners();
  }

  Future<bool> _schedule(
    ExpiryReminder reminder,
    AndroidScheduleMode mode,
  ) async {
    final when = zonedWallClock(reminder.fireAt);
    final details = _detailsFor(
      groupKey: reminder.groupKey,
      includeStatusActions: true,
    );
    final payload = encodeExpiryPayload([reminder.ingredientId]);

    Future<void> attempt(AndroidScheduleMode scheduleMode) {
      return _plugin.zonedSchedule(
        id: reminder.notificationId,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: scheduleMode,
        payload: payload,
      );
    }

    try {
      await attempt(mode);
      return true;
    } catch (error, stack) {
      debugPrint(
        'schedule failed for ${reminder.ingredientId} ($mode): $error\n$stack',
      );
      if (mode == AndroidScheduleMode.inexactAllowWhileIdle) return false;
      try {
        await attempt(AndroidScheduleMode.inexactAllowWhileIdle);
        exactAlarmsGranted = false;
        return true;
      } catch (fallbackError, fallbackStack) {
        debugPrint('inexact schedule failed: $fallbackError\n$fallbackStack');
        return false;
      }
    }
  }

  Future<AndroidScheduleMode> _resolveMode() async {
    if (!platformCanRequestExactAlarms) {
      exactAlarmsApplicable = false;
      exactAlarmsGranted = false;
      return scheduleModeFor(exactGranted: false);
    }
    exactAlarmsApplicable = true;
    final android = _android;
    if (android != null) await _refreshExact(android);
    return scheduleModeFor(exactGranted: exactAlarmsGranted);
  }

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _ensureZones();
    final initialized =
        await _plugin.initialize(
          settings: _initializationSettings(),
          onDidReceiveNotificationResponse: _onForeground,
          onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
        ) ??
        false;
    if (!initialized) {
      throw StateError('notification plugin declined to initialize');
    }
    _ready = true;
  }

  Future<void> _ensureZones() async {
    if (_zonesReady) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (error, stack) {
      debugPrint('local timezone lookup failed: $error\n$stack');
      final name = fallbackTimeZoneName(DateTime.now().timeZoneOffset);
      try {
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
    _zonesReady = true;
  }

  Future<void> _registerDailyWork() async {
    final dispatcher = _dailyDispatcher;
    if (dispatcher == null) return;
    try {
      await Workmanager().initialize(dispatcher);
      await Workmanager().registerPeriodicTask(
        expiryRefreshUniqueName,
        expiryRefreshTaskName,
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(hours: 1),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (error, stack) {
      debugPrint('daily expiry refresh was not registered: $error\n$stack');
    }
  }

  Future<void> _captureLaunchRoute() async {
    if (!_ready) return;
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp != true) return;
      final response = launch?.notificationResponse;
      final plan = planNotificationAction(
        actionId: response?.actionId,
        payload: response?.payload,
      );
      if (plan.kind == NotificationActionKind.openRecipes) {
        _emitRoute('/recipes');
      }
    } catch (error, stack) {
      debugPrint('launch notification check failed: $error\n$stack');
    }
  }

  void _onForeground(NotificationResponse response) {
    final plan = planNotificationAction(
      actionId: response.actionId,
      payload: response.payload,
    );
    final handler = onAction;
    if (handler != null) {
      unawaited(handler(plan));
      return;
    }
    if (plan.kind == NotificationActionKind.openRecipes) {
      _emitRoute('/recipes');
    }
  }

  void _emitRoute(String route) {
    pendingRoute = route;
    if (!_routes.isClosed) _routes.add(route);
  }

  Future<void> _refreshExact(
    AndroidFlutterLocalNotificationsPlugin android,
  ) async {
    try {
      exactAlarmsGranted =
          await android.canScheduleExactNotifications() ?? false;
    } catch (error, stack) {
      exactAlarmsGranted = false;
      debugPrint('exact alarm check failed: $error\n$stack');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  NotificationAccess _accessFrom({
    required bool? granted,
    required bool? enabled,
  }) {
    if (enabled == false || granted == false) return NotificationAccess.denied;
    return NotificationAccess.granted;
  }

  InitializationSettings _initializationSettings() {
    return InitializationSettings(
      android: const AndroidInitializationSettings('@drawable/ic_stat_namgim'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            expiryCategoryId,
            actions: [
              DarwinNotificationAction.plain(notificationActionEaten, '먹음'),
              DarwinNotificationAction.plain(
                notificationActionDiscarded,
                '버림',
                options: {DarwinNotificationActionOption.destructive},
              ),
              DarwinNotificationAction.plain(
                notificationActionRecipes,
                '메뉴 보기',
                options: {DarwinNotificationActionOption.foreground},
              ),
            ],
          ),
        ],
      ),
    );
  }

  NotificationDetails _detailsFor({
    required String groupKey,
    required bool includeStatusActions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        expiryChannelId,
        expiryChannelName,
        channelDescription: expiryChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        groupKey: groupKey,
        category: AndroidNotificationCategory.reminder,
        actions: [if (includeStatusActions) ..._statusActions, _recipesAction],
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: expiryCategoryId,
        threadIdentifier: groupKey,
      ),
    );
  }

  static const _statusActions = <AndroidNotificationAction>[
    AndroidNotificationAction(
      notificationActionEaten,
      '먹음',
      showsUserInterface: false,
      cancelNotification: true,
    ),
    AndroidNotificationAction(
      notificationActionDiscarded,
      '버림',
      showsUserInterface: false,
      cancelNotification: true,
    ),
  ];

  static const _recipesAction = AndroidNotificationAction(
    notificationActionRecipes,
    '메뉴 보기',
    showsUserInterface: true,
    cancelNotification: false,
  );

  @override
  void dispose() {
    _routes.close();
    super.dispose();
  }
}
