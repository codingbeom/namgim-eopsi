import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_toast.dart';
import '../../core/format.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../providers/providers.dart';

Future<void> setIngredientStatus({
  required BuildContext context,
  required WidgetRef ref,
  required IngredientItem item,
  required IngredientStatus status,
  VoidCallback? onUndo,
}) async {
  final repository = ref.read(ingredientRepositoryProvider);
  await repository.setStatus(item.id, status);
  if (!context.mounted) return;
  final verb = status == IngredientStatus.eaten ? '먹었어요' : '버렸어요';
  AppToast.show(
    context,
    '${item.name} $verb',
    kind: AppToastKind.success,
    action: SnackBarAction(
      label: '되돌리기',
      onPressed: () {
        onUndo?.call();
        repository.setStatus(item.id, IngredientStatus.stored);
      },
    ),
  );
}

Future<void> openIngredient({
  required BuildContext context,
  required WidgetRef ref,
  required IngredientItem item,
}) async {
  if (item.isOpened) {
    AppToast.show(
      context,
      '${item.name}, 이미 개봉한 재료예요',
      kind: AppToastKind.info,
    );
    return;
  }

  final repository = ref.read(ingredientRepositoryProvider);
  final plan = await repository.previewOpen(item);
  if (!context.mounted) return;

  var moveToFridge = false;
  if (plan.suggestFridge) {
    final move = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('냉장으로 옮길까요?'),
        content: Text(
          '개봉한 ${item.name}은 냉장 보관이 좋아요. 기한은 ${formatMonthDay(plan.expiryDate)}로 다시 계산해요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('상온에 둘게요'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('냉장으로'),
          ),
        ],
      ),
    );
    if (move == null || !context.mounted) return;
    moveToFridge = move;
  }

  await repository.markOpened(
    id: item.id,
    expiryDate: plan.expiryDate,
    moveToFridge: moveToFridge,
  );
  if (!context.mounted) return;

  final message = moveToFridge
      ? '${item.name}을 냉장으로 옮기고 기한을 ${formatMonthDay(plan.expiryDate)}로 맞췄어요'
      : plan.shortened
      ? '${item.name} 개봉. 기한을 ${formatMonthDay(plan.expiryDate)}로 줄였어요'
      : '${item.name}을 개봉으로 표시했어요. 기한은 그대로예요';
  AppToast.show(context, message, kind: AppToastKind.info);
}

Future<void> showIngredientEditor({
  required BuildContext context,
  required WidgetRef ref,
  required IngredientItem item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _IngredientEditor(item: item),
  );
}

class _IngredientEditor extends ConsumerStatefulWidget {
  const _IngredientEditor({required this.item});

  final IngredientItem item;

  @override
  ConsumerState<_IngredientEditor> createState() => _IngredientEditorState();
}

class _IngredientEditorState extends ConsumerState<_IngredientEditor> {
  late double _quantity = widget.item.quantity;
  late StorageLocation _location = widget.item.storageLocation;
  late DateTime _expiry = widget.item.expiryDate;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    await ref
        .read(ingredientRepositoryProvider)
        .updateDetails(
          id: widget.item.id,
          quantity: _quantity,
          location: _location,
          expiryDate: _expiry,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('수량'),
              const Spacer(),
              IconButton(
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity -= 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Text(formatQuantity(_quantity)),
              IconButton(
                onPressed: _quantity < 99
                    ? () => setState(() => _quantity += 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<StorageLocation>(
            segments: [
              for (final location in StorageLocation.values)
                ButtonSegment(value: location, label: Text(location.label)),
            ],
            selected: {_location},
            onSelectionChanged: (value) =>
                setState(() => _location = value.first),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('유통기한'),
            subtitle: Text(formatMonthDay(_expiry)),
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          if (widget.item.status == IngredientStatus.stored &&
              !widget.item.isOpened)
            OutlinedButton(
              onPressed: () async {
                await openIngredient(
                  context: context,
                  ref: ref,
                  item: widget.item,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('개봉하고 기한 다시 계산'),
            ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _save, child: const Text('저장')),
        ],
      ),
    );
  }
}
