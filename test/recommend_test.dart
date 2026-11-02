import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/app/namgim_app.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
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
  tester.view.physicalSize = const Size(390, 900);
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

void main() {
  testWidgets('recommend explains urgency and hides menus you cannot start', (
    tester,
  ) async {
    await _pump(tester, [
      _item(1, '두부', StorageLocation.fridge, 1),
      _item(2, '양파', StorageLocation.pantry, 40),
      _item(3, '굴소스', StorageLocation.pantry, 120),
    ]);

    expect(find.byKey(const Key('home-recipe-reason')), findsOneWidget);
    expect(find.textContaining('두부 내일까지'), findsOneWidget);
    expect(find.textContaining('없는 재료 1개'), findsOneWidget);

    await tester.tap(find.text('추천'));
    await tester.pumpAndSettle();

    expect(find.text('곧 상할 재료를 쓰는 메뉴를 위로 올렸어요.'), findsOneWidget);
    expect(find.text('보관 3개 · 임박 1개'), findsOneWidget);
    expect(find.byKey(const Key('recipe-band-rescue')), findsOneWidget);
    expect(find.byKey(const Key('recipe-band-ready')), findsOneWidget);
    expect(find.text('프렌치토스트'), findsNothing);
    expect(find.text('가진 재료가 없어요'), findsNothing);

    final tofu = find.byKey(const Key('recipe-tofu-jorim'));
    expect(find.byKey(const Key('recipe-reason-tofu-jorim')), findsOneWidget);
    expect(
      find.descendant(of: tofu, matching: find.text('대파 없음')),
      findsOneWidget,
    );
    expect(find.text('두부 내일까지'), findsWidgets);
    expect(
      find.descendant(of: tofu, matching: find.text('가진 재료만 정리')),
      findsOneWidget,
    );
    expect(find.textContaining('도톰하게'), findsNothing);
    await tester.tap(find.descendant(of: tofu, matching: find.text('만드는 법')));
    await tester.pumpAndSettle();
    expect(find.textContaining('도톰하게'), findsOneWidget);

    final recipesList = find.descendant(
      of: find.byKey(const Key('recipes-list')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('recipe-onion-stir')),
      300,
      scrollable: recipesList,
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('recipe-onion-stir')),
        matching: find.text('만들고 재료 정리'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('recipes-add-missing')),
      300,
      scrollable: recipesList,
    );
    expect(find.byKey(const Key('recipes-add-missing')), findsOneWidget);
  });

  testWidgets('an empty fridge offers a way to add ingredients', (
    tester,
  ) async {
    await _pump(tester, const []);

    await tester.tap(find.text('추천'));
    await tester.pumpAndSettle();

    expect(find.text('냉장고가 비어 있어요'), findsOneWidget);
    expect(find.textContaining('재료를 담으면'), findsOneWidget);
    expect(find.text('두부조림'), findsNothing);

    await tester.tap(find.byKey(const Key('recipes-add')));
    await tester.pumpAndSettle();
    expect(find.text('자주 사는 것'), findsOneWidget);
  });

  testWidgets('ingredients with no sample match explain the gap', (
    tester,
  ) async {
    await _pump(tester, [_item(1, '와사비', StorageLocation.fridge, 5)]);

    await tester.tap(find.text('추천'));
    await tester.pumpAndSettle();

    expect(find.text('겹치는 메뉴가 없어요'), findsOneWidget);
    expect(find.textContaining('두부, 계란, 대파'), findsOneWidget);
    expect(find.text('계란볶음밥'), findsNothing);
  });

  testWidgets('an empty name shows a field error instead of adding', (
    tester,
  ) async {
    await _pump(tester, const []);

    await tester.scrollUntilVisible(
      find.text('재료 추가'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('재료 추가'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-submit')));
    await tester.pumpAndSettle();

    expect(find.text('이름을 입력하거나 위 칩을 누르세요'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byKey(const Key('add-submit')), findsOneWidget);
  });
}
