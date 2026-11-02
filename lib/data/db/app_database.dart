import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../daos/favorite_dao.dart';
import '../daos/ingredient_dao.dart';
import '../daos/settings_dao.dart';
import '../daos/shelf_life_dao.dart';
import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';
part 'seed.dart';

@DriftDatabase(
  tables: [Ingredients, Favorites, ShelfLifeDefaults, NotificationSettings],
  daos: [IngredientDao, FavoriteDao, ShelfLifeDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'namgim_eopsi',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await seedNamgim(this);
    },
  );
}
