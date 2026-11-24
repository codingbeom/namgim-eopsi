import '../data/db/app_database.dart';
import '../data/repositories/ingredient_repository.dart';
import '../data/repositories/mappers.dart';
import '../data/repositories/shelf_life_repository.dart';
import '../domain/models.dart';
import '../domain/notification_prefs.dart';

const homeWidgetScheme = 'namgim';

class Kitchen {
  const Kitchen({
    required this.items,
    required this.favorites,
    required this.prefs,
  });

  final List<IngredientItem> items;
  final List<FavoriteItem> favorites;
  final NotificationPrefs prefs;
}

class WidgetFavoriteAddResult {
  const WidgetFavoriteAddResult({required this.added, this.ingredientId});

  final bool added;
  final int? ingredientId;

  static const skipped = WidgetFavoriteAddResult(added: false);
}

/// Header opens the app. The add control opens `/add`.
String? widgetLaunchLocation(Uri uri) {
  if (uri.scheme != homeWidgetScheme) return null;
  return switch (uri.host) {
    'add' => '/add',
    'home' => '/home',
    _ => null,
  };
}

int? favoriteIdFromWidgetUri(Uri? uri) {
  if (uri == null || uri.scheme != homeWidgetScheme) return null;
  if (uri.host != 'favorite') return null;
  return int.tryParse(uri.queryParameters['id'] ?? '');
}

Future<Kitchen> loadKitchen(AppDatabase database) async {
  final items = [
    for (final row in await database.ingredientDao.watchAll().first)
      mapIngredient(row),
  ];
  final favorites = [
    for (final row in await database.favoriteDao.watchAll().first)
      mapFavorite(row),
  ];
  final prefs = mapPrefs(await database.settingsDao.getOne());
  return Kitchen(items: items, favorites: favorites, prefs: prefs);
}

/// Writes one favorite using its saved place and shelf life.
///
/// An unknown id does not insert a row. Implicit staples are unrelated: this
/// only runs when the widget sends a real favorite id.
Future<WidgetFavoriteAddResult> addFavoriteFromWidget({
  required AppDatabase database,
  required int favoriteId,
}) async {
  final rows = await database.favoriteDao.watchAll().first;
  FavoriteRow? match;
  for (final row in rows) {
    if (row.id == favoriteId) {
      match = row;
      break;
    }
  }
  if (match == null) return WidgetFavoriteAddResult.skipped;
  final repository = DriftIngredientRepository(
    database,
    DriftShelfLifeRepository(database),
  );
  final id = await repository.addFromFavorite(mapFavorite(match));
  return WidgetFavoriteAddResult(added: true, ingredientId: id);
}
