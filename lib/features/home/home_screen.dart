import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/notification_prefs.dart';
import '../../domain/urgency.dart';
import '../../providers/providers.dart';
import '../shell/app_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(ingredientsProvider);
    final prefs =
        ref.watch(settingsProvider).value ?? NotificationPrefs.defaults;
    return AsyncBody<List<IngredientItem>>(
      value: items,
      data: (all) => _HomeBody(items: all, prefs: prefs),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.items, required this.prefs});

  final List<IngredientItem> items;
  final NotificationPrefs prefs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final stored = items
        .where((item) => item.status == IngredientStatus.stored)
        .toList();
    final attention = stored
        .where(
          (item) => needsAttention(
            expiry: item.expiryDate,
            location: item.storageLocation,
            now: now,
            prefs: prefs,
          ),
        )
        .toList();
    final summaries = summarizeStorage(items, now, prefs);
    final eaten = items
        .where((item) => item.status == IngredientStatus.eaten)
        .length;
    final discarded = items
        .where((item) => item.status == IngredientStatus.discarded)
        .length;
    final recipes = ref.watch(rankedRecipesProvider);
    final featured = recipes.isEmpty ? null : recipes.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text(
          '남김없이',
          key: Key('app-title'),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.olive,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '입력은 간편하게, 식재료는 남김없이',
          key: Key('app-slogan'),
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 18),
        _AttentionCard(count: attention.length),
        if (eaten + discarded > 0) ...[
          const SizedBox(height: 8),
          Text(
            '먹은 $eaten · 버린 $discarded',
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            for (final location in StorageLocation.values) ...[
              Expanded(
                child: _StorageCard(
                  location: location,
                  summary: summaries[location]!,
                  onTap: () => context.go('/ingredients'),
                ),
              ),
              if (location != StorageLocation.pantry) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 22),
        const _SectionTitle('임박한 재료'),
        const SizedBox(height: 8),
        if (attention.isEmpty)
          EmptyHint(
            title: '오늘은 여유로워요',
            body:
                '냉장 ${prefs.fridgeLeadDays}일, 냉동 ${prefs.freezerLeadDays}일, 상온 ${prefs.pantryLateDays}일 안에 들어오면 여기에 보여요.',
          )
        else
          for (final item in attention) ...[
            _ImminentRow(item: item, now: now),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 12),
        const _SectionTitle('오늘의 메뉴'),
        const SizedBox(height: 8),
        if (featured == null || !featured.hasMatch)
          const EmptyHint(
            title: '아직 맞출 메뉴가 없어요',
            body: '재료를 담으면, 곧 상할 것부터 쓰는 메뉴가 올라와요.',
          )
        else
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/recipes'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featured.recipe.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      featured.recipe.summary,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '임박 재료 ${featured.urgentCount}개 · ${featured.recipe.minutes}분',
                      style: const TextStyle(
                        color: AppColors.olive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () => context.push('/add'),
          icon: const Icon(Icons.add),
          label: const Text('재료 추가'),
        ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final quiet = count == 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: quiet ? AppColors.olive : AppColors.olive,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiet ? '오늘 챙길 재료 없음' : '오늘 챙길 재료',
                  style: const TextStyle(
                    color: Color(0xFFD5E3A8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quiet ? '냉장고가 한가해요' : '기한이 가까운 것부터 보면 돼요',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Text(
            '$count',
            key: const Key('home-attention-count'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({
    required this.location,
    required this.summary,
    required this.onTap,
  });

  final StorageLocation location;
  final StorageSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${summary.stored}개',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                summary.attention == 0 ? '여유' : '임박 ${summary.attention}',
                style: TextStyle(
                  color: summary.attention == 0
                      ? AppColors.muted
                      : AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _ImminentRow extends StatelessWidget {
  const _ImminentRow({required this.item, required this.now});

  final IngredientItem item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.go('/ingredients'),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(formatExpiry(item.expiryDate, now)),
        trailing: StatusChip(
          label: item.storageLocation.label,
          color: storageColor(item.storageLocation.label),
        ),
      ),
    );
  }
}
