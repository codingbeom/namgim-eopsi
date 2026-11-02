import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/app/namgim_app.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/features/recipes/recipe_catalog_screen.dart';
import 'package:namgim_eopsi/features/recipes/recipes_screen.dart';
import 'package:namgim_eopsi/providers/providers.dart';

IngredientItem _item(
  int id,
  String name,
  StorageLocation location,
  int daysFromToday,
) {
  final now = DateTime.now();
  return IngredientItem(
    id: id,
    name: name,
    quantity: 1,
    storageLocation: location,
    expiryDate: addDays(now, daysFromToday),
    isOpened: false,
    openedAt: null,
    status: IngredientStatus.stored,
    createdAt: now,
  );
}

Future<void> _pump(WidgetTester tester, List<IngredientItem> items) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ingredientsProvider.overrideWith((ref) => Stream.value(items)),
        settingsProvider.overrideWith(
          (ref) => Stream.value(NotificationPrefs.defaults),
        ),
        favoritesProvider.overrideWith(
          (ref) => Stream.value(const <FavoriteItem>[]),
        ),
        shelfLifeProvider.overrideWith(
          (ref) => Stream.value(const <ShelfLifeRule>[]),
        ),
      ],
      child: const NamgimApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _in(Type screen, String text) {
  return find.descendant(of: find.byType(screen), matching: find.text(text));
}

Future<void> _scrollCatalog(WidgetTester tester, Finder target) {
  final list = find.descendant(
    of: find.byType(RecipeCatalogScreen),
    matching: find.byType(ListView),
  );
  return tester.scrollUntilVisible(
    target,
    400,
    scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
  );
}

void _expectSampleCount(WidgetTester tester) {
  final count = tester
      .widget<Text>(find.byKey(const Key('recipe-result-count')))
      .data!;
  expect(count, startsWith('샘플 '));
  expect(
    int.parse(count.replaceAll(RegExp(r'\D'), '')),
    greaterThanOrEqualTo(30),
  );
}

void main() {
  final stocked = [
    _item(1, '두부', StorageLocation.fridge, 1),
    _item(2, '우유', StorageLocation.fridge, 2),
    _item(3, '대파', StorageLocation.fridge, 3),
    _item(4, '식빵', StorageLocation.pantry, 2),
    _item(5, '계란', StorageLocation.fridge, 16),
    _item(6, '양파', StorageLocation.pantry, 25),
    _item(7, '굴소스', StorageLocation.pantry, 120),
    _item(8, '냉동만두', StorageLocation.freezer, 40),
  ];

  testWidgets('recipe tab browses the full catalog and an empty search', (
    tester,
  ) async {
    await _pump(tester, stocked);

    await tester.tap(find.text('레시피'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, '레시피'), findsOneWidget);
    expect(
      _in(RecipeCatalogScreen, '냉장고와 상관없이, 샘플 메뉴를 전부 둘러봐요.'),
      findsOneWidget,
    );
    _expectSampleCount(tester);
    expect(_in(RecipeCatalogScreen, '계란볶음밥'), findsOneWidget);

    await _scrollCatalog(tester, _in(RecipeCatalogScreen, '미역국'));
    expect(_in(RecipeCatalogScreen, '없는 재료 3개 · 미역, 소고기, 마늘'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('recipe-search')), '미역');
    await tester.pumpAndSettle();

    expect(_in(RecipeCatalogScreen, '미역국'), findsOneWidget);
    expect(_in(RecipeCatalogScreen, '두부조림'), findsNothing);
    expect(_in(RecipeCatalogScreen, '1개'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('recipe-search')), '두부조림');
    await tester.pumpAndSettle();
    expect(_in(RecipeCatalogScreen, '재료가 다 있어요'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('recipe-search')), 'zzzz없는메뉴');
    await tester.pumpAndSettle();
    expect(_in(RecipeCatalogScreen, '찾는 메뉴가 없어요'), findsOneWidget);
    expect(_in(RecipeCatalogScreen, '미역국'), findsNothing);

    await tester.tap(find.byKey(const Key('recipe-search-clear')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recipe-category-soup')));
    await tester.pumpAndSettle();

    expect(_in(RecipeCatalogScreen, '대파계란국'), findsOneWidget);
    expect(_in(RecipeCatalogScreen, '두부조림'), findsNothing);
    expect(_in(RecipeCatalogScreen, '프렌치토스트'), findsNothing);
    await _scrollCatalog(tester, _in(RecipeCatalogScreen, '미역국'));
    expect(_in(RecipeCatalogScreen, '미역국'), findsOneWidget);
  });

  testWidgets('recommend tab keeps urgent matches and hides zero overlap', (
    tester,
  ) async {
    await _pump(tester, stocked);

    await tester.tap(find.text('추천'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, '추천'), findsOneWidget);
    expect(find.byKey(const Key('recipe-band-rescue')), findsOneWidget);
    expect(find.text('두부조림'), findsOneWidget);
    expect(find.text('미역국'), findsNothing);
    expect(find.text('고등어구이'), findsNothing);
    expect(find.text('주먹밥'), findsNothing);
  });


  testWidgets('empty fridge still opens the recipe catalog', (tester) async {
    await _pump(tester, const []);

    await tester.tap(find.text('추천'));
    await tester.pumpAndSettle();
    expect(find.text('냉장고가 비어 있어요'), findsOneWidget);

    await tester.tap(find.byKey(const Key('recipes-open-catalog')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '레시피'), findsOneWidget);
    _expectSampleCount(tester);

    await tester.enterText(find.byKey(const Key('recipe-search')), '두부조림');
    await tester.pumpAndSettle();
    expect(_in(RecipeCatalogScreen, '없는 재료 3개 · 두부, 대파, 굴소스'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('recipe-search')), '미역');
    await tester.pumpAndSettle();
    expect(_in(RecipeCatalogScreen, '미역국'), findsOneWidget);
  });
}
