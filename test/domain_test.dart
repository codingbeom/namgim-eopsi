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
    expect(ranked.first.band, RecommendBand.rescue);
    expect(ranked.first.urgentCount, greaterThan(0));
    expect(ranked.first.missing, isEmpty);
    expect(ranked.first.reason, '두부 내일까지, 대파 3일 남음. 가진 재료로 바로 만들 수 있어요');
    expect(
      ranked.first.score,
      greaterThan(
        ranked.firstWhere((item) => item.recipe.id == 'onion-stir').score,
      ),
    );
    expect(
      [
        for (final scored in ranked)
          if (scored.hasMatch) scored.recipe.id,
      ],
      [
        'tofu-jorim',
        'egg-fried-rice',
        'egg-drop-soup',
        'gyeran-jjim',
        'onion-stir',
        'mandu-guk',
      ],
    );
    expect(
      ranked.firstWhere((item) => item.recipe.id == 'egg-fried-rice').reason,
      '대파 3일 남음. 없는 재료 1개 (계란)',
    );
    expect(
      ranked.firstWhere((item) => item.recipe.id == 'onion-stir').band,
      RecommendBand.ready,
    );
    expect(
      ranked.firstWhere((item) => item.recipe.id == 'mandu-guk').band,
      RecommendBand.stretch,
    );
    expect(
      ranked.firstWhere((item) => item.recipe.id == 'french-toast').band,
      RecommendBand.none,
    );

    final groups = groupRecipes(ranked);
    expect(groups.rescue.map((item) => item.recipe.id), [
      'tofu-jorim',
      'egg-fried-rice',
      'egg-drop-soup',
      'gyeran-jjim',
    ]);
    expect(groups.ready.map((item) => item.recipe.id), ['onion-stir']);
    expect(groups.stretch.map((item) => item.recipe.id), ['mandu-guk']);
    expect(
      recommendIntro(groups: groups, fridgeEmpty: false),
      '곧 상할 재료를 쓰는 메뉴를 위로 올렸어요.',
    );
  });

  IngredientItem storedItem({
    required int id,
    required String name,
    required int days,
    StorageLocation location = StorageLocation.fridge,
    IngredientStatus status = IngredientStatus.stored,
  }) {
    final now = DateTime(2026, 11, 2);
    return IngredientItem(
      id: id,
      name: name,
      quantity: 1,
      storageLocation: location,
      expiryDate: addDays(now, days),
      isOpened: false,
      openedAt: null,
      status: status,
      createdAt: now,
    );
  }

  Recipe plainRecipe({
    required String id,
    required String name,
    required int minutes,
    required List<String> ingredients,
  }) {
    return Recipe(
      id: id,
      name: name,
      minutes: minutes,
      summary: name,
      steps: name,
      ingredients: ingredients,
    );
  }

  test('a recipe uses the soonest matching ingredient', () {
    final now = DateTime(2026, 11, 2);
    final scored = scoreRecipe(
      recipe: sampleRecipes.firstWhere((recipe) => recipe.id == 'onion-stir'),
      stored: [
        storedItem(
          id: 1,
          name: '양파',
          days: 2,
          location: StorageLocation.pantry,
        ),
        storedItem(
          id: 2,
          name: '양파',
          days: 20,
          location: StorageLocation.pantry,
        ),
        storedItem(
          id: 3,
          name: '굴소스',
          days: 100,
          location: StorageLocation.pantry,
        ),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(scored.used.map((item) => item.id), [1, 3]);
    expect(scored.soonestDays, 2);
  });

  test('one missing urgent meal outranks a fresh meal you can cook', () {
    final now = DateTime(2026, 11, 2);
    final ranked = rankRecipes(
      recipes: [
        plainRecipe(id: 'fresh', name: '양파만', minutes: 10, ingredients: ['양파']),
        plainRecipe(
          id: 'rescue',
          name: '두부조림',
          minutes: 15,
          ingredients: ['두부', '굴소스'],
        ),
      ],
      stored: [
        storedItem(id: 1, name: '두부', days: 1),
        storedItem(
          id: 2,
          name: '양파',
          days: 30,
          location: StorageLocation.pantry,
        ),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(ranked.first.recipe.id, 'rescue');
    expect(ranked.first.band, RecommendBand.rescue);
    expect(ranked.first.reason, contains('두부 내일까지'));
    expect(ranked.first.reason, contains('없는 재료 1개 (굴소스)'));
    expect(ranked[1].band, RecommendBand.ready);
  });

  test('a meal you can cook stays above a weak urgent partial', () {
    final now = DateTime(2026, 11, 2);
    final ranked = rankRecipes(
      recipes: [
        plainRecipe(
          id: 'stretch',
          name: '두부정식',
          minutes: 20,
          ingredients: ['두부', '대파', '계란'],
        ),
        plainRecipe(
          id: 'ready',
          name: '양파볶음',
          minutes: 10,
          ingredients: ['양파', '굴소스'],
        ),
      ],
      stored: [
        storedItem(id: 1, name: '두부', days: 0),
        storedItem(
          id: 2,
          name: '양파',
          days: 40,
          location: StorageLocation.pantry,
        ),
        storedItem(
          id: 3,
          name: '굴소스',
          days: 40,
          location: StorageLocation.pantry,
        ),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(ranked.map((item) => item.recipe.id), ['ready', 'stretch']);
    expect(ranked.first.band, RecommendBand.ready);
    expect(ranked.last.band, RecommendBand.stretch);
    expect(ranked.last.reason, contains('두부 오늘까지'));
    expect(ranked.last.reason, contains('없는 재료 2개'));
  });

  test('overdue food outranks food that expires today', () {
    final now = DateTime(2026, 11, 2);
    final ranked = rankRecipes(
      recipes: [
        plainRecipe(id: 'today', name: '양파', minutes: 10, ingredients: ['양파']),
        plainRecipe(id: 'late', name: '두부', minutes: 10, ingredients: ['두부']),
      ],
      stored: [
        storedItem(id: 1, name: '두부', days: -1),
        storedItem(id: 2, name: '양파', days: 0),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(ranked.first.recipe.id, 'late');
    expect(ranked.first.reason, contains('1일 지남'));
    expect(ranked.first.score, greaterThan(ranked[1].score));
  });

  test('shorter recipes win when the rescue is otherwise the same', () {
    final now = DateTime(2026, 11, 2);
    final ranked = rankRecipes(
      recipes: [
        plainRecipe(
          id: 'slow',
          name: '느린국',
          minutes: 30,
          ingredients: ['대파', '계란'],
        ),
        plainRecipe(
          id: 'fast',
          name: '빠른국',
          minutes: 8,
          ingredients: ['대파', '계란'],
        ),
      ],
      stored: [storedItem(id: 1, name: '대파', days: 1)],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(ranked.map((item) => item.recipe.id), ['fast', 'slow']);
  });

  test('eaten ingredients and an empty fridge suggest nothing', () {
    final now = DateTime(2026, 11, 2);
    final eaten = rankRecipes(
      recipes: sampleRecipes,
      stored: [
        storedItem(id: 1, name: '두부', days: 0, status: IngredientStatus.eaten),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(groupRecipes(eaten).isEmpty, isTrue);

    final empty = groupRecipes(
      rankRecipes(
        recipes: sampleRecipes,
        stored: const [],
        now: now,
        prefs: NotificationPrefs.defaults,
      ),
    );
    expect(empty.isEmpty, isTrue);
    expect(
      recommendIntro(groups: empty, fridgeEmpty: true),
      contains('재료를 담으면'),
    );

    final unmatched = groupRecipes(
      rankRecipes(
        recipes: sampleRecipes,
        stored: [storedItem(id: 1, name: '김치', days: 5)],
        now: now,
        prefs: NotificationPrefs.defaults,
      ),
    );
    expect(unmatched.isEmpty, isTrue);
    expect(
      recommendIntro(groups: unmatched, fridgeEmpty: false),
      contains('겹치는 예시 메뉴가 없어요'),
    );
  });

  test('chip labels name the gap and how soon food expires', () {
    final now = DateTime(2026, 11, 2);
    final scored = scoreRecipe(
      recipe: sampleRecipes.firstWhere((recipe) => recipe.id == 'tofu-jorim'),
      stored: [storedItem(id: 1, name: '두부', days: 0)],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(matchedIngredientLabel(name: '두부', scored: scored), '두부 오늘까지');
    expect(matchedIngredientLabel(name: '대파', scored: scored), '대파 없음');
    expect(expiryPhrase('우유', -2), '우유 2일 지남');
    expect(expiryPhrase('식빵', 1), '식빵 내일까지');
  });
}
