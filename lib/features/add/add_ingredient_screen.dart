import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/format.dart';
import '../../core/widgets/async_body.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/models.dart';
import '../../domain/names.dart';
import '../../domain/shelf_life.dart';
import '../../providers/providers.dart';

class _NameOption {
  const _NameOption({
    required this.name,
    required this.location,
    required this.days,
    required this.source,
  });

  final String name;
  final StorageLocation location;
  final int days;
  final String source;

  String get label => '$name · $source · ${location.label} $days일';
}

class AddIngredientScreen extends ConsumerStatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  ConsumerState<AddIngredientScreen> createState() =>
      _AddIngredientScreenState();
}

class _AddIngredientScreenState extends ConsumerState<AddIngredientScreen> {
  String _name = '';
  StorageLocation _location = StorageLocation.fridge;
  late DateTime _expiry = addDays(DateTime.now(), 7);
  double _quantity = 1;
  bool _storageTouched = false;
  bool _expiryTouched = false;
  bool _saveFavorite = false;
  bool _saving = false;
  String _helper = '즐겨찾기나 이름을 입력하면 기한을 다시 계산해요';

  void _recompute({StorageLocation? location, int? days, String? keyword}) {
    final rules = ref.read(shelfLifeProvider).value ?? const <ShelfLifeRule>[];
    final name = _name.trim();
    if (location != null && !_storageTouched) {
      _location = location;
    }
    if (name.isEmpty) {
      if (!_expiryTouched) {
        _expiry = addDays(DateTime.now(), fallbackShelfDays(_location));
      }
      _helper = '즐겨찾기나 이름을 입력하면 기한을 다시 계산해요';
      return;
    }
    if (days != null && keyword != null) {
      if (!_expiryTouched) {
        _expiry = addDays(DateTime.now(), days);
      }
      _helper = '$keyword · ${_location.label} $days일';
      return;
    }
    final suggestion = suggestExpiry(
      rules: rules,
      name: name,
      location: _location,
      lockLocation: _storageTouched,
    );
    if (!_storageTouched) {
      _location = suggestion.location;
    }
    if (!_expiryTouched) {
      _expiry = addDays(DateTime.now(), suggestion.days);
    }
    _helper = suggestion.helper;
  }

  Future<void> _addFavorite(FavoriteItem favorite) async {
    final id = await ref
        .read(ingredientRepositoryProvider)
        .addFromFavorite(favorite);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${favorite.name} 담았어요'),
        action: SnackBarAction(
          label: '되돌리기',
          onPressed: () {
            ref.read(ingredientRepositoryProvider).delete(id);
          },
        ),
      ),
    );
  }

  Future<void> _removeFavorite(FavoriteItem favorite) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('즐겨찾기에서 뺄까요?'),
        content: Text('${favorite.name} 칩만 사라져요. 이미 담은 재료는 그대로예요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('빼기'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(favoriteRepositoryProvider).delete(favorite.id);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    setState(() {
      _expiry = picked;
      _expiryTouched = true;
      _helper = '날짜를 직접 골랐어요';
    });
  }

  Future<void> _save() async {
    final name = _name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('이름을 입력하거나 위 칩을 누르세요')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(ingredientRepositoryProvider)
          .add(
            name: name,
            quantity: _quantity,
            location: _location,
            expiryDate: _expiry,
          );
      if (_saveFavorite) {
        final days = daysUntil(_expiry, DateTime.now());
        final added = await ref
            .read(favoriteRepositoryProvider)
            .addIfAbsent(
              name: name,
              location: _location,
              shelfDays: days < 0 ? null : days,
            );
        if (!added && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('같은 이름의 즐겨찾기가 이미 있어요')));
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$name 담았어요')));
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shelfLifeProvider, (_, _) {
      setState(_recompute);
    });
    final favorites = ref.watch(favoritesProvider);
    final rules = ref.watch(shelfLifeProvider).value ?? const <ShelfLifeRule>[];
    final options = _options(favorites.value ?? const [], rules);

    return Scaffold(
      appBar: AppBar(title: const Text('재료 추가')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          const Text(
            '자주 사는 것',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            '한 번 누르면 바로 담겨요. 길게 누르면 즐겨찾기에서 빼요.',
            style: TextStyle(color: AppColors.muted, height: 1.35),
          ),
          const SizedBox(height: 10),
          AsyncBody<List<FavoriteItem>>(
            value: favorites,
            data: (items) {
              if (items.isEmpty) {
                return const Text(
                  '즐겨찾기가 비어 있어요. 아래에서 담을 때 저장할 수 있어요.',
                  style: TextStyle(color: AppColors.muted),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final favorite in items)
                    GestureDetector(
                      onLongPress: () => _removeFavorite(favorite),
                      child: ActionChip(
                        label: Text(favorite.name),
                        avatar: const Icon(Icons.touch_app, size: 18),
                        onPressed: () => _addFavorite(favorite),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const Text(
            '직접 입력',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Autocomplete<_NameOption>(
            displayStringForOption: (option) => option.name,
            optionsBuilder: (value) {
              final query = compactName(value.text);
              if (query.isEmpty) return const Iterable<_NameOption>.empty();
              return options
                  .where((option) {
                    final name = compactName(option.name);
                    return name.contains(query) || query.contains(name);
                  })
                  .take(8);
            },
            onSelected: (option) {
              _name = option.name;
              setState(() {
                if (!_storageTouched) _location = option.location;
                _recompute(
                  location: option.location,
                  days: option.days,
                  keyword: option.name,
                );
              });
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmit) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '두부, 우유, 굴소스',
                ),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  _name = value;
                  setState(_recompute);
                },
                onSubmitted: (_) => onSubmit(),
              );
            },
          ),
          const SizedBox(height: 14),
          SegmentedButton<StorageLocation>(
            showSelectedIcon: false,
            segments: [
              for (final location in StorageLocation.values)
                ButtonSegment(value: location, label: Text(location.label)),
            ],
            selected: {_location},
            onSelectionChanged: (value) {
              setState(() {
                _location = value.first;
                _storageTouched = true;
                _recompute();
              });
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('유통기한'),
            subtitle: Text('${formatMonthDay(_expiry)}\n$_helper'),
            isThreeLine: true,
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: _pickDate,
          ),
          Row(
            children: [
              const Text('수량', style: TextStyle(fontWeight: FontWeight.w600)),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('즐겨찾기에 추가'),
            subtitle: const Text('다음엔 칩 한 번으로 다시 담아요'),
            value: _saveFavorite,
            onChanged: (value) => setState(() => _saveFavorite = value),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('add-submit'),
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '담는 중' : '담기'),
          ),
          const SizedBox(height: 22),
          const Text(
            '바코드와 날짜 촬영은 6주차에 붙여요. 지금은 기본 보관 기한으로 채워요.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                // TODO(week6): ML Kit barcode. GS1 date first, then shelf-life fallback.
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('바코드'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                // TODO(week6): ML Kit text recognition for the printed date.
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('날짜 촬영'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_NameOption> _options(
    List<FavoriteItem> favorites,
    List<ShelfLifeRule> rules,
  ) {
    final options = <_NameOption>[
      for (final favorite in favorites)
        _NameOption(
          name: favorite.name,
          location: favorite.defaultStorageLocation,
          days:
              favorite.defaultShelfDays ??
              fallbackShelfDays(favorite.defaultStorageLocation),
          source: '즐겨찾기',
        ),
      for (final rule in rules)
        _NameOption(
          name: rule.nameKeyword,
          location: rule.storageLocation,
          days: rule.days,
          source: rule.category ?? '기본 기한',
        ),
    ];
    return options;
  }
}
