import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/app_toast.dart';
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

class _ExpiryPreset {
  const _ExpiryPreset(this.days, this.label);

  final int days;
  final String label;
}

const _expiryPresets = <_ExpiryPreset>[
  _ExpiryPreset(0, '오늘'),
  _ExpiryPreset(3, '+3일'),
  _ExpiryPreset(7, '+7일'),
  _ExpiryPreset(14, '+14일'),
];

class AddIngredientScreen extends ConsumerStatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  ConsumerState<AddIngredientScreen> createState() =>
      _AddIngredientScreenState();
}

class _AddIngredientScreenState extends ConsumerState<AddIngredientScreen> {
  final _nameKey = GlobalKey();
  String _name = '';
  StorageLocation _location = StorageLocation.fridge;
  late DateTime _expiry;
  double _quantity = 1;
  bool _storageTouched = false;
  bool _expiryTouched = false;
  bool _saveFavorite = false;
  bool _saving = false;
  bool _nameMissing = false;
  late String _helper;

  @override
  void initState() {
    super.initState();
    _expiry = addDays(DateTime.now(), fallbackShelfDays(_location));
    _helper = _fallbackHelper(_location);
  }

  String _fallbackHelper(StorageLocation location) {
    return ExpirySuggestion(
      days: fallbackShelfDays(location),
      location: location,
      fromFallback: true,
    ).helper;
  }

  void _recompute({StorageLocation? location, int? days, String? keyword}) {
    final rules = ref.read(shelfLifeProvider).value ?? const <ShelfLifeRule>[];
    final name = _name.trim();
    if (location != null && !_storageTouched) {
      _location = location;
    }
    if (name.isEmpty) {
      if (!_expiryTouched) {
        _expiry = addDays(DateTime.now(), fallbackShelfDays(_location));
        _helper = _fallbackHelper(_location);
      }
      return;
    }
    if (days != null && keyword != null) {
      if (!_expiryTouched) {
        _expiry = addDays(DateTime.now(), days);
        _helper = '$keyword · ${_location.label} $days일';
      }
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
      _helper = suggestion.helper;
    }
  }

  Future<void> _addFavorite(FavoriteItem favorite) async {
    final id = await ref
        .read(ingredientRepositoryProvider)
        .addFromFavorite(favorite);
    if (!mounted) return;
    AppToast.show(
      context,
      '${favorite.name} 담았어요',
      kind: AppToastKind.success,
      action: SnackBarAction(
        label: '되돌리기',
        onPressed: () {
          ref.read(ingredientRepositoryProvider).delete(id);
        },
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

  void _applyPreset(int days) {
    setState(() {
      _expiry = addDays(DateTime.now(), days);
      _expiryTouched = true;
      _helper = days == 0 ? '오늘까지로 골랐어요' : '$days일 뒤로 골랐어요';
    });
  }

  void _showNameError() {
    setState(() => _nameMissing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _nameKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_saving) return;
    final name = _name.trim();
    if (name.isEmpty) {
      _showNameError();
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
          AppToast.show(
            context,
            '같은 이름의 즐겨찾기가 이미 있어요',
            kind: AppToastKind.info,
          );
        }
      }
      if (!mounted) return;
      AppToast.show(context, '$name 담았어요', kind: AppToastKind.success);
      context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shelfLifeProvider, (_, _) {
      setState(() => _recompute());
    });
    final favorites = ref.watch(favoritesProvider);
    final rules = ref.watch(shelfLifeProvider).value ?? const <ShelfLifeRule>[];
    final options = _options(favorites.value ?? const [], rules);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('재료 추가')),
      // The footer lives in the body so the scaffold can lift it above the
      // keyboard. bottomNavigationBar stays pinned to the screen bottom.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              key: const Key('add-form'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
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
                const SizedBox(height: 8),
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
                const SizedBox(height: 16),
                const Text(
                  '직접 입력',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Autocomplete<_NameOption>(
                  displayStringForOption: (option) => option.name,
                  optionsBuilder: (value) {
                    final query = compactName(value.text);
                    if (query.isEmpty) {
                      return const Iterable<_NameOption>.empty();
                    }
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
                      _nameMissing = false;
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
                      key: _nameKey,
                      controller: controller,
                      focusNode: focusNode,
                      scrollPadding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      decoration: InputDecoration(
                        labelText: '이름',
                        hintText: '두부, 우유, 굴소스',
                        errorText: _nameMissing && _name.trim().isEmpty
                            ? '이름을 입력하거나 위 칩을 누르세요'
                            : null,
                        errorMaxLines: 2,
                      ),
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        _name = value;
                        setState(() {
                          if (value.trim().isNotEmpty) _nameMissing = false;
                          _recompute();
                        });
                      },
                      onSubmitted: (_) {
                        onSubmit();
                        focusNode.unfocus();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text('보관', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SegmentedButton<StorageLocation>(
                  showSelectedIcon: false,
                  segments: [
                    for (final location in StorageLocation.values)
                      ButtonSegment(
                        value: location,
                        label: Text(location.label),
                      ),
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
                const SizedBox(height: 8),
                _expirySection(),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '수량',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: '수량 줄이기',
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity -= 1)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '${formatQuantity(_quantity)}개',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: '수량 늘리기',
                      onPressed: _quantity < 99
                          ? () => setState(() => _quantity += 1)
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  title: const Text('즐겨찾기에 추가'),
                  subtitle: const Text('다음엔 칩 한 번으로 다시 담아요'),
                  value: _saveFavorite,
                  onChanged: (value) => setState(() => _saveFavorite = value),
                ),
                const Divider(),
                const SizedBox(height: 12),
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
          ),
          _saveBar(),
        ],
      ),
    );
  }

  Widget _expirySection() {
    final selectedDays = daysUntil(_expiry, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '유통기한',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatMonthDay(_expiry),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _helper,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Tooltip(
                  message: '날짜 직접 선택',
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.olive,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _expiryPresets)
              ChoiceChip(
                label: Text(preset.label),
                selected: selectedDays == preset.days,
                showCheckmark: false,
                selectedColor: AppColors.leaf.withValues(alpha: 0.45),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selectedDays == preset.days
                      ? AppColors.olive
                      : AppColors.line,
                ),
                labelStyle: TextStyle(
                  color: AppColors.ink,
                  fontWeight: selectedDays == preset.days
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                onSelected: (_) => _applyPreset(preset.days),
              ),
          ],
        ),
      ],
    );
  }

  Widget _saveBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: FilledButton(
            key: const Key('add-submit'),
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(_saving ? '담는 중' : '담기'),
          ),
        ),
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
