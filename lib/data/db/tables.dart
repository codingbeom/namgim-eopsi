import 'package:drift/drift.dart';

import '../../domain/enums.dart';

@DataClassName('IngredientRow')
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  RealColumn get quantity => real().withDefault(const Constant(1))();
  IntColumn get storageLocation => intEnum<StorageLocation>()();
  DateTimeColumn get expiryDate => dateTime()();
  BoolColumn get isOpened => boolean().withDefault(const Constant(false))();
  DateTimeColumn get openedAt => dateTime().nullable()();
  IntColumn get status =>
      intEnum<IngredientStatus>().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('FavoriteRow')
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get defaultStorageLocation => intEnum<StorageLocation>()();
  IntColumn get defaultShelfDays => integer().nullable()();
}

@DataClassName('ShelfLifeRow')
class ShelfLifeDefaults extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nameKeyword => text()();
  TextColumn get category => text().nullable()();
  IntColumn get storageLocation => intEnum<StorageLocation>()();
  IntColumn get days => integer()();
  IntColumn get openedDays => integer().nullable()();
  BoolColumn get refrigerateAfterOpen =>
      boolean().withDefault(const Constant(false))();
}

@DataClassName('NotificationSettingRow')
class NotificationSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get notifyHour => integer().withDefault(const Constant(8))();
  IntColumn get notifyMinute => integer().withDefault(const Constant(0))();
  IntColumn get fridgeLeadDays => integer().withDefault(const Constant(3))();
  BoolColumn get fridgeOnTheDay =>
      boolean().withDefault(const Constant(true))();
  IntColumn get freezerLeadDays => integer().withDefault(const Constant(3))();
  BoolColumn get freezerOnTheDay =>
      boolean().withDefault(const Constant(true))();
  IntColumn get pantryEarlyDays => integer().withDefault(const Constant(14))();
  IntColumn get pantryLateDays => integer().withDefault(const Constant(7))();
}
