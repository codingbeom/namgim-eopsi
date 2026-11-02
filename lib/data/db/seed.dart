part of 'app_database.dart';

Future<void> seedNamgim(AppDatabase db) async {
  final today = dateOnly(DateTime.now());
  await db.batch((batch) {
    batch.insertAll(db.shelfLifeDefaults, [
      for (final seed in shelfLifeSeeds)
        ShelfLifeDefaultsCompanion.insert(
          nameKeyword: seed.keyword,
          category: Value(seed.category),
          storageLocation: seed.location,
          days: seed.days,
          openedDays: Value(seed.openedDays),
          refrigerateAfterOpen: Value(seed.refrigerateAfterOpen),
        ),
    ]);
    batch.insertAll(db.favorites, [
      for (final seed in favoriteSeeds)
        FavoritesCompanion.insert(
          name: seed.name,
          defaultStorageLocation: seed.location,
          defaultShelfDays: Value(seed.shelfDays),
        ),
    ]);
    batch.insertAll(db.ingredients, [
      for (final seed in sampleIngredients)
        IngredientsCompanion.insert(
          name: seed.name,
          storageLocation: seed.location,
          expiryDate: today.add(Duration(days: seed.daysFromToday)),
          quantity: const Value(1),
        ),
    ]);
    batch.insert(
      db.notificationSettings,
      NotificationSettingsCompanion.insert(),
    );
  });
}
