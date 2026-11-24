import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/data/db/app_database.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/home_widget_snapshot.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/services/expiry_refresh.dart';
import 'package:namgim_eopsi/services/home_widget_actions.dart';
import 'package:namgim_eopsi/services/home_widget_callback.dart';
import 'package:namgim_eopsi/services/home_widget_publish.dart';

IngredientItem _item({
  required int id,
  required String name,
  required int days,
  required DateTime now,
  StorageLocation location = StorageLocation.fridge,
  IngredientStatus status = IngredientStatus.stored,
}) {
  return IngredientItem(
    id: id,
    name: name,
    quantity: 1,
    storageLocation: location,
    expiryDate: addDays(now, days),
    isOpened: false,
    openedAt: null,
    status: status,
    createdAt: now,
  );
}

FavoriteItem _favorite(int id, String name) {
  return FavoriteItem(
    id: id,
    name: name,
    defaultStorageLocation: StorageLocation.fridge,
    defaultShelfDays: 7,
  );
}

void main() {
  final now = DateTime(2026, 11, 24);

  test('d-day labels and tones', () {
    expect(widgetDdayLabel(-2), 'D+2');
    expect(widgetDdayLabel(0), 'D-Day');
    expect(widgetDdayLabel(3), 'D-3');
    expect(widgetDdayTone(-1), 'overdue');
    expect(widgetDdayTone(0), 'today');
    expect(widgetDdayTone(3), 'soon');
  });

  test('snapshot sorts imminent food and leaves an empty kitchen quiet', () {
    final prefs = NotificationPrefs.defaults;
    final snapshot = buildHomeWidgetSnapshot(
      items: [
        _item(
          id: 1,
          name: '양파',
          days: 10,
          now: now,
          location: StorageLocation.pantry,
        ),
        _item(
          id: 2,
          name: '식빵',
          days: 2,
          now: now,
          location: StorageLocation.pantry,
        ),
        _item(id: 3, name: '두부', days: 1, now: now),
        _item(id: 4, name: '우유', days: 0, now: now),
        _item(id: 5, name: '대파', days: -2, now: now),
        _item(id: 6, name: '계란', days: 16, now: now),
        _item(
          id: 7,
          name: '버린두부',
          days: 0,
          now: now,
          status: IngredientStatus.eaten,
        ),
        _item(
          id: 8,
          name: '냉동만두',
          days: 4,
          now: now,
          location: StorageLocation.freezer,
        ),
        _item(id: 9, name: '가지', days: 1, now: now),
      ],
      favorites: [
        _favorite(5, '식빵'),
        _favorite(1, '계란'),
        _favorite(4, '대파'),
        _favorite(2, '우유'),
        _favorite(3, '두부'),
      ],
      prefs: prefs,
      now: now,
    );

    expect(snapshot.summary, '임박 5개');
    expect(snapshot.detail, '보관 8개 · 오늘 확인할 재료');
    expect(snapshot.imminent.map((item) => item.name), ['대파', '우유', '가지']);
    expect(snapshot.imminent.map((item) => item.badge), [
      'D+2',
      'D-Day',
      'D-1',
    ]);
    expect(snapshot.imminent.map((item) => item.tone), [
      'overdue',
      'today',
      'soon',
    ]);
    expect(snapshot.favorites.map((item) => item.name), [
      '계란',
      '우유',
      '두부',
      '대파',
    ]);

    final payload = snapshot.toPayload();
    expect(payload['imminent_count'], '5');
    expect(payload['item1_name'], '대파');
    expect(payload['item1_badge'], 'D+2');
    expect(payload['item3_tone'], 'soon');
    expect(payload['favorite_count'], '4');
    expect(payload['fav1_id'], '1');
    expect(payload['fav4_name'], '대파');
    expect(payload['favorites_label'], '즐겨찾기');
    expect(payload['favorites_hint'], '');
  });

  test('empty kitchen and a wider pantry window change the payload', () {
    final empty = buildHomeWidgetSnapshot(
      items: const [],
      favorites: const [],
      prefs: NotificationPrefs.defaults,
      now: now,
    );
    expect(empty.summary, '임박한 재료 없음');
    expect(empty.detail, '냉장고가 비어 있어요');
    expect(empty.isEmpty, isTrue);
    expect(empty.favoritesLabel, '즐겨찾기가 없어요');
    final emptyPayload = empty.toPayload();
    expect(emptyPayload['item1_name'], '');
    expect(emptyPayload['item3_badge'], '');
    expect(emptyPayload['fav1_id'], '');
    expect(emptyPayload['favorite_count'], '0');
    expect(emptyPayload['favorites_hint'], '앱에서 담아 두면 여기서 바로 추가해요');

    final quiet = buildHomeWidgetSnapshot(
      items: [
        _item(
          id: 1,
          name: '양파',
          days: 10,
          now: now,
          location: StorageLocation.pantry,
        ),
      ],
      favorites: [_favorite(1, '양파')],
      prefs: NotificationPrefs.defaults,
      now: now,
    );
    expect(quiet.imminentCount, 0);
    expect(quiet.detail, '오늘은 바로 챙길 재료가 없어요');

    final wider = buildHomeWidgetSnapshot(
      items: [
        _item(
          id: 1,
          name: '양파',
          days: 10,
          now: now,
          location: StorageLocation.pantry,
        ),
      ],
      favorites: const [],
      prefs: NotificationPrefs.defaults.copyWith(pantryLateDays: 14),
      now: now,
    );
    expect(wider.imminentCount, 1);
    expect(wider.imminent.single.badge, 'D-10');
    expect(wider.summary, '임박 1개');
  });

  test('widget uris open the app or name a favorite', () {
    expect(widgetLaunchLocation(Uri.parse('namgim://add')), '/add');
    expect(widgetLaunchLocation(Uri.parse('namgim://home')), '/home');
    expect(widgetLaunchLocation(Uri.parse('namgim://favorite?id=3')), isNull);
    expect(favoriteIdFromWidgetUri(Uri.parse('namgim://favorite?id=12')), 12);
    expect(
      favoriteIdFromWidgetUri(Uri.parse('namgim://favorite?id=nope')),
      isNull,
    );
    expect(favoriteIdFromWidgetUri(Uri.parse('namgim://add')), isNull);
    expect(favoriteIdFromWidgetUri(null), isNull);
  });

  test('quick-add writes the favorite and refreshes the kitchen', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final before = await loadKitchen(database);
    final beforeCount = before.items.length;
    var notified = 0;
    final skipped = await handleHomeWidgetFavoriteUri(
      database: database,
      uri: Uri.parse('namgim://home'),
      onAdded: (_) async => notified += 1,
    );
    expect(skipped.added, isFalse);
    expect(notified, 0);

    final missing = await handleHomeWidgetFavoriteUri(
      database: database,
      uri: Uri.parse('namgim://favorite?id=999999'),
      now: now,
    );
    expect(missing.added, isFalse);
    expect((await loadKitchen(database)).items, hasLength(beforeCount));

    final chicken = before.favorites.firstWhere((item) => item.name == '닭가슴살');
    final clock = DateTime.now();
    Kitchen? refreshed;
    final added = await handleHomeWidgetFavoriteUri(
      database: database,
      uri: Uri.parse('namgim://favorite?id=${chicken.id}'),
      now: clock,
      onAdded: (kitchen) async {
        refreshed = kitchen;
        await syncExpiryNotifications(
          items: kitchen.items,
          prefs: kitchen.prefs,
        );
      },
    );
    expect(added.added, isTrue);
    expect(added.ingredientId, isNotNull);
    final row = refreshed!.items.firstWhere(
      (item) => item.id == added.ingredientId,
    );
    expect(row.name, '닭가슴살');
    expect(row.storageLocation, StorageLocation.fridge);
    expect(row.status, IngredientStatus.stored);
    expect(daysUntil(row.expiryDate, clock), 2);

    final snapshot = buildHomeWidgetSnapshot(
      items: refreshed!.items,
      favorites: refreshed!.favorites,
      prefs: refreshed!.prefs,
      now: clock,
    );
    final shown = snapshot.imminent.firstWhere((item) => item.name == '닭가슴살');
    expect(shown.badge, 'D-2');
    expect(shown.tone, 'soon');
    expect(snapshot.favorites.map((item) => item.name), [
      '계란',
      '우유',
      '두부',
      '대파',
    ]);
  });

  test('widget channel calls stay quiet when android is unavailable', () async {
    await registerHomeWidgetCallback();
    await publishHomeWidget(
      items: const [],
      favorites: const [],
      prefs: NotificationPrefs.defaults,
      now: now,
    );
  });
}
