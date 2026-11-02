import '../../domain/models.dart';
import '../db/app_database.dart';
import 'mappers.dart';

abstract class ShelfLifeRepository {
  Stream<List<ShelfLifeRule>> watchAll();
}

class DriftShelfLifeRepository implements ShelfLifeRepository {
  DriftShelfLifeRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ShelfLifeRule>> watchAll() {
    return _db.shelfLifeDao.watchAll().map(
      (rows) => [for (final row in rows) mapShelfLife(row)],
    );
  }
}
