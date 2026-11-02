import 'dates.dart';
import 'enums.dart';
import 'models.dart';
import 'names.dart';
import 'notification_prefs.dart';
import 'urgency.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.minutes,
    required this.summary,
    required this.steps,
    required this.ingredients,
  });

  final String id;
  final String name;
  final int minutes;
  final String summary;
  final String steps;
  final List<String> ingredients;
}

class ScoredRecipe {
  const ScoredRecipe({
    required this.recipe,
    required this.used,
    required this.missing,
    required this.urgentIds,
    required this.urgentCount,
    required this.score,
  });

  final Recipe recipe;
  final List<IngredientItem> used;
  final List<String> missing;
  final List<int> urgentIds;
  final int urgentCount;
  final int score;

  bool get hasMatch => used.isNotEmpty;
}

const sampleRecipes = <Recipe>[
  Recipe(
    id: 'tofu-jorim',
    name: '두부조림',
    minutes: 15,
    summary: '노릇하게 구운 두부에 굴소스와 대파를 얹어요.',
    steps: '두부는 도톰하게 썰어 팬에 구워요. 굴소스 1숟갈과 물을 조금 넣고, 송송 썬 대파를 올려 1분만 졸여요.',
    ingredients: ['두부', '대파', '굴소스'],
  ),
  Recipe(
    id: 'french-toast',
    name: '프렌치토스트',
    minutes: 15,
    summary: '식빵을 계란·우유에 적셔 노릇하게 굽는 아침.',
    steps: '계란과 우유를 풀어 식빵을 적셔요. 팬에 약불로 앞뒤를 구워요. 설탕은 집에 있는 만큼만.',
    ingredients: ['식빵', '계란', '우유'],
  ),
  Recipe(
    id: 'gyeran-jjim',
    name: '계란찜',
    minutes: 12,
    summary: '대파만 올리면 되는 짧은 계란찜.',
    steps: '계란을 풀고 물을 조금 넣어요. 대파를 얹어 약불로 찌거나 전자레인지에 2분 돌려요.',
    ingredients: ['계란', '대파'],
  ),
  Recipe(
    id: 'egg-drop-soup',
    name: '대파계란국',
    minutes: 10,
    summary: '물 끓이고 대파와 계란만 넣어요.',
    steps: '물을 끓여 대파를 먼저 넣고, 푼 계란을 저으며 부어요. 소금이나 굴소스가 있으면 간해요.',
    ingredients: ['대파', '계란'],
  ),
  Recipe(
    id: 'egg-fried-rice',
    name: '계란볶음밥',
    minutes: 12,
    summary: '찬밥이 있으면 대파·계란·굴소스로 마무리해요.',
    steps: '대파를 볶고 찬밥을 넣어 풀어줘요. 계란을 가장자리에 스크램블한 뒤 굴소스로 간해요.',
    ingredients: ['계란', '대파', '굴소스'],
  ),
  Recipe(
    id: 'mandu-guk',
    name: '만두국',
    minutes: 15,
    summary: '냉동만두를 끓이고 계란과 대파를 올려요.',
    steps: '물을 끓여 만두를 넣고 떠오를 때까지 끓여요. 대파를 올리고 계란을 풀어 한 번 더 끓여요.',
    ingredients: ['만두', '대파', '계란'],
  ),
  Recipe(
    id: 'onion-stir',
    name: '양파볶음',
    minutes: 10,
    summary: '양파를 굴소스로 빠르게 볶아요.',
    steps: '양파를 채 썰어 팬에 볶다가 숨이 죽으면 굴소스를 둘러요. 밥 위에 얹어 먹어도 돼요.',
    ingredients: ['양파', '굴소스'],
  ),
];

ScoredRecipe scoreRecipe({
  required Recipe recipe,
  required List<IngredientItem> stored,
  required DateTime now,
  required NotificationPrefs prefs,
}) {
  final pool = [...stored];
  final used = <IngredientItem>[];
  final missing = <String>[];
  for (final needed in recipe.ingredients) {
    IngredientItem? best;
    for (final item in pool) {
      if (!namesMatch(item.name, needed)) continue;
      if (best == null || item.expiryDate.isBefore(best.expiryDate)) {
        best = item;
      }
    }
    if (best == null) {
      missing.add(needed);
      continue;
    }
    used.add(best);
    pool.remove(best);
  }

  final urgentIds = <int>[];
  for (final item in used) {
    final urgent = needsAttention(
      expiry: item.expiryDate,
      location: item.storageLocation,
      now: now,
      prefs: prefs,
    );
    if (urgent) urgentIds.add(item.id);
  }
  final urgentCount = urgentIds.length;

  var score = 0;
  if (used.isEmpty) {
    score -= 100;
  }
  score += used.length * 10;
  score += urgentCount * 25;
  score -= missing.length * 3;
  for (final item in used) {
    final days = daysUntil(item.expiryDate, now);
    if (days < 0) score += 8;
  }

  return ScoredRecipe(
    recipe: recipe,
    used: used,
    missing: missing,
    urgentIds: urgentIds,
    urgentCount: urgentCount,
    score: score,
  );
}

List<ScoredRecipe> rankRecipes({
  required List<Recipe> recipes,
  required List<IngredientItem> stored,
  required DateTime now,
  required NotificationPrefs prefs,
}) {
  final active = stored
      .where((item) => item.status == IngredientStatus.stored)
      .toList();
  final ranked = [
    for (final recipe in recipes)
      scoreRecipe(recipe: recipe, stored: active, now: now, prefs: prefs),
  ];
  ranked.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byUrgent = b.urgentCount.compareTo(a.urgentCount);
    if (byUrgent != 0) return byUrgent;
    return a.recipe.name.compareTo(b.recipe.name);
  });
  return ranked;
}
