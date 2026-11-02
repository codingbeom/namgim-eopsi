import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/app_toast.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/names.dart';
import '../../domain/notification_prefs.dart';
import '../../domain/recipes.dart';
import '../../domain/urgency.dart';
import '../../providers/providers.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(ingredientsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('추천')),
      body: AsyncBody<List<IngredientItem>>(
        value: ingredients,
        data: (items) => _RecipesBody(items: items),
      ),
    );
  }
}

class _RecipesBody extends ConsumerWidget {
  const _RecipesBody({required this.items});

  final List<IngredientItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(rankedRecipesProvider);
    final prefs =
        ref.watch(settingsProvider).value ?? NotificationPrefs.defaults;
    final now = DateTime.now();
    final stored = [
      for (final item in items)
        if (item.status == IngredientStatus.stored) item,
    ];
    final groups = groupRecipes(recipes);
    final fridgeEmpty = stored.isEmpty;

    if (fridgeEmpty || groups.isEmpty) {
      return _EmptyRecipes(
        title: fridgeEmpty ? '냉장고가 비어 있어요' : '겹치는 메뉴가 없어요',
        body: recommendIntro(groups: groups, fridgeEmpty: fridgeEmpty),
      );
    }

    final urgentIngredients = stored
        .where(
          (item) => needsAttention(
            expiry: item.expiryDate,
            location: item.storageLocation,
            now: now,
            prefs: prefs,
          ),
        )
        .length;
    final urgentLabel = urgentIngredients == 0
        ? '임박한 재료 없음'
        : '임박 $urgentIngredients개';
    final needsMore = [
      ...groups.rescue,
      ...groups.stretch,
    ].any((scored) => scored.missing.isNotEmpty);
    final sections = <Widget>[
      if (groups.rescue.isNotEmpty)
        _RecipeSection(
          band: RecommendBand.rescue,
          title: '먼저 쓰면 좋아요',
          subtitle: '임박한 재료를 쓰고, 없는 재료는 하나 이하예요.',
          recipes: groups.rescue,
        ),
      if (groups.ready.isNotEmpty)
        _RecipeSection(
          band: RecommendBand.ready,
          title: '바로 만들 수 있어요',
          subtitle: '가진 재료만으로 충분하고, 서두르지 않아도 돼요.',
          recipes: groups.ready,
        ),
      if (groups.stretch.isNotEmpty)
        _RecipeSection(
          band: RecommendBand.stretch,
          title: '재료가 더 필요해요',
          subtitle: '없는 재료를 확인하고, 있는 것만 정리할 수 있어요.',
          recipes: groups.stretch,
        ),
    ];

    return ListView(
      key: const Key('recipes-list'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text(
          recommendIntro(groups: groups, fridgeEmpty: false),
          style: const TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 6),
        Text(
          '보관 ${stored.length}개 · $urgentLabel',
          key: const Key('recipes-summary'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.olive,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          sections[i],
        ],
        if (needsMore) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('recipes-add-missing'),
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add),
              label: const Text('없는 재료 담기'),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyRecipes extends StatelessWidget {
  const _EmptyRecipes({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        EmptyHint(title: title, body: body),
        FilledButton.icon(
          key: const Key('recipes-add'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: () => context.push('/add'),
          icon: const Icon(Icons.add),
          label: const Text('재료 추가'),
        ),
      ],
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({
    required this.band,
    required this.title,
    required this.subtitle,
    required this.recipes,
  });

  final RecommendBand band;
  final String title;
  final String subtitle;
  final List<ScoredRecipe> recipes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          key: Key('recipe-band-${band.name}'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.muted, height: 1.35),
        ),
        const SizedBox(height: 10),
        for (final scored in recipes) ...[
          _RecipeCard(scored: scored),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.scored});

  final ScoredRecipe scored;

  Future<void> _cook(BuildContext context, WidgetRef ref) async {
    final used = scored.used;
    if (used.isEmpty) return;
    final usedNames = used.map((item) => item.name).join(', ');
    final missing = scored.missing.isEmpty
        ? '없는 재료는 없어요.'
        : '없는 재료: ${scored.missing.join(', ')}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${scored.recipe.name} 만들고 정리'),
        content: Text('쓴 재료: $usedNames\n$missing\n먹음으로 정리할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('정리'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repository = ref.read(ingredientRepositoryProvider);
    for (final item in used) {
      await repository.setStatus(item.id, IngredientStatus.eaten);
    }
    if (!context.mounted) return;
    AppToast.show(
      context,
      '${used.length}개를 먹음으로 정리했어요',
      kind: AppToastKind.success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = scored.recipe;
    return Card(
      key: Key('recipe-${recipe.id}'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: _bandColor(scored.band)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${recipe.minutes}분',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  scored.reason,
                  key: Key('recipe-reason-${recipe.id}'),
                  style: TextStyle(
                    color: scored.urgentCount > 0
                        ? AppColors.accent
                        : AppColors.olive,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(recipe.summary, style: const TextStyle(height: 1.35)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final name in recipe.ingredients)
                      _IngredientChip(name: name, scored: scored),
                  ],
                ),
                const SizedBox(height: 4),
                _RecipeSteps(steps: recipe.steps),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _cook(context, ref),
                    child: Text(
                      scored.missing.isEmpty ? '만들고 재료 정리' : '가진 재료만 정리',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeSteps extends StatefulWidget {
  const _RecipeSteps({required this.steps});

  final String steps;

  @override
  State<_RecipeSteps> createState() => _RecipeStepsState();
}

class _RecipeStepsState extends State<_RecipeSteps> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.olive,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => setState(() => _open = !_open),
          icon: Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18),
          label: Text(_open ? '만드는 법 접기' : '만드는 법'),
        ),
        if (_open) ...[
          const SizedBox(height: 4),
          Text(
            widget.steps,
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.name, required this.scored});

  final String name;
  final ScoredRecipe scored;

  @override
  Widget build(BuildContext context) {
    IngredientItem? match;
    for (final item in scored.used) {
      if (namesMatch(item.name, name)) {
        match = item;
        break;
      }
    }
    final owned = match != null;
    final urgent = match != null && scored.urgentIds.contains(match.id);
    final days = match == null
        ? null
        : daysUntil(match.expiryDate, scored.scoredAt);
    final color = _chipColor(owned: owned, urgent: urgent, days: days);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: owned ? color.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: owned ? color : AppColors.line),
      ),
      child: Text(
        matchedIngredientLabel(name: name, scored: scored),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

Color _bandColor(RecommendBand band) => switch (band) {
  RecommendBand.rescue => AppColors.accent,
  RecommendBand.ready => AppColors.olive,
  RecommendBand.stretch => AppColors.soon,
  RecommendBand.none => AppColors.line,
};

Color _chipColor({
  required bool owned,
  required bool urgent,
  required int? days,
}) {
  if (!owned) return AppColors.muted;
  if (!urgent) return AppColors.olive;
  if (days != null && days < 0) return AppColors.danger;
  if (days != null && days == 0) return AppColors.accent;
  return AppColors.soon;
}
