import 'package:drift/drift.dart';

import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/open_plan.dart';
import '../../domain/shelf_life.dart';
import '../db/app_database.dart';
import 'mappers.dart';
import 'shelf_life_repository.dart';

abstract class IngredientRepository {
  Stream<List<IngredientItem>> watchAll();

  Future<int> add({
    required String name,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  });

  Future<int> addFromFavorite(FavoriteItem favorite);

  Future<void> setStatus(int id, IngredientStatus status);

  Future<void> delete(int id);

  Future<void> updateDetails({
    required int id,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  });

  Future<OpenPlan> previewOpen(IngredientItem item, {DateTime? now});

  Future<void> markOpened({
    required int id,
    required DateTime expiryDate,
    required bool moveToFridge,
    DateTime? openedAt,
  });
}

class DriftIngredientRepository implements IngredientRepository {
  DriftIngredientRepository(this._db, this._shelfLife);

  final AppDatabase _db;
  final ShelfLifeRepository _shelfLife;

  @override
  Stream<List<IngredientItem>> watchAll() {
    return _db.ingredientDao.watchAll().map(
      (rows) => [for (final row in rows) mapIngredient(row)],
    );
  }

  @override
  Future<int> add({
    required String name,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  }) {
    return _db.ingredientDao.insertIngredient(
      IngredientsCompanion.insert(
        name: name.trim(),
        quantity: Value(quantity),
        storageLocation: location,
        expiryDate: dateOnly(expiryDate),
      ),
    );
  }

  @override
  Future<int> addFromFavorite(FavoriteItem favorite) async {
    final rules = await _shelfLife.watchAll().first;
    final suggestion = suggestExpiry(
      rules: rules,
      name: favorite.name,
      location: favorite.defaultStorageLocation,
      lockLocation: true,
    );
    final days = favorite.defaultShelfDays ?? suggestion.days;
    return add(
      name: favorite.name,
      quantity: 1,
      location: favorite.defaultStorageLocation,
      expiryDate: addDays(DateTime.now(), days),
    );
  }

  @override
  Future<void> setStatus(int id, IngredientStatus status) {
    return _db.ingredientDao.updateStatus(id, status);
  }

  @override
  Future<void> delete(int id) => _db.ingredientDao.deleteById(id);

  @override
  Future<void> updateDetails({
    required int id,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  }) {
    return _db.ingredientDao.updateDetails(
      id: id,
      quantity: quantity,
      location: location,
      expiryDate: dateOnly(expiryDate),
    );
  }

  @override
  Future<OpenPlan> previewOpen(IngredientItem item, {DateTime? now}) async {
    final rules = await _shelfLife.watchAll().first;
    final matched = bestRule(
      rules,
      item.name,
      prefer: item.storageLocation,
      requireLocation: true,
    );
    final fallback = bestRule(rules, item.name, prefer: item.storageLocation);
    final rule = matched ?? fallback;
    return planOpen(
      now: now ?? DateTime.now(),
      currentExpiry: item.expiryDate,
      location: item.storageLocation,
      openedDays: rule?.openedDays,
      refrigerateAfterOpen: rule?.refrigerateAfterOpen ?? false,
    );
  }

  @override
  Future<void> markOpened({
    required int id,
    required DateTime expiryDate,
    required bool moveToFridge,
    DateTime? openedAt,
  }) {
    return _db.ingredientDao.markOpened(
      id: id,
      expiryDate: dateOnly(expiryDate),
      openedAt: openedAt ?? DateTime.now(),
      moveTo: moveToFridge ? StorageLocation.fridge : null,
    );
  }
}
