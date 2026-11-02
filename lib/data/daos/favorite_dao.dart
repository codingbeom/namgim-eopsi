import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'favorite_dao.g.dart';

@DriftAccessor(tables: [Favorites])
class FavoriteDao extends DatabaseAccessor<AppDatabase>
    with _$FavoriteDaoMixin {
  FavoriteDao(super.db);

  Stream<List<FavoriteRow>> watchAll() {
    return (select(
      favorites,
    )..orderBy([(row) => OrderingTerm.asc(row.id)])).watch();
  }

  Future<FavoriteRow?> findByName(String name) {
    return (select(
      favorites,
    )..where((row) => row.name.equals(name))).getSingleOrNull();
  }

  Future<int> insertFavorite(FavoritesCompanion companion) {
    return into(favorites).insert(companion);
  }

  Future<void> deleteById(int id) {
    return (delete(favorites)..where((row) => row.id.equals(id))).go();
  }
}
