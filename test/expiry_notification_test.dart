import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/data/db/app_database.dart';
import 'package:namgim_eopsi/data/repositories/ingredient_repository.dart';
import 'package:namgim_eopsi/data/repositories/shelf_life_repository.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/expiry_reminders.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/services/notification_actions.dart';
import 'package:namgim_eopsi/services/notification_clock.dart';
import 'package:namgim_eopsi/services/notification_schedule_mode.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

IngredientItem item({
  required int id,
  required String name,
  required StorageLocation location,
  required DateTime expiry,
  IngredientStatus status = IngredientStatus.stored,
  bool opened = false,
}) {
  return IngredientItem(
    id: id,
    name: name,
    quantity: 1,
    storageLocation: location,
    expiryDate: expiry,
    isOpened: opened,
    openedAt: opened ? expiry : null,
    status: status,
    createdAt: DateTime(2026, 11, 1),
  );
}

void main() {
  final now = DateTime(2026, 11, 24, 7, 30);
  final prefs = NotificationPrefs.defaults;

  List<ExpiryReminder> plan(
    List<IngredientItem> items, {
    NotificationPrefs? settings,
    DateTime? at,
    int? limit,
  }) {
    return planExpiryReminders(
      items: items,
      prefs: settings ?? prefs,
      now: at ?? now,
      limit: limit ?? maxExpiryReminders,
    );
  }

  test('fridge and freezer use their own lead days and same-day toggle', () {
    final reminders = plan([
      item(
        id: 1,
        name: '두부',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 27),
      ),
      item(
        id: 2,
        name: '만두',
        location: StorageLocation.freezer,
        expiry: DateTime(2026, 11, 30),
      ),
    ], settings: prefs.copyWith(freezerLeadDays: 2, freezerOnTheDay: false));

    final tofu = reminders.where((reminder) => reminder.ingredientId == 1);
    expect(tofu.map((reminder) => reminder.daysBefore), [3, 0]);
    expect(tofu.map((reminder) => reminder.fireAt), [
      DateTime(2026, 11, 24, 8),
      DateTime(2026, 11, 27, 8),
    ]);
    expect(tofu.first.title, '두부, 3일 남았어요');
    expect(tofu.last.title, '두부, 오늘까지예요');

    final dumplings = reminders.where((reminder) => reminder.ingredientId == 2);
    expect(dumplings.map((reminder) => reminder.daysBefore), [2]);
    expect(dumplings.single.fireAt, DateTime(2026, 11, 28, 8));
    expect(dumplings.single.title, '만두, 2일 남았어요');
  });

  test('pantry schedules both leads and skips a duplicate day', () {
    final sauce = item(
      id: 4,
      name: '굴소스',
      location: StorageLocation.pantry,
      expiry: DateTime(2026, 12, 22),
    );
    final reminders = plan([sauce]);
    expect(reminders.map((reminder) => reminder.daysBefore), [14, 7]);
    expect(reminders.map((reminder) => reminder.fireAt), [
      DateTime(2026, 12, 8, 8),
      DateTime(2026, 12, 15, 8),
    ]);
    expect(reminders.first.body, contains('찬장'));

    final collapsed = plan([
      sauce,
    ], settings: prefs.copyWith(pantryEarlyDays: 7, pantryLateDays: 7));
    expect(collapsed, hasLength(1));
    expect(collapsed.single.daysBefore, 7);
  });

  test('drops past times, eaten and discarded rows, and keeps opened food', () {
    final at = DateTime(2026, 11, 24, 9);
    final reminders = plan([
      item(
        id: 1,
        name: '두부',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 25),
      ),
      item(
        id: 2,
        name: '우유',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 24),
      ),
      item(
        id: 3,
        name: '먹은 두부',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 24),
        status: IngredientStatus.eaten,
      ),
      item(
        id: 5,
        name: '버린 파',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 24),
        status: IngredientStatus.discarded,
      ),
      item(
        id: 6,
        name: '연 우유',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 28),
        opened: true,
      ),
    ], at: at);

    // 두부: lead on the 22nd is past, same-day on the 25th remains.
    // 연 우유: lead on the 25th and same-day on the 28th. 우유 today is past.
    expect(reminders.map((reminder) => reminder.ingredientId), [1, 6, 6]);
    expect(reminders.map((reminder) => reminder.daysBefore), [0, 3, 0]);
    expect(reminders.last.title, '연 우유, 오늘까지예요');
    expect(reminders.where((reminder) => reminder.opened).length, 2);
    expect(reminders.last.body, startsWith('개봉함'));
    expect(reminders.every((reminder) => reminder.fireAt.isAfter(at)), isTrue);
  });

  test('same-day morning is kept only until that minute', () {
    final milk = item(
      id: 8,
      name: '우유',
      location: StorageLocation.fridge,
      expiry: DateTime(2026, 11, 24),
    );
    final before = plan(
      [milk],
      at: DateTime(2026, 11, 24, 7, 59),
      settings: prefs.copyWith(fridgeLeadDays: 0, fridgeOnTheDay: true),
    );
    expect(before.single.fireAt, DateTime(2026, 11, 24, 8));
    expect(before.single.title, '우유, 오늘까지예요');

    final onTheMinute = plan(
      [milk],
      at: DateTime(2026, 11, 24, 8),
      settings: prefs.copyWith(fridgeLeadDays: 0, fridgeOnTheDay: true),
    );
    expect(onTheMinute, isEmpty);

    final leadOnly = plan(
      [milk],
      at: DateTime(2026, 11, 20, 8),
      settings: prefs.copyWith(hour: 21, minute: 15, fridgeOnTheDay: false),
    );
    expect(leadOnly.single.fireAt, DateTime(2026, 11, 21, 21, 15));
  });

  test('ids stay unique and the cap keeps the soonest reminders', () {
    final reminders = plan([
      item(
        id: 1,
        name: '두부',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 28),
      ),
      item(
        id: 2,
        name: '계란',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 12, 20),
      ),
    ]);
    final ids = reminders.map((reminder) => reminder.notificationId).toSet();
    expect(ids, hasLength(reminders.length));
    expect(
      notificationIdFor(1, ReminderSlot.lead),
      notificationIdFor(1, ReminderSlot.lead),
    );
    expect(
      notificationIdFor(1, ReminderSlot.lead),
      isNot(notificationIdFor(1, ReminderSlot.sameDay)),
    );

    final capped = plan([
      item(
        id: 1,
        name: '나중',
        location: StorageLocation.pantry,
        expiry: DateTime(2027, 6, 1),
      ),
      item(
        id: 2,
        name: '먼저',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 27),
      ),
    ], limit: 1);
    expect(capped.single.name, '먼저');
    expect(capped.single.groupKey, 'expiry-20261124-fridge');
  });

  test('a far now schedules nothing, so the clock argument is honored', () {
    final reminders = plan([
      item(
        id: 1,
        name: '두부',
        location: StorageLocation.fridge,
        expiry: DateTime(2026, 11, 27),
      ),
    ], at: DateTime(2099, 1, 1));
    expect(reminders, isEmpty);
  });

  test('payload ids round-trip and actions stay unambiguous', () {
    expect(decodeExpiryIngredientIds(encodeExpiryPayload([3, 8])), [3, 8]);
    expect(decodeExpiryIngredientIds('not-json'), isEmpty);
    expect(decodeExpiryIngredientIds('{"ids":["두부"]}'), isEmpty);

    final eaten = planNotificationAction(
      actionId: notificationActionEaten,
      payload: encodeExpiryPayload([3]),
    );
    expect(eaten.kind, NotificationActionKind.markEaten);
    expect(eaten.ingredientIds, [3]);

    final discarded = planNotificationAction(
      actionId: notificationActionDiscarded,
      payload: encodeExpiryPayload([3, 8]),
    );
    expect(discarded.kind, NotificationActionKind.markDiscarded);
    expect(discarded.ingredientIds, [3, 8]);

    expect(
      planNotificationAction(
        actionId: notificationActionEaten,
        payload: encodeExpiryPayload(const []),
      ).kind,
      NotificationActionKind.ignore,
    );
    expect(
      planNotificationAction(
        actionId: null,
        payload: encodeExpiryPayload([3]),
      ).kind,
      NotificationActionKind.openRecipes,
    );
    expect(
      planNotificationAction(
        actionId: notificationActionRecipes,
        payload: null,
      ).kind,
      NotificationActionKind.openRecipes,
    );
  });

  test('먹음 and 버림 update only the payload ids', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = DriftIngredientRepository(
      database,
      DriftShelfLifeRepository(database),
    );
    addTearDown(database.close);

    final tofu = await repository.add(
      name: '두부',
      quantity: 1,
      location: StorageLocation.fridge,
      expiryDate: addDays(DateTime(2026, 11, 24), 3),
    );
    final milk = await repository.add(
      name: '우유',
      quantity: 1,
      location: StorageLocation.fridge,
      expiryDate: addDays(DateTime(2026, 11, 24), 5),
    );
    final sauce = await repository.add(
      name: '굴소스',
      quantity: 1,
      location: StorageLocation.pantry,
      expiryDate: addDays(DateTime(2026, 11, 24), 40),
    );

    await applyNotificationAction(
      repository: repository,
      plan: planNotificationAction(
        actionId: notificationActionEaten,
        payload: encodeExpiryPayload([tofu]),
      ),
    );
    await applyNotificationAction(
      repository: repository,
      plan: planNotificationAction(
        actionId: notificationActionDiscarded,
        payload: encodeExpiryPayload([milk, sauce]),
      ),
    );
    await applyNotificationAction(
      repository: repository,
      plan: planNotificationAction(
        actionId: notificationActionRecipes,
        payload: encodeExpiryPayload([tofu]),
      ),
    );
    await applyNotificationAction(
      repository: repository,
      plan: planNotificationAction(
        actionId: notificationActionEaten,
        payload: encodeExpiryPayload([9999]),
      ),
    );

    final stored = await repository.watchAll().first;
    expect(
      stored.firstWhere((item) => item.id == tofu).status,
      IngredientStatus.eaten,
    );
    expect(
      stored.firstWhere((item) => item.id == milk).status,
      IngredientStatus.discarded,
    );
    expect(
      stored.firstWhere((item) => item.id == sauce).status,
      IngredientStatus.discarded,
    );

    final reminders = planExpiryReminders(
      items: stored,
      prefs: prefs,
      now: DateTime(2026, 11, 24, 7),
    );
    expect(
      reminders.where((reminder) => reminder.ingredientId == tofu),
      isEmpty,
    );
  });

  test('Seoul wall-clock 08:00 stays on that morning', () {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    final zoned = zonedWallClock(DateTime(2026, 11, 27, 8));
    expect(zoned.year, 2026);
    expect(zoned.month, 11);
    expect(zoned.day, 27);
    expect(zoned.hour, 8);
    expect(zoned.minute, 0);
    expect(zoned.timeZoneOffset, const Duration(hours: 9));
    expect(zoned.toUtc(), DateTime.utc(2026, 11, 26, 23));
  });

  test('exact alarms are used only when the permission is granted', () {
    expect(
      scheduleModeFor(exactGranted: true),
      AndroidScheduleMode.exactAllowWhileIdle,
    );
    expect(
      scheduleModeFor(exactGranted: false),
      AndroidScheduleMode.inexactAllowWhileIdle,
    );
    expect(fallbackTimeZoneName(const Duration(hours: 9)), 'Etc/GMT-9');
    expect(fallbackTimeZoneName(const Duration(hours: -4)), 'Etc/GMT+4');
    expect(fallbackTimeZoneName(Duration.zero), 'Etc/GMT');
    expect(fallbackTimeZoneName(const Duration(hours: 5, minutes: 30)), 'UTC');
  });
}
