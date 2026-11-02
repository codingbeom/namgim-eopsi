import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [NotificationSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Stream<NotificationSettingRow> watchOne() {
    return (select(notificationSettings)..limit(1)).watchSingle();
  }

  Future<NotificationSettingRow> getOne() {
    return (select(notificationSettings)..limit(1)).getSingle();
  }

  Future<void> write(int id, NotificationSettingsCompanion companion) {
    return (update(
      notificationSettings,
    )..where((row) => row.id.equals(id))).write(companion);
  }
}
