import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/enums.dart';
import '../../domain/names.dart';
import '../../domain/notification_prefs.dart';
import '../../domain/recipes.dart';
import '../../providers/providers.dart';

class RecipeCatalogScreen extends ConsumerStatefulWidget {
  const RecipeCatalogScreen({super.key});

  @override
  ConsumerState<RecipeCatalogScreen> createState() =>
      _RecipeCatalogScreenState();
}

class _RecipeCatalogScreenState extends ConsumerState<RecipeCatalogScreen> {
  final _search = TextEditingController();
  String _query = '';
  RecipeCategory? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(ingredientsProvider);
    final prefs =
        ref.watch(settingsProvider).value ?? NotificationPrefs.defaults;
    final visible = filterRecipes(
      sampleRecipes,
      query: _query,
      category: _category,
    );
    final filtering = _query.trim().isNotEmpty || _category != null;

    return Scaffold(
      appBar: AppBar(title: const Text('레시피')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              '냉장고와 상관없이, 샘플 메뉴를 전부 둘러봐요.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              key: const Key('recipe-search'),
              controller: _search,
              onChanged: _setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '메뉴, 재료 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        key: const Key('recipe-search-clear'),
                        tooltip: '지우기',
                        onPressed: () {
                          _search.clear();
                          _setQuery('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CategoryChip(
                  key: const Key('recipe-category-all'),
                  label: '전체',
                  selected: _category == null,
                  onSelected: () => setState(() => _category = null),
                ),
                for (final category in RecipeCategory.values)
                  _CategoryChip(
                    key: Key('recipe-category-${category.name}'),
                    label: category.label,
                    selected: _category == category,
                    onSelected: () => setState(() {
                      _category = _category == category ? null : category;
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              filtering ? '${visible.length}개' : '샘플 ${visible.length}개',
              key: const Key('recipe-result-count'),
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: ingredients.when(
              skipLoadingOnReload: true,
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.olive),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    '불러오지 못했어요\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.danger,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              data: (items) {
                if (visible.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      EmptyHint(
                        title: filtering ? '찾는 메뉴가 없어요' : '보여줄 레시피가 없어요',
                        body: filtering
                            ? '다른 이름이나 재료, 분류로 다시 찾아 보세요.'
                            : '샘플 메뉴가 아직 없어요.',
                      ),
                    ],
                  );
                }
                final stored = [
                  for (final item in items)
                    if (item.status == IngredientStatus.stored) item,
                ];
                final now = DateTime.now();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  children: [
                    for (final recipe in visible) ...[
                      _CatalogCard(
                        scored: scoreRecipe(
                          recipe: recipe,
                          stored: stored,
                          now: now,
                          prefs: prefs,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      visualDensity: VisualDensity.compact,
      selectedColor: AppColors.leaf.withValues(alpha: 0.45),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.olive : AppColors.muted,
      ),
      side: const BorderSide(color: AppColors.line),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.scored});

  final ScoredRecipe scored;

  @override
  Widget build(BuildContext context) {
    final recipe = scored.recipe;
    final ready = scored.missing.isEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 4),
            Text(
              recipe.category.label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(recipe.summary, style: const TextStyle(height: 1.35)),
            const SizedBox(height: 8),
            Text(
              recipeGapLabel(scored),
              key: Key('recipe-missing-${recipe.id}'),
              style: TextStyle(
                color: ready ? AppColors.olive : AppColors.accent,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.steps,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final name in recipe.ingredients)
                  _CatalogChip(name: name, scored: scored),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogChip extends StatelessWidget {
  const _CatalogChip({required this.name, required this.scored});

  final String name;
  final ScoredRecipe scored;

  @override
  Widget build(BuildContext context) {
    final owned = scored.used.any((item) => namesMatch(item.name, name));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: owned
            ? AppColors.olive.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: owned ? AppColors.olive : AppColors.line),
      ),
      child: Text(
        owned ? name : '$name 없음',
        style: TextStyle(
          color: owned ? AppColors.olive : AppColors.muted,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
