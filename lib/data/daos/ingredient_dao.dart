import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../db/app_database.dart';
import '../db/tables.dart';

part 'ingredient_dao.g.dart';

@DriftAccessor(tables: [Ingredients])
class IngredientDao extends DatabaseAccessor<AppDatabase>
    with _$IngredientDaoMixin {
  IngredientDao(super.db);

  Stream<List<IngredientRow>> watchAll() {
    return (select(ingredients)..orderBy([
          (row) => OrderingTerm.asc(row.expiryDate),
          (row) => OrderingTerm.asc(row.name),
        ]))
        .watch();
  }

  Future<int> insertIngredient(IngredientsCompanion companion) {
    return into(ingredients).insert(companion);
  }

  Future<void> updateStatus(int id, IngredientStatus status) {
    return (update(ingredients)..where((row) => row.id.equals(id))).write(
      IngredientsCompanion(status: Value(status)),
    );
  }

  Future<void> deleteById(int id) {
    return (delete(ingredients)..where((row) => row.id.equals(id))).go();
  }

  Future<void> updateDetails({
    required int id,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  }) {
    return (update(ingredients)..where((row) => row.id.equals(id))).write(
      IngredientsCompanion(
        quantity: Value(quantity),
        storageLocation: Value(location),
        expiryDate: Value(expiryDate),
      ),
    );
  }

  Future<void> markOpened({
    required int id,
    required DateTime expiryDate,
    required DateTime openedAt,
    StorageLocation? moveTo,
  }) {
    return (update(ingredients)..where((row) => row.id.equals(id))).write(
      IngredientsCompanion(
        isOpened: const Value(true),
        openedAt: Value(openedAt),
        expiryDate: Value(expiryDate),
        storageLocation: moveTo == null ? const Value.absent() : Value(moveTo),
      ),
    );
  }
}
