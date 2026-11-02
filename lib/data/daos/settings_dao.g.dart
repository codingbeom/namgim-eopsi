// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $NotificationSettingsTable get notificationSettings =>
      attachedDatabase.notificationSettings;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$NotificationSettingsTableTableManager get notificationSettings =>
      $$NotificationSettingsTableTableManager(
        _db.attachedDatabase,
        _db.notificationSettings,
      );
}
