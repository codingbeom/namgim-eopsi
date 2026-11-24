import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../data/db/app_database.dart';
import '../data/repositories/ingredient_repository.dart';
import '../data/repositories/shelf_life_repository.dart';
import '../domain/models.dart';
import '../domain/notification_prefs.dart';
import 'home_widget_actions.dart';
import 'home_widget_publish.dart';
import 'notification_actions.dart';
import 'notification_service.dart';

/// Workmanager entry point. Runs once a day and rebuilds the local schedule.
@pragma('vm:entry-point')
void expiryRefreshDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await refreshScheduledExpiryNotifications();
      return true;
    } catch (error, stack) {
      debugPrint('expiry refresh failed: $error\n$stack');
      return false;
    }
  });
}

/// Background isolate for 먹음 / 버림. The activity is not opened.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  unawaited(handleBackgroundNotificationResponse(response));
}

Future<void> handleBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  final plan = planNotificationAction(
    actionId: response.actionId,
    payload: response.payload,
  );
  if (!plan.updatesStorage) return;
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final kitchen = await _updateThenLoad(plan);
    await _reschedule(kitchen);
  } catch (error, stack) {
    debugPrint('background notification action failed: $error\n$stack');
  }
}

Future<void> refreshScheduledExpiryNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.defaults();
  late final Kitchen kitchen;
  try {
    kitchen = await loadKitchen(database);
  } finally {
    await database.close();
  }
  await _publishWidget(kitchen);
  await syncExpiryNotifications(items: kitchen.items, prefs: kitchen.prefs);
}

Future<void> syncExpiryNotifications({
  required List<IngredientItem> items,
  required NotificationPrefs prefs,
}) async {
  final service = NotificationService();
  try {
    await service.initialize(
      registerDailyWork: false,
      onBackgroundResponse: notificationTapBackground,
    );
    await service.sync(items: items, prefs: prefs);
  } finally {
    service.dispose();
  }
}

Future<Kitchen> _updateThenLoad(NotificationActionPlan plan) async {
  final database = AppDatabase.defaults();
  try {
    final repository = DriftIngredientRepository(
      database,
      DriftShelfLifeRepository(database),
    );
    await applyNotificationAction(repository: repository, plan: plan);
    return await loadKitchen(database);
  } finally {
    await database.close();
  }
}

Future<void> _reschedule(Kitchen kitchen) async {
  await _publishWidget(kitchen);
  await syncExpiryNotifications(items: kitchen.items, prefs: kitchen.prefs);
}

Future<void> _publishWidget(Kitchen kitchen) {
  return publishHomeWidget(
    items: kitchen.items,
    favorites: kitchen.favorites,
    prefs: kitchen.prefs,
  );
}
