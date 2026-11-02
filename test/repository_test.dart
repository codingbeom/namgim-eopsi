import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/data/db/app_database.dart';
import 'package:namgim_eopsi/data/repositories/favorite_repository.dart';
import 'package:namgim_eopsi/data/repositories/ingredient_repository.dart';
import 'package:namgim_eopsi/data/repositories/settings_repository.dart';
import 'package:namgim_eopsi/data/repositories/shelf_life_repository.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';

void main() {
  late AppDatabase database;
  late DriftIngredientRepository ingredients;
  late DriftFavoriteRepository favorites;
  late DriftSettingsRepository settings;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    final shelfLife = DriftShelfLifeRepository(database);
    ingredients = DriftIngredientRepository(database, shelfLife);
    favorites = DriftFavoriteRepository(database);
    settings = DriftSettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('seed, favorite re-add, eat, open, and settings', () async {
    final favoriteItems = await favorites.watchAll().first;
    expect(
      favoriteItems.map((item) => item.name),
      containsAll(['계란', '우유', '두부', '대파']),
    );

    final rules = await DriftShelfLifeRepository(database).watchAll().first;
    final milk = rules.firstWhere((rule) => rule.nameKeyword == '우유');
    expect(milk.days, 7);
    expect(milk.storageLocation, StorageLocation.fridge);

    final stored = await ingredients.watchAll().first;
    expect(
      stored
          .where((item) => item.status == IngredientStatus.stored)
          .map((item) => item.name),
      contains('두부'),
    );

    final egg = favoriteItems.firstWhere((item) => item.name == '계란');
    final addedId = await ingredients.addFromFavorite(egg);
    final afterAdd = await ingredients.watchAll().first;
    final added = afterAdd.firstWhere((item) => item.id == addedId);
    expect(added.storageLocation, StorageLocation.fridge);
    expect(daysUntil(added.expiryDate, DateTime.now()), 21);

    final tofu = stored.firstWhere((item) => item.name == '두부');
    await ingredients.setStatus(tofu.id, IngredientStatus.eaten);
    final afterEat = await ingredients.watchAll().first;
    expect(
      afterEat.firstWhere((item) => item.id == tofu.id).status,
      IngredientStatus.eaten,
    );

    final sauce = afterEat.firstWhere((item) => item.name == '굴소스');
    final plan = await ingredients.previewOpen(sauce);
    expect(plan.suggestFridge, isTrue);
    expect(plan.shortened, isTrue);
    await ingredients.markOpened(
      id: sauce.id,
      expiryDate: plan.expiryDate,
      moveToFridge: true,
    );
    final opened = (await ingredients.watchAll().first).firstWhere(
      (item) => item.id == sauce.id,
    );
    expect(opened.isOpened, isTrue);
    expect(opened.storageLocation, StorageLocation.fridge);
    expect(dateOnly(opened.expiryDate), dateOnly(plan.expiryDate));

    final prefs = await settings.watch().first;
    expect(prefs.fridgeLeadDays, 3);
    expect(prefs.pantryEarlyDays, 14);
    expect(prefs.pantryLateDays, 7);
    await settings.save(prefs.copyWith(fridgeLeadDays: 5, hour: 9));
    final saved = await settings.watch().first;
    expect(saved.fridgeLeadDays, 5);
    expect(saved.hour, 9);
  });
}
