import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/app/namgim_app.dart';
import 'package:namgim_eopsi/core/format.dart';
import 'package:namgim_eopsi/data/repositories/ingredient_repository.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/domain/open_plan.dart';
import 'package:namgim_eopsi/providers/providers.dart';

class _RecordingIngredients implements IngredientRepository {
  _RecordingIngredients({this.gate});

  final Completer<void>? gate;
  int adds = 0;
  String? lastName;
  double? lastQuantity;
  StorageLocation? lastLocation;

  @override
  Future<int> add({
    required String name,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  }) async {
    adds += 1;
    lastName = name;
    lastQuantity = quantity;
    lastLocation = location;
    final gate = this.gate;
    if (gate != null) await gate.future;
    return adds;
  }

  @override
  Stream<List<IngredientItem>> watchAll() => const Stream.empty();

  @override
  Future<int> addFromFavorite(FavoriteItem favorite) async => 0;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> setStatus(int id, IngredientStatus status) async {}

  @override
  Future<void> updateDetails({
    required int id,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  }) async {}

  @override
  Future<OpenPlan> previewOpen(IngredientItem item, {DateTime? now}) {
    throw UnimplementedError();
  }

  @override
  Future<void> markOpened({
    required int id,
    required DateTime expiryDate,
    required bool moveToFridge,
    DateTime? openedAt,
  }) async {}
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required Size size,
  _RecordingIngredients? repository,
  List<FavoriteItem> favorites = const [],
  List<ShelfLifeRule> rules = const [],
  double systemBottom = 48,
  double keyboard = 0,
}) async {
  final repo = repository ?? _RecordingIngredients();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.viewPadding = FakeViewPadding(top: 24, bottom: systemBottom);
  tester.view.padding = FakeViewPadding(
    top: 24,
    bottom: keyboard > 0 ? 0 : systemBottom,
  );
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ingredientsProvider.overrideWith((ref) => Stream.value(const [])),
        settingsProvider.overrideWith(
          (ref) => Stream.value(NotificationPrefs.defaults),
        ),
        favoritesProvider.overrideWith((ref) => Stream.value(favorites)),
        shelfLifeProvider.overrideWith((ref) => Stream.value(rules)),
        ingredientRepositoryProvider.overrideWithValue(repo),
      ],
      child: const NamgimApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openAdd(WidgetTester tester) async {
  final add = find.widgetWithText(FilledButton, '재료 추가');
  await tester.scrollUntilVisible(
    add,
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(add);
  await tester.pumpAndSettle();
}

Rect _visibleRect(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final keyboard = tester.view.viewInsets.bottom;
  final systemBottom = keyboard > 0 ? 0.0 : tester.view.padding.bottom;
  final limit = size.height - keyboard - systemBottom;
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.left, greaterThanOrEqualTo(-0.1));
  expect(rect.right, lessThanOrEqualTo(size.width + 0.1));
  expect(rect.bottom, lessThanOrEqualTo(limit + 1));
  expect(rect.height, greaterThan(0));
  return rect;
}

void _expectPinnedToSafeBottom(WidgetTester tester, Finder finder) {
  final rect = _visibleRect(tester, finder);
  final size = tester.view.physicalSize / tester.view.devicePixelRatio;
  final keyboard = tester.view.viewInsets.bottom;
  final systemBottom = keyboard > 0 ? 0.0 : tester.view.padding.bottom;
  final limit = size.height - keyboard - systemBottom;
  expect(rect.bottom, greaterThan(limit - 80));
  expect(rect.height, greaterThanOrEqualTo(48));
}

Finder get _saveButton => find.byKey(const Key('add-submit'));

Finder get _form => find.byKey(const Key('add-form'));

Finder get _formScrollable => find.descendant(
  of: _form,
  matching: find.byWidgetPredicate(
    (widget) => widget is Scrollable && widget.axis == Axis.vertical,
  ),
);

void main() {
  testWidgets('save stays visible above the system inset and the keyboard', (
    tester,
  ) async {
    await _pumpApp(tester, size: const Size(390, 640));
    await _openAdd(tester);

    expect(find.text('설정'), findsNothing);
    expect(find.text('재료 추가'), findsOneWidget);
    _expectPinnedToSafeBottom(tester, _saveButton);

    final before = tester.getTopLeft(_saveButton).dy;
    final scroll = tester.state<ScrollableState>(_formScrollable);
    final offset = scroll.position.pixels;
    await tester.drag(_form, const Offset(0, -280));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, greaterThan(offset));
    expect(tester.getTopLeft(_saveButton).dy, before);

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    tester.view.padding = const FakeViewPadding(top: 24);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(_saveButton).dy, lessThan(before));
    _expectPinnedToSafeBottom(tester, _saveButton);
    scroll.position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      80,
      scrollable: _formScrollable,
    );
    expect(tester.getTopLeft(_saveButton).dy, lessThan(before));
    _expectPinnedToSafeBottom(tester, _saveButton);
    _visibleRect(tester, find.byType(TextField));
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();
    expect(find.text('이름을 입력하거나 위 칩을 누르세요'), findsOneWidget);
  });

  testWidgets('long favorite list scrolls behind a fixed save button', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      size: const Size(390, 700),
      favorites: [
        for (var i = 0; i < 16; i++)
          FavoriteItem(
            id: i,
            name: '재료$i',
            defaultStorageLocation: StorageLocation.fridge,
            defaultShelfDays: 4,
          ),
      ],
    );
    await _openAdd(tester);

    final before = tester.getTopLeft(_saveButton).dy;
    await tester.scrollUntilVisible(
      find.byType(TextField),
      200,
      scrollable: _formScrollable,
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(_saveButton).dy, before);
    _expectPinnedToSafeBottom(tester, _saveButton);
    _visibleRect(tester, find.byType(TextField));
  });

  testWidgets('defaults, presets, and validation keep what was typed', (
    tester,
  ) async {
    final repo = _RecordingIngredients();
    await _pumpApp(
      tester,
      size: const Size(390, 844),
      repository: repo,
      rules: const [
        ShelfLifeRule(
          id: 1,
          nameKeyword: '두부',
          storageLocation: StorageLocation.fridge,
          days: 5,
          category: '단백질',
        ),
      ],
    );
    await _openAdd(tester);

    expect(find.text('냉장 기본 7일로 채웠어요'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '+7일'))
          .selected,
      isTrue,
    );

    await tester.tap(find.text('냉동'));
    await tester.pumpAndSettle();
    expect(find.text('냉동 기본 30일로 채웠어요'), findsOneWidget);
    expect(
      find.text(formatMonthDay(addDays(DateTime.now(), 30))),
      findsOneWidget,
    );

    await tester.tap(find.text('냉장'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '두부');
    await tester.pumpAndSettle();
    expect(find.text('두부 · 냉장 5일'), findsOneWidget);
    expect(
      find.text(formatMonthDay(addDays(DateTime.now(), 5))),
      findsOneWidget,
    );

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('+3일'),
      120,
      scrollable: _formScrollable,
    );
    await tester.tap(find.text('+3일'));
    await tester.pumpAndSettle();
    expect(find.text('3일 뒤로 골랐어요'), findsOneWidget);
    expect(
      find.text(formatMonthDay(addDays(DateTime.now(), 3))),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '+3일'))
          .selected,
      isTrue,
    );

    await tester.tap(find.text('냉동'));
    await tester.pumpAndSettle();
    expect(
      find.text(formatMonthDay(addDays(DateTime.now(), 3))),
      findsOneWidget,
    );
    expect(find.text('3일 뒤로 골랐어요'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();
    expect(find.text('이름을 입력하거나 위 칩을 누르세요'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '   ',
    );
    expect(repo.adds, 0);

    await tester.enterText(find.byType(TextField), '양파');
    await tester.pump();
    expect(find.text('이름을 입력하거나 위 칩을 누르세요'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '양파',
    );
    expect(repo.adds, 0);

    await tester.tap(find.text('유통기한'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '양파',
    );
  });

  testWidgets('a second tap while saving does not add twice', (tester) async {
    final gate = Completer<void>();
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    final repo = _RecordingIngredients(gate: gate);
    await _pumpApp(tester, size: const Size(390, 844), repository: repo);
    await _openAdd(tester);

    await tester.enterText(find.byType(TextField), '두부');
    await tester.pump();
    await tester.tap(_saveButton);
    await tester.tap(_saveButton);
    expect(repo.adds, 1);
    expect(repo.lastName, '두부');
    expect(repo.lastQuantity, 1);
    expect(repo.lastLocation, StorageLocation.fridge);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('두부 담았어요'), findsOneWidget);
    expect(repo.adds, 1);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
