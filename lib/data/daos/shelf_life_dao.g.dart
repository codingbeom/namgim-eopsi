// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_life_dao.dart';

// ignore_for_file: type=lint
mixin _$ShelfLifeDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShelfLifeDefaultsTable get shelfLifeDefaults =>
      attachedDatabase.shelfLifeDefaults;
  ShelfLifeDaoManager get managers => ShelfLifeDaoManager(this);
}

class ShelfLifeDaoManager {
  final _$ShelfLifeDaoMixin _db;
  ShelfLifeDaoManager(this._db);
  $$ShelfLifeDefaultsTableTableManager get shelfLifeDefaults =>
      $$ShelfLifeDefaultsTableTableManager(
        _db.attachedDatabase,
        _db.shelfLifeDefaults,
      );
}
