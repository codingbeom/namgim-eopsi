import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/app/namgim_app.dart';
import 'package:namgim_eopsi/data/repositories/settings_repository.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/providers/providers.dart';

class _MemorySettings implements SettingsRepository {
  _MemorySettings(this.prefs);

  NotificationPrefs prefs;
  final _updates = StreamController<NotificationPrefs>.broadcast();

  @override
  Stream<NotificationPrefs> watch() async* {
    yield prefs;
    yield* _updates.stream;
  }

  @override
  Future<void> save(NotificationPrefs next) async {
    prefs = next;
    _updates.add(next);
  }
}

void main() {
  testWidgets('settings explains live notifications and can send a test', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final settings = _MemorySettings(NotificationPrefs.defaults);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientsProvider.overrideWith(
            (ref) => Stream.value(const <IngredientItem>[]),
          ),
          favoritesProvider.overrideWith(
            (ref) => Stream.value(const <FavoriteItem>[]),
          ),
          shelfLifeProvider.overrideWith(
            (ref) => Stream.value(const <ShelfLifeRule>[]),
          ),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const NamgimApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();

    expect(find.textContaining('5주차'), findsNothing);
    expect(find.textContaining('workmanager와 함께'), findsNothing);
    expect(find.textContaining('먹음·버림은 앱을 열지 않아도'), findsOneWidget);
    expect(find.textContaining('웹이나 컴퓨터에서는 알림을 예약하지 않아요'), findsOneWidget);
    expect(find.text('테스트 알림 보내기'), findsOneWidget);
    expect(find.byKey(const Key('notification-permission')), findsNothing);

    await tester.tap(find.text('테스트 알림 보내기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('이 환경에서는 테스트 알림을 보낼 수 없어요.'), findsOneWidget);

    final fridgeRow = find.ancestor(
      of: find.text('며칠 전').first,
      matching: find.byType(Row),
    );
    await tester.tap(
      find.descendant(of: fridgeRow, matching: find.byIcon(Icons.add)),
    );
    await tester.pumpAndSettle();
    expect(find.text('4일'), findsOneWidget);
    expect(settings.prefs.fridgeLeadDays, 4);
  });
}
