import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_body.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/notification_prefs.dart';
import '../../providers/providers.dart';
import 'ingredient_actions.dart';
import 'ingredient_tile.dart';

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});

  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  IngredientStatus _status = IngredientStatus.stored;
  final Set<int> _hidden = {};

  List<IngredientItem> _visible(List<IngredientItem> items) {
    return [
      for (final item in items)
        if (item.status == _status && !_hidden.contains(item.id)) item,
    ];
  }

  Future<void> _dismiss(IngredientItem item, IngredientStatus status) async {
    setState(() => _hidden.add(item.id));
    await setIngredientStatus(
      context: context,
      ref: ref,
      item: item,
      status: status,
      onUndo: () {
        if (mounted) setState(() => _hidden.remove(item.id));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(ingredientsProvider);
    final prefs =
        ref.watch(settingsProvider).value ?? NotificationPrefs.defaults;
    final now = DateTime.now();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('식재료'),
          actions: [
            IconButton(
              tooltip: '재료 추가',
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add'),
          icon: const Icon(Icons.add),
          label: const Text('재료 추가'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SegmentedButton<IngredientStatus>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: IngredientStatus.stored,
                    label: Text('보관'),
                  ),
                  ButtonSegment(
                    value: IngredientStatus.eaten,
                    label: Text('먹음'),
                  ),
                  ButtonSegment(
                    value: IngredientStatus.discarded,
                    label: Text('버림'),
                  ),
                ],
                selected: {_status},
                onSelectionChanged: (value) {
                  setState(() => _status = value.first);
                },
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: '전체'),
                Tab(text: '냉장'),
                Tab(text: '냉동'),
                Tab(text: '상온'),
              ],
            ),
            Expanded(
              child: AsyncBody<List<IngredientItem>>(
                value: items,
                data: (all) {
                  final visible = _visible(all);
                  return TabBarView(
                    children: [
                      _LocationList(
                        items: visible,
                        location: null,
                        status: _status,
                        prefs: prefs,
                        now: now,
                        onDismiss: _dismiss,
                      ),
                      for (final location in StorageLocation.values)
                        _LocationList(
                          items: visible
                              .where((item) => item.storageLocation == location)
                              .toList(),
                          location: location,
                          status: _status,
                          prefs: prefs,
                          now: now,
                          onDismiss: _dismiss,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationList extends ConsumerWidget {
  const _LocationList({
    required this.items,
    required this.location,
    required this.status,
    required this.prefs,
    required this.now,
    required this.onDismiss,
  });

  final List<IngredientItem> items;
  final StorageLocation? location;
  final IngredientStatus status;
  final NotificationPrefs prefs;
  final DateTime now;
  final Future<void> Function(IngredientItem item, IngredientStatus status)
  onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      final place = location?.place ?? '집';
      final title = switch (status) {
        IngredientStatus.stored => '$place에 담긴 재료가 없어요',
        IngredientStatus.eaten => '먹은 기록이 없어요',
        IngredientStatus.discarded => '버린 기록이 없어요',
      };
      return ListView(
        children: [
          EmptyHint(
            title: title,
            body: status == IngredientStatus.stored
                ? '즐겨찾기를 한 번 누르면 날짜까지 채워져요.'
                : '목록에서 먹음이나 버림을 누르면 여기에 남아요.',
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final tile = IngredientTile(
          item: item,
          prefs: prefs,
          now: now,
          onEat: () => onDismiss(item, IngredientStatus.eaten),
          onDiscard: () => onDismiss(item, IngredientStatus.discarded),
          onOpen: () => openIngredient(context: context, ref: ref, item: item),
          onEdit: status == IngredientStatus.stored
              ? () =>
                    showIngredientEditor(context: context, ref: ref, item: item)
              : null,
        );
        if (status != IngredientStatus.stored) return tile;
        return Dismissible(
          key: ValueKey('ingredient-${item.id}'),
          background: const _SwipeBackground(
            alignment: Alignment.centerLeft,
            color: Color(0xFF97B33F),
            label: '먹음',
          ),
          secondaryBackground: const _SwipeBackground(
            alignment: Alignment.centerRight,
            color: Color(0xFFB42318),
            label: '버림',
          ),
          onDismissed: (direction) {
            final next = direction == DismissDirection.startToEnd
                ? IngredientStatus.eaten
                : IngredientStatus.discarded;
            onDismiss(item, next);
          },
          child: tile,
        );
      },
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
