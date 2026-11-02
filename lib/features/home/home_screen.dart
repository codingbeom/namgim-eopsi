import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/notification_prefs.dart';
import '../../domain/recipes.dart';
import '../../domain/urgency.dart';
import '../../providers/providers.dart';
import '../shell/app_shell.dart';

const _pale = Color(0xFFD5E3A8);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(ingredientsProvider);
    final prefs =
        ref.watch(settingsProvider).value ?? NotificationPrefs.defaults;
    return Scaffold(
      appBar: AppBar(title: const Text('남김없이', key: Key('app-title'))),
      body: AsyncBody<List<IngredientItem>>(
        value: items,
        data: (all) => _HomeBody(items: all, prefs: prefs),
      ),
    );
  }
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody({required this.items, required this.prefs});

  final List<IngredientItem> items;
  final NotificationPrefs prefs;

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_enter.isAnimating || _enter.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _enter.value = 1;
    } else {
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  double _reveal(int index) {
    const step = 0.07;
    const span = 0.55;
    final start = index * step;
    final end = start + span;
    final raw = _enter.value;
    if (raw <= start) return 0;
    if (raw >= end) return 1;
    return Curves.easeOutCubic.transform((raw - start) / (end - start));
  }

  Widget _rise(int index, Widget child) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = _reveal(index);
        return Opacity(
          opacity: 0.4 + (0.6 * t),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 8),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final prefs = widget.prefs;
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
    final featured = recipes.where((scored) => scored.hasMatch).firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        _rise(
          0,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatMonthDay(now),
                style: const TextStyle(
                  color: AppColors.olive,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '입력은 간편하게, 식재료는 남김없이',
                key: Key('app-slogan'),
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _rise(
          1,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AttentionCard(count: attention.length, stored: stored.length),
              if (eaten + discarded > 0) ...[
                const SizedBox(height: 8),
                _HistoryPill(eaten: eaten, discarded: discarded),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _rise(
          2,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final location in StorageLocation.values) ...[
                  Expanded(
                    child: _StorageCard(
                      location: location,
                      summary: summaries[location]!,
                      onTap: () => context.go('/ingredients'),
                    ),
                  ),
                  if (location != StorageLocation.pantry)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        _rise(
          3,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                '임박한 재료',
                trailing: attention.isEmpty ? '없음' : '${attention.length}',
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: attention.isEmpty
                    ? _EmptyCard(
                        key: const ValueKey('imminent-empty'),
                        title: '오늘은 여유로워요',
                        body:
                            '냉장 ${prefs.fridgeLeadDays}일, 냉동 ${prefs.freezerLeadDays}일, 상온 ${prefs.pantryLateDays}일 안에 들어오면 여기에 보여요.',
                      )
                    : Column(
                        key: const ValueKey('imminent-list'),
                        children: [
                          for (final item in attention) ...[
                            _ImminentRow(item: item, now: now, prefs: prefs),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _rise(
          4,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                '오늘의 메뉴',
                trailing: featured != null && featured.hasMatch
                    ? '${featured.recipe.minutes}분'
                    : '없음',
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: featured == null || !featured.hasMatch
                    ? const _EmptyCard(
                        key: ValueKey('recipe-empty'),
                        title: '아직 맞출 메뉴가 없어요',
                        body: '재료를 담으면, 곧 상할 것부터 쓰는 메뉴가 올라와요.',
                      )
                    : _FeaturedCard(
                        key: const ValueKey('recipe-featured'),
                        scored: featured,
                        onTap: () => context.go('/recipes'),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _rise(
          5,
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
        ),
      ],
    );
  }
}

class _Load {
  const _Load(this.value, this.color);

  final double value;
  final Color color;

  static _Load of(int stored, int attention) {
    if (stored == 0) return const _Load(0, AppColors.line);
    if (attention == 0) return const _Load(1, AppColors.leaf);
    return _Load(attention / stored, AppColors.accent);
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.count, required this.stored});

  final int count;
  final int stored;

  @override
  Widget build(BuildContext context) {
    final quiet = count == 0;
    final load = _Load.of(stored, count);
    final caption = stored == 0
        ? '아직 담긴 재료가 없어요'
        : quiet
        ? '보관 $stored개 모두 여유'
        : '보관 $stored개 중 $count개';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.olive,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  quiet ? Icons.spa_outlined : Icons.schedule,
                  color: quiet ? _pale : AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiet ? '오늘 챙길 재료 없음' : '오늘 챙길 재료',
                      style: const TextStyle(
                        color: _pale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quiet ? '냉장고가 한가해요' : '기한이 가까운 것부터 보면 돼요',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _AnimatedCount(count: count),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            caption,
            style: const TextStyle(
              color: _pale,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _Meter(
            value: load.value,
            color: load.color,
            track: Colors.white24,
            height: 6,
          ),
        ],
      ),
    );
  }
}

class _AnimatedCount extends StatelessWidget {
  const _AnimatedCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: count.toDouble()),
      duration: const Duration(milliseconds: 640),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final shown = value.round();
        final t = count == 0 ? 1.0 : (shown / count).clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.94 + (0.06 * t),
          alignment: Alignment.centerRight,
          child: Text(
            '$shown',
            key: const Key('home-attention-count'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 1,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryPill extends StatelessWidget {
  const _HistoryPill({required this.eaten, required this.discarded});

  final int eaten;
  final int discarded;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          '먹은 $eaten · 버린 $discarded',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
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
    final color = storageColor(location.label);
    final load = _Load.of(summary.stored, summary.attention);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_storageIcon(location), size: 18, color: color),
              const SizedBox(height: 8),
              Text(
                location.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${summary.stored}개',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 8),
              _Meter(value: load.value, color: load.color),
              const SizedBox(height: 6),
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

class _Meter extends StatelessWidget {
  const _Meter({
    required this.value,
    required this.color,
    this.track = AppColors.line,
    this.height = 4,
  });

  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ColoredBox(
          color: track,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: target),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) {
              return Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: t,
                  heightFactor: 1,
                  child: ColoredBox(color: color),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: EmptyHint(title: title, body: body),
    );
  }
}

class _ImminentRow extends StatelessWidget {
  const _ImminentRow({
    required this.item,
    required this.now,
    required this.prefs,
  });

  final IngredientItem item;
  final DateTime now;
  final NotificationPrefs prefs;

  @override
  Widget build(BuildContext context) {
    final urgency = urgencyFor(
      expiry: item.expiryDate,
      location: item.storageLocation,
      now: now,
      prefs: prefs,
    );
    final color = urgencyColor(urgency);
    final opened = item.isOpened ? ' · 개봉' : '';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/ingredients'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(6),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatExpiry(item.expiryDate, now)} · ${formatQuantity(item.quantity)}개$opened',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: item.storageLocation.label,
                color: storageColor(item.storageLocation.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({super.key, required this.scored, required this.onTap});

  final ScoredRecipe scored;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final recipe = scored.recipe;
    final urgent = scored.urgentCount > 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 14, 12, 14),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 72,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: urgent ? AppColors.accent : AppColors.olive,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(6),
                  ),
                ),
              ),
              Expanded(
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
                        const Icon(Icons.chevron_right, color: AppColors.olive),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scored.reason,
                      key: const Key('home-recipe-reason'),
                      style: TextStyle(
                        color: urgent ? AppColors.accent : AppColors.olive,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.summary,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _storageIcon(StorageLocation location) {
  return switch (location) {
    StorageLocation.fridge => Icons.kitchen_outlined,
    StorageLocation.freezer => Icons.ac_unit,
    StorageLocation.pantry => Icons.inventory_2_outlined,
  };
}
