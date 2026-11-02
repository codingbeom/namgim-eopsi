import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/repositories/favorite_repository.dart';
import '../data/repositories/ingredient_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/shelf_life_repository.dart';
import '../domain/enums.dart';
import '../domain/models.dart';
import '../domain/notification_prefs.dart';
import '../domain/recipes.dart';
import '../services/notification_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();
  ref.onDispose(database.close);
  return database;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final shelfLifeRepositoryProvider = Provider<ShelfLifeRepository>((ref) {
  return DriftShelfLifeRepository(ref.watch(databaseProvider));
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return DriftFavoriteRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(ref.watch(databaseProvider));
});

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return DriftIngredientRepository(
    ref.watch(databaseProvider),
    ref.watch(shelfLifeRepositoryProvider),
  );
});

final ingredientsProvider = StreamProvider<List<IngredientItem>>((ref) {
  return ref.watch(ingredientRepositoryProvider).watchAll();
});

final favoritesProvider = StreamProvider<List<FavoriteItem>>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchAll();
});

final shelfLifeProvider = StreamProvider<List<ShelfLifeRule>>((ref) {
  return ref.watch(shelfLifeRepositoryProvider).watchAll();
});

final settingsProvider = StreamProvider<NotificationPrefs>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final rankedRecipesProvider = Provider<List<ScoredRecipe>>((ref) {
  final stored =
      ref.watch(ingredientsProvider).value ?? const <IngredientItem>[];
  final prefs = ref.watch(settingsProvider).value ?? NotificationPrefs.defaults;
  final active = stored
      .where((item) => item.status == IngredientStatus.stored)
      .toList();
  return rankRecipes(
    recipes: sampleRecipes,
    stored: active,
    now: DateTime.now(),
    prefs: prefs,
  );
});
