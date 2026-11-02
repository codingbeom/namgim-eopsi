import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/domain/open_plan.dart';
import 'package:namgim_eopsi/domain/recipes.dart';
import 'package:namgim_eopsi/domain/shelf_life.dart';

void main() {
  final rules = [
    const ShelfLifeRule(
      id: 1,
      nameKeyword: '우유',
      storageLocation: StorageLocation.fridge,
      days: 7,
      openedDays: 3,
    ),
    const ShelfLifeRule(
      id: 2,
      nameKeyword: '닭가슴살',
      storageLocation: StorageLocation.fridge,
      days: 2,
      openedDays: 1,
    ),
    const ShelfLifeRule(
      id: 3,
      nameKeyword: '닭가슴살',
      storageLocation: StorageLocation.freezer,
      days: 90,
    ),
    const ShelfLifeRule(
      id: 4,
      nameKeyword: '굴소스',
      storageLocation: StorageLocation.pantry,
      days: 365,
      openedDays: 90,
      refrigerateAfterOpen: true,
    ),
    const ShelfLifeRule(
      id: 5,
      nameKeyword: '냉동만두',
      storageLocation: StorageLocation.freezer,
      days: 90,
    ),
    const ShelfLifeRule(
      id: 6,
      nameKeyword: '만두',
      storageLocation: StorageLocation.freezer,
      days: 90,
    ),
  ];

  test('shelf life prefers the selected storage and the longer keyword', () {
    final milk = suggestExpiry(
      rules: rules,
      name: '우유',
      location: StorageLocation.fridge,
      lockLocation: true,
    );
    expect(milk.days, 7);
    expect(milk.fromFallback, isFalse);

    final frozenMilk = suggestExpiry(
      rules: rules,
      name: '우유',
      location: StorageLocation.freezer,
      lockLocation: true,
    );
    expect(frozenMilk.fromFallback, isTrue);
    expect(frozenMilk.days, 30);

    final chicken = suggestExpiry(
      rules: rules,
      name: '닭가슴살',
      location: StorageLocation.freezer,
      lockLocation: false,
    );
    expect(chicken.location, StorageLocation.freezer);
    expect(chicken.days, 90);

    final dumplings = suggestExpiry(
      rules: rules,
      name: '냉동만두',
      location: StorageLocation.freezer,
      lockLocation: true,
    );
    expect(dumplings.matchedKeyword, '냉동만두');
  });

  test('opening shortens a long pantry date and suggests the fridge', () {
    final today = DateTime(2026, 11, 2);
    final plan = planOpen(
      now: today,
      currentExpiry: addDays(today, 200),
      location: StorageLocation.pantry,
      openedDays: 90,
      refrigerateAfterOpen: true,
    );
    expect(plan.suggestFridge, isTrue);
    expect(plan.shortened, isTrue);
    expect(plan.expiryDate, addDays(today, 90));

    final milk = planOpen(
      now: today,
      currentExpiry: addDays(today, 1),
      location: StorageLocation.fridge,
      openedDays: 3,
      refrigerateAfterOpen: false,
    );
    expect(milk.shortened, isFalse);
    expect(milk.expiryDate, addDays(today, 1));
    expect(milk.suggestFridge, isFalse);
  });

  test('recipes put soon-to-expire matches first', () {
    final now = DateTime(2026, 11, 2);
    final stored = [
      IngredientItem(
        id: 1,
        name: '두부',
        quantity: 1,
        storageLocation: StorageLocation.fridge,
        expiryDate: addDays(now, 1),
        isOpened: false,
        openedAt: null,
        status: IngredientStatus.stored,
        createdAt: now,
      ),
      IngredientItem(
        id: 2,
        name: '대파',
        quantity: 1,
        storageLocation: StorageLocation.fridge,
        expiryDate: addDays(now, 3),
        isOpened: false,
        openedAt: null,
        status: IngredientStatus.stored,
        createdAt: now,
      ),
      IngredientItem(
        id: 3,
        name: '굴소스',
        quantity: 1,
        storageLocation: StorageLocation.pantry,
        expiryDate: addDays(now, 120),
        isOpened: false,
        openedAt: null,
        status: IngredientStatus.stored,
        createdAt: now,
      ),
      IngredientItem(
        id: 4,
        name: '양파',
        quantity: 1,
        storageLocation: StorageLocation.pantry,
        expiryDate: addDays(now, 25),
        isOpened: false,
        openedAt: null,
        status: IngredientStatus.stored,
        createdAt: now,
      ),
    ];

    final ranked = rankRecipes(
      recipes: sampleRecipes,
      stored: stored,
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(ranked.first.recipe.id, 'tofu-jorim');
    expect(ranked.first.urgentCount, greaterThan(0));
    expect(
      ranked.first.score,
      greaterThan(
        ranked.firstWhere((item) => item.recipe.id == 'onion-stir').score,
      ),
    );
  });
}
