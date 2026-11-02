import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'shelf_life_dao.g.dart';

@DriftAccessor(tables: [ShelfLifeDefaults])
class ShelfLifeDao extends DatabaseAccessor<AppDatabase>
    with _$ShelfLifeDaoMixin {
  ShelfLifeDao(super.db);

  Stream<List<ShelfLifeRow>> watchAll() {
    return (select(
      shelfLifeDefaults,
    )..orderBy([(row) => OrderingTerm.asc(row.nameKeyword)])).watch();
  }
}
