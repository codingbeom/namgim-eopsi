import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../data/db/app_database.dart';
import '../data/repositories/ingredient_repository.dart';
import '../data/repositories/mappers.dart';
import '../data/repositories/shelf_life_repository.dart';
import '../domain/models.dart';
import '../domain/notification_prefs.dart';
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
  late final List<IngredientItem> items;
  late final NotificationPrefs prefs;
  try {
    items = await _readItems(database);
    prefs = mapPrefs(await database.settingsDao.getOne());
  } finally {
    await database.close();
  }
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

Future<({List<IngredientItem> items, NotificationPrefs prefs})> _updateThenLoad(
  NotificationActionPlan plan,
) async {
  final database = AppDatabase.defaults();
  try {
    final repository = DriftIngredientRepository(
      database,
      DriftShelfLifeRepository(database),
    );
    await applyNotificationAction(repository: repository, plan: plan);
    final items = await _readItems(database);
    final prefs = mapPrefs(await database.settingsDao.getOne());
    return (items: items, prefs: prefs);
  } finally {
    await database.close();
  }
}

Future<void> _reschedule(
  ({List<IngredientItem> items, NotificationPrefs prefs}) kitchen,
) async {
  final service = NotificationService();
  try {
    await service.initialize(
      registerDailyWork: false,
      onBackgroundResponse: notificationTapBackground,
    );
    await service.sync(items: kitchen.items, prefs: kitchen.prefs);
  } finally {
    service.dispose();
  }
}

Future<List<IngredientItem>> _readItems(AppDatabase database) async {
  final rows = await database.ingredientDao.watchAll().first;
  return [for (final row in rows) mapIngredient(row)];
}
