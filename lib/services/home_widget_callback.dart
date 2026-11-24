import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/db/app_database.dart';
import 'expiry_refresh.dart';
import 'home_widget_actions.dart';
import 'home_widget_bridge.dart';
import 'home_widget_publish.dart';

/// Widget favorite tap. Runs without opening the activity.
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    final database = AppDatabase.defaults();
    try {
      await handleHomeWidgetFavoriteUri(
        database: database,
        uri: uri,
        onAdded: (kitchen) {
          return syncExpiryNotifications(
            items: kitchen.items,
            prefs: kitchen.prefs,
          );
        },
      );
    } finally {
      await database.close();
    }
  } catch (error, stack) {
    debugPrint('home widget favorite add failed: $error\n$stack');
  }
}

Future<void> registerHomeWidgetCallback() {
  return registerHomeWidgetInteractivity(homeWidgetBackgroundCallback);
}

/// Adds the favorite, refreshes the widget, then tells the caller so
/// notifications can be rescheduled from the new rows.
Future<WidgetFavoriteAddResult> handleHomeWidgetFavoriteUri({
  required AppDatabase database,
  required Uri? uri,
  DateTime? now,
  Future<void> Function(Kitchen kitchen)? onAdded,
}) async {
  final favoriteId = favoriteIdFromWidgetUri(uri);
  if (favoriteId == null) return WidgetFavoriteAddResult.skipped;
  final added = await addFavoriteFromWidget(
    database: database,
    favoriteId: favoriteId,
  );
  if (!added.added) return added;
  final kitchen = await loadKitchen(database);
  await publishHomeWidget(
    items: kitchen.items,
    favorites: kitchen.favorites,
    prefs: kitchen.prefs,
    now: now,
  );
  if (onAdded != null) await onAdded(kitchen);
  return added;
}
