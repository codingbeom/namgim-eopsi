import '../../domain/models.dart';
import '../../domain/notification_prefs.dart';
import '../db/app_database.dart';

IngredientItem mapIngredient(IngredientRow row) {
  return IngredientItem(
    id: row.id,
    name: row.name,
    quantity: row.quantity,
    storageLocation: row.storageLocation,
    expiryDate: row.expiryDate,
    isOpened: row.isOpened,
    openedAt: row.openedAt,
    status: row.status,
    createdAt: row.createdAt,
  );
}

FavoriteItem mapFavorite(FavoriteRow row) {
  return FavoriteItem(
    id: row.id,
    name: row.name,
    defaultStorageLocation: row.defaultStorageLocation,
    defaultShelfDays: row.defaultShelfDays,
  );
}

ShelfLifeRule mapShelfLife(ShelfLifeRow row) {
  return ShelfLifeRule(
    id: row.id,
    nameKeyword: row.nameKeyword,
    category: row.category,
    storageLocation: row.storageLocation,
    days: row.days,
    openedDays: row.openedDays,
    refrigerateAfterOpen: row.refrigerateAfterOpen,
  );
}

NotificationPrefs mapPrefs(NotificationSettingRow row) {
  return NotificationPrefs(
    hour: row.notifyHour,
    minute: row.notifyMinute,
    fridgeLeadDays: row.fridgeLeadDays,
    fridgeOnTheDay: row.fridgeOnTheDay,
    freezerLeadDays: row.freezerLeadDays,
    freezerOnTheDay: row.freezerOnTheDay,
    pantryEarlyDays: row.pantryEarlyDays,
    pantryLateDays: row.pantryLateDays,
  );
}
