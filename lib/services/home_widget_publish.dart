import '../domain/home_widget_snapshot.dart';
import '../domain/models.dart';
import '../domain/notification_prefs.dart';
import 'home_widget_bridge.dart';

Future<void> publishHomeWidget({
  required List<IngredientItem> items,
  required List<FavoriteItem> favorites,
  required NotificationPrefs prefs,
  DateTime? now,
}) {
  final snapshot = buildHomeWidgetSnapshot(
    items: items,
    favorites: favorites,
    prefs: prefs,
    now: now ?? DateTime.now(),
  );
  return writeHomeWidgetPayload(snapshot.toPayload());
}
