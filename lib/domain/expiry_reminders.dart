import 'dates.dart';
import 'enums.dart';
import 'models.dart';
import 'notification_prefs.dart';

/// Which reminder of an ingredient this slot is.
///
/// The index is part of the notification id, so append new values at the end.
enum ReminderSlot { lead, sameDay, pantryEarly, pantryLate }

/// One future local notification for a single stored ingredient.
///
/// Each reminder names one ingredient. The payload carries that id so 먹음 and
/// 버림 update that row and no other.
class ExpiryReminder {
  const ExpiryReminder({
    required this.ingredientId,
    required this.name,
    required this.location,
    required this.expiryDate,
    required this.fireAt,
    required this.daysBefore,
    required this.slot,
    required this.opened,
  });

  final int ingredientId;
  final String name;
  final StorageLocation location;
  final DateTime expiryDate;
  final DateTime fireAt;
  final int daysBefore;
  final ReminderSlot slot;
  final bool opened;

  int get notificationId => notificationIdFor(ingredientId, slot);

  String get title => expiryReminderTitle(name, daysBefore);

  String get body => expiryReminderBody(
    location: location,
    expiry: expiryDate,
    opened: opened,
  );

  String get groupKey => expiryGroupKey(fireAt, location);
}

const maxExpiryReminders = 50;

int notificationIdFor(int ingredientId, ReminderSlot slot) {
  final id = ingredientId * 10 + slot.index + 1;
  if (id <= 0) return 1;
  if (id > 0x7fffffff) return id & 0x7fffffff;
  return id;
}

String expiryReminderTitle(String name, int daysBefore) {
  if (daysBefore <= 0) return '$name, 오늘까지예요';
  if (daysBefore == 1) return '$name, 내일까지예요';
  return '$name, $daysBefore일 남았어요';
}

String expiryReminderBody({
  required StorageLocation location,
  required DateTime expiry,
  required bool opened,
}) {
  final when = '${location.place} · ${formatExpiryDay(expiry)}까지';
  return opened ? '개봉함 · $when' : when;
}

String formatExpiryDay(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final local = dateOnly(date);
  return '${local.month}월 ${local.day}일 (${weekdays[local.weekday - 1]})';
}

String expiryGroupKey(DateTime fireAt, StorageLocation location) {
  final day = dateOnly(fireAt);
  final month = day.month.toString().padLeft(2, '0');
  final date = day.day.toString().padLeft(2, '0');
  return 'expiry-${day.year}$month$date-${location.name}';
}

DateTime reminderFireAt({
  required DateTime expiry,
  required int daysBefore,
  required int hour,
  required int minute,
}) {
  final day = addDays(expiry, -daysBefore);
  return DateTime(day.year, day.month, day.day, hour, minute);
}

/// Lead days and the same-day toggle, per storage location.
///
/// A lead of 0 does not add a second reminder. The same-day toggle is the
/// expiry morning. Pantry uses the two lead days only, and duplicate days
/// collapse into one reminder.
List<({int daysBefore, ReminderSlot slot})> reminderOffsets(
  StorageLocation location,
  NotificationPrefs prefs,
) {
  return switch (location) {
    StorageLocation.fridge => _coldOffsets(
      leadDays: prefs.fridgeLeadDays,
      onTheDay: prefs.fridgeOnTheDay,
    ),
    StorageLocation.freezer => _coldOffsets(
      leadDays: prefs.freezerLeadDays,
      onTheDay: prefs.freezerOnTheDay,
    ),
    StorageLocation.pantry => _pantryOffsets(prefs),
  };
}

List<({int daysBefore, ReminderSlot slot})> _coldOffsets({
  required int leadDays,
  required bool onTheDay,
}) {
  final offsets = <({int daysBefore, ReminderSlot slot})>[];
  final seen = <int>{};
  if (leadDays > 0 && seen.add(leadDays)) {
    offsets.add((daysBefore: leadDays, slot: ReminderSlot.lead));
  }
  if (onTheDay && seen.add(0)) {
    offsets.add((daysBefore: 0, slot: ReminderSlot.sameDay));
  }
  return offsets;
}

List<({int daysBefore, ReminderSlot slot})> _pantryOffsets(
  NotificationPrefs prefs,
) {
  final offsets = <({int daysBefore, ReminderSlot slot})>[];
  final seen = <int>{};
  void add(int days, ReminderSlot slot) {
    if (days <= 0 || !seen.add(days)) return;
    offsets.add((daysBefore: days, slot: slot));
  }

  add(prefs.pantryEarlyDays, ReminderSlot.pantryEarly);
  add(prefs.pantryLateDays, ReminderSlot.pantryLate);
  return offsets;
}

/// Stored ingredients only. Eaten and discarded rows are left out.
/// Opened food stays, using its current expiry.
///
/// [now] is a local wall clock. A reminder at or before [now] is not scheduled.
List<ExpiryReminder> planExpiryReminders({
  required List<IngredientItem> items,
  required NotificationPrefs prefs,
  required DateTime now,
  int limit = maxExpiryReminders,
}) {
  final reminders = <ExpiryReminder>[];
  for (final item in items) {
    if (item.status != IngredientStatus.stored) continue;
    for (final offset in reminderOffsets(item.storageLocation, prefs)) {
      final fireAt = reminderFireAt(
        expiry: item.expiryDate,
        daysBefore: offset.daysBefore,
        hour: prefs.hour,
        minute: prefs.minute,
      );
      if (!fireAt.isAfter(now)) continue;
      reminders.add(
        ExpiryReminder(
          ingredientId: item.id,
          name: item.name,
          location: item.storageLocation,
          expiryDate: dateOnly(item.expiryDate),
          fireAt: fireAt,
          daysBefore: offset.daysBefore,
          slot: offset.slot,
          opened: item.isOpened,
        ),
      );
    }
  }
  reminders.sort((a, b) {
    final byTime = a.fireAt.compareTo(b.fireAt);
    if (byTime != 0) return byTime;
    final byName = a.name.compareTo(b.name);
    if (byName != 0) return byName;
    return a.ingredientId.compareTo(b.ingredientId);
  });
  if (reminders.length <= limit) return reminders;
  return reminders.sublist(0, limit);
}
