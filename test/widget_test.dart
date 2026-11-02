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

void main() {
  testWidgets('home shows the slogan and a seeded ingredient', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final items = [
      _item(1, '두부', StorageLocation.fridge, 1),
      _item(2, '우유', StorageLocation.fridge, 2),
      _item(3, '대파', StorageLocation.fridge, 3),
      _item(4, '식빵', StorageLocation.pantry, 2),
      _item(5, '계란', StorageLocation.fridge, 16),
      _item(6, '양파', StorageLocation.pantry, 25),
      _item(7, '굴소스', StorageLocation.pantry, 120),
      _item(8, '냉동만두', StorageLocation.freezer, 40),
    ];

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

    expect(find.text('남김없이'), findsWidgets);
    expect(find.text('입력은 간편하게, 식재료는 남김없이'), findsOneWidget);
    expect(find.text('두부'), findsWidgets);
    expect(find.text('보관 8개 중 4개'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('home-attention-count'))).data,
      '4',
    );
    expect(find.byType(AppBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byKey(const Key('app-title')),
      ),
      findsOneWidget,
    );

    final title = find.byKey(const Key('app-title'));
    final titleBefore = tester.getTopLeft(title).dy;
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    final scrolled = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrolled.position.pixels, greaterThan(40));
    expect(tester.getTopLeft(title).dy, titleBefore);
    expect(tester.getTopLeft(title).dy, inInclusiveRange(0, 80));
    expect(
      find.descendant(of: find.byType(Scrollable), matching: title),
      findsNothing,
    );

    await tester.scrollUntilVisible(
      find.text('재료 추가'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('재료 추가'), findsOneWidget);
    expect(tester.getTopLeft(title).dy, titleBefore);

    await tester.tap(find.text('식재료'));
    await tester.pumpAndSettle();
    expect(find.text('개봉'), findsWidgets);
  });

  testWidgets('empty home keeps the title and explains the quiet kitchen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientsProvider.overrideWith(
            (ref) => Stream.value(const <IngredientItem>[]),
          ),
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

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byKey(const Key('app-title')),
      ),
      findsOneWidget,
    );
    expect(find.text('아직 담긴 재료가 없어요'), findsOneWidget);
    expect(find.text('오늘은 여유로워요'), findsOneWidget);
    expect(find.text('아직 맞출 메뉴가 없어요'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('home-attention-count'))).data,
      '0',
    );
  });
}
