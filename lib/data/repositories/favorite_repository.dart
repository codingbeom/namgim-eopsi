import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../db/app_database.dart';
import 'mappers.dart';

abstract class FavoriteRepository {
  Stream<List<FavoriteItem>> watchAll();
  Future<bool> addIfAbsent({
    required String name,
    required StorageLocation location,
    int? shelfDays,
  });
  Future<void> delete(int id);
}

class DriftFavoriteRepository implements FavoriteRepository {
  DriftFavoriteRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<FavoriteItem>> watchAll() {
    return _db.favoriteDao.watchAll().map(
      (rows) => [for (final row in rows) mapFavorite(row)],
    );
  }

  @override
  Future<bool> addIfAbsent({
    required String name,
    required StorageLocation location,
    int? shelfDays,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final existing = await _db.favoriteDao.findByName(trimmed);
    if (existing != null) return false;
    await _db.favoriteDao.insertFavorite(
      FavoritesCompanion.insert(
        name: trimmed,
        defaultStorageLocation: location,
        defaultShelfDays: Value(shelfDays),
      ),
    );
    return true;
  }

  @override
  Future<void> delete(int id) => _db.favoriteDao.deleteById(id);
}
