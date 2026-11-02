import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/names.dart';
import '../../domain/recipes.dart';
import '../../providers/providers.dart';

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(rankedRecipesProvider);
    final loading = ref.watch(ingredientsProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('추천')),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.olive),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                const Text(
                  '곧 상할 재료를 쓰는 메뉴를 위로 올렸어요. 네트워크 없이, 예시 레시피만 비교해요.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                for (final scored in recipes) ...[
                  _RecipeCard(scored: scored),
                  const SizedBox(height: 10),
                ],
              ],
            ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.scored});

  final ScoredRecipe scored;

  Future<void> _cook(BuildContext context, WidgetRef ref) async {
    final used = scored.used;
    if (used.isEmpty) return;
    final names = used.map((item) => item.name).join(', ');
    final missing = scored.missing.isEmpty
        ? '없는 재료는 없어요.'
        : '없는 재료: ${scored.missing.join(', ')}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${scored.recipe.name} 만들고 정리'),
        content: Text('$names을 먹음으로 정리할까요?\n$missing'),
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${used.length}개를 먹음으로 정리했어요')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipe = scored.recipe;
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
            const SizedBox(height: 6),
            Text(recipe.summary, style: const TextStyle(height: 1.35)),
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
                  _IngredientChip(name: name, scored: scored),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: scored.hasMatch ? () => _cook(context, ref) : null,
                child: Text(scored.hasMatch ? '만들고 재료 정리' : '가진 재료가 없어요'),
              ),
            ),
          ],
        ),
      ),
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
    final color = !owned
        ? AppColors.muted
        : urgent
        ? AppColors.accent
        : AppColors.olive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: owned ? color.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: owned ? color : AppColors.line),
      ),
      child: Text(
        owned ? (urgent ? '$name 임박' : name) : '$name 없음',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
