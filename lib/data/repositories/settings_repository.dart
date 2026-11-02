import 'package:drift/drift.dart';

import '../../domain/notification_prefs.dart';
import '../db/app_database.dart';
import 'mappers.dart';

abstract class SettingsRepository {
  Stream<NotificationPrefs> watch();
  Future<void> save(NotificationPrefs prefs);
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<NotificationPrefs> watch() {
    return _db.settingsDao.watchOne().map(mapPrefs);
  }

  @override
  Future<void> save(NotificationPrefs prefs) async {
    final current = await _db.settingsDao.getOne();
    await _db.settingsDao.write(
      current.id,
      NotificationSettingsCompanion(
        notifyHour: Value(prefs.hour),
        notifyMinute: Value(prefs.minute),
        fridgeLeadDays: Value(prefs.fridgeLeadDays),
        fridgeOnTheDay: Value(prefs.fridgeOnTheDay),
        freezerLeadDays: Value(prefs.freezerLeadDays),
        freezerOnTheDay: Value(prefs.freezerOnTheDay),
        pantryEarlyDays: Value(prefs.pantryEarlyDays),
        pantryLateDays: Value(prefs.pantryLateDays),
      ),
    );
  }
}
