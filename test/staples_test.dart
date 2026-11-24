import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/household_staples.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/domain/recipes.dart';

void main() {
  final now = DateTime(2026, 11, 2);

  IngredientItem storedItem({
    required int id,
    required String name,
    required int days,
    StorageLocation location = StorageLocation.fridge,
  }) {
    return IngredientItem(
      id: id,
      name: name,
      quantity: 1,
      storageLocation: location,
      expiryDate: addDays(now, days),
      isOpened: false,
      openedAt: null,
      status: IngredientStatus.stored,
      createdAt: now,
    );
  }

  Recipe recipe(List<String> ingredients) {
    return Recipe(
      id: 'custom',
      name: '테스트',
      category: RecipeCategory.quick,
      minutes: 10,
      summary: '테스트',
      steps: '테스트',
      ingredients: ingredients,
    );
  }

  test('rice and kimchi aliases are staples, seaweed and dishes are not', () {
    expect(isHouseholdStaple('밥'), isTrue);
    expect(isHouseholdStaple(' 김치 '), isTrue);
    expect(isHouseholdStaple('찬밥'), isTrue);
    expect(isHouseholdStaple('냉동밥'), isTrue);
    expect(isHouseholdStaple('배추김치'), isTrue);
    expect(isHouseholdStaple('김'), isFalse);
    expect(isHouseholdStaple('김밥'), isFalse);
    expect(isHouseholdStaple('계란'), isFalse);
    expect(coversIngredient('찬밥', '밥'), isTrue);
    expect(coversIngredient('배추김치', '김치'), isTrue);
    expect(coversIngredient('김치', '밥'), isFalse);
  });

  test('egg plus implicit staples counts as nothing missing', () {
    final scored = scoreRecipe(
      recipe: recipe(['계란', '밥', '김치']),
      stored: [storedItem(id: 1, name: '계란', days: 6)],
      now: now,
      prefs: NotificationPrefs.defaults,
    );

    expect(scored.missing, isEmpty);
    expect(scored.assumed, ['밥', '김치']);
    expect(scored.used.map((item) => item.id), [1]);
    expect(scored.hasMatch, isTrue);
    expect(scored.band, RecommendBand.ready);
    expect(recipeGapLabel(scored), '재료가 다 있어요 · 기본 재료 밥, 김치');
    expect(matchedIngredientLabel(name: '밥', scored: scored), '밥 · 기본');
    expect(matchedIngredientLabel(name: '김치', scored: scored), '김치 · 기본');
    expect(cookCleanupBody(scored), contains('쓴 재료: 계란'));
    expect(cookCleanupBody(scored), contains('기본 재료(밥, 김치)는 그대로 둬요.'));
    expect(cookCleanupBody(scored), isNot(contains('id')));
  });

  test('an empty fridge does not recommend staple-only overlap', () {
    final ranked = rankRecipes(
      recipes: sampleRecipes,
      stored: const [],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    expect(matchedRecipes(ranked), isEmpty);
    expect(groupRecipes(ranked).isEmpty, isTrue);
    expect(
      ranked.where((item) => item.recipe.ingredients.any(isHouseholdStaple)),
      isNotEmpty,
    );
    expect(
      recommendIntro(groups: groupRecipes(ranked), fridgeEmpty: true),
      contains('재료를 담으면'),
    );
  });

  test('implicit staples do not surface meals with no stored match', () {
    final ranked = rankRecipes(
      recipes: sampleRecipes,
      stored: [storedItem(id: 1, name: '계란', days: 5)],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    final matched = matchedRecipes(ranked);
    expect(matched, isNotEmpty);
    for (final scored in matched) {
      expect(scored.used.map((item) => item.name), contains('계란'));
      expect(scored.missing, isNot(contains('밥')));
      expect(scored.missing, isNot(contains('김치')));
    }
    expect(matched.map((item) => item.recipe.id), isNot(contains('jumeokbap')));
    expect(
      matched.map((item) => item.recipe.id),
      isNot(contains('kimchi-jeon')),
    );

    final fried = matched.firstWhere(
      (item) => item.recipe.id == 'kimchi-fried-rice',
    );
    expect(fried.missing, ['대파']);
    expect(fried.assumed, ['김치', '밥']);
    expect(fried.used.map((item) => item.id), [1]);
  });

  test('stored rice is a real row and implicit kimchi is not', () {
    final scored = scoreRecipe(
      recipe: recipe(['계란', '밥', '김치']),
      stored: [
        storedItem(id: 1, name: '계란', days: 10),
        storedItem(id: 2, name: '밥', days: 30),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );

    expect(scored.missing, isEmpty);
    expect(scored.used.map((item) => item.id), [1, 2]);
    expect(scored.assumed, ['김치']);
    expect(cookCleanupBody(scored), contains('쓴 재료: 계란, 밥'));
    expect(cookCleanupBody(scored), contains('기본 재료(김치)는 그대로 둬요.'));
  });

  test('stored cold rice covers a rice ingredient and can be cleared', () {
    final scored = scoreRecipe(
      recipe: recipe(['밥', '계란']),
      stored: [
        storedItem(id: 9, name: '찬밥', days: 1),
        storedItem(id: 3, name: '계란', days: 4),
      ],
      now: now,
      prefs: NotificationPrefs.defaults,
    );

    expect(scored.missing, isEmpty);
    expect(scored.assumed, isEmpty);
    expect(scored.used.map((item) => item.id), [9, 3]);
    expect(scored.urgentIds, contains(9));
  });

  test('explicit rice recommends meals that use it and skips the rest', () {
    final ranked = rankRecipes(
      recipes: sampleRecipes,
      stored: [storedItem(id: 4, name: '밥', days: 12)],
      now: now,
      prefs: NotificationPrefs.defaults,
    );
    final ids = matchedRecipes(ranked).map((item) => item.recipe.id);
    expect(ids, contains('jumeokbap'));
    expect(ids, isNot(contains('kimchi-jeon')));

    final riceBall = ranked.firstWhere((item) => item.recipe.id == 'jumeokbap');
    expect(riceBall.used.map((item) => item.id), [4]);
    expect(riceBall.assumed, isEmpty);
    expect(riceBall.missing, containsAll(['참기름', '김', '소금']));

    final fried = ranked.firstWhere(
      (item) => item.recipe.id == 'kimchi-fried-rice',
    );
    expect(fried.hasMatch, isTrue);
    expect(fried.assumed, ['김치']);
    expect(fried.missing, containsAll(['계란', '대파']));
    expect(fried.missing, isNot(contains('밥')));
  });

  test('wasabi still matches nothing when staples are assumed', () {
    final groups = groupRecipes(
      rankRecipes(
        recipes: sampleRecipes,
        stored: [storedItem(id: 1, name: '와사비', days: 5)],
        now: now,
        prefs: NotificationPrefs.defaults,
      ),
    );
    expect(groups.isEmpty, isTrue);
  });
}
