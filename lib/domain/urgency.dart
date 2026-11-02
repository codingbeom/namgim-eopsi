import 'dates.dart';
import 'enums.dart';
import 'models.dart';
import 'notification_prefs.dart';

enum Urgency { overdue, today, soon, later }

int attentionWindow(NotificationPrefs prefs, StorageLocation location) {
  return switch (location) {
    StorageLocation.fridge => prefs.fridgeLeadDays,
    StorageLocation.freezer => prefs.freezerLeadDays,
    StorageLocation.pantry => prefs.pantryLateDays,
  };
}

Urgency urgencyFor({
  required DateTime expiry,
  required StorageLocation location,
  required DateTime now,
  required NotificationPrefs prefs,
}) {
  final days = daysUntil(expiry, now);
  if (days < 0) return Urgency.overdue;
  if (days == 0) return Urgency.today;
  if (days <= attentionWindow(prefs, location)) return Urgency.soon;
  return Urgency.later;
}

bool needsAttention({
  required DateTime expiry,
  required StorageLocation location,
  required DateTime now,
  required NotificationPrefs prefs,
}) {
  return daysUntil(expiry, now) <= attentionWindow(prefs, location);
}

class StorageSummary {
  const StorageSummary({required this.stored, required this.attention});

  final int stored;
  final int attention;
}

Map<StorageLocation, StorageSummary> summarizeStorage(
  List<IngredientItem> items,
  DateTime now,
  NotificationPrefs prefs,
) {
  final stored = items
      .where((item) => item.status == IngredientStatus.stored)
      .toList();
  return {
    for (final location in StorageLocation.values)
      location: StorageSummary(
        stored: stored.where((item) => item.storageLocation == location).length,
        attention: stored
            .where(
              (item) =>
                  item.storageLocation == location &&
                  needsAttention(
                    expiry: item.expiryDate,
                    location: location,
                    now: now,
                    prefs: prefs,
                  ),
            )
            .length,
      ),
  };
}
