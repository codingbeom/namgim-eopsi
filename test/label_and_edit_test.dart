import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/app/namgim_app.dart';
import 'package:namgim_eopsi/data/db/app_database.dart';
import 'package:namgim_eopsi/data/repositories/ingredient_repository.dart';
import 'package:namgim_eopsi/data/repositories/shelf_life_repository.dart';
import 'package:namgim_eopsi/core/format.dart';
import 'package:namgim_eopsi/domain/dates.dart';
import 'package:namgim_eopsi/domain/enums.dart';
import 'package:namgim_eopsi/domain/expiry_reminders.dart';
import 'package:namgim_eopsi/domain/gs1_barcode.dart';
import 'package:namgim_eopsi/domain/models.dart';
import 'package:namgim_eopsi/domain/notification_prefs.dart';
import 'package:namgim_eopsi/domain/packaging_date.dart';
import 'package:namgim_eopsi/domain/open_plan.dart';
import 'package:namgim_eopsi/features/ingredients/ingredients_screen.dart';
import 'package:namgim_eopsi/features/shell/notification_host.dart';
import 'package:namgim_eopsi/providers/providers.dart';
import 'package:namgim_eopsi/services/label_capture.dart';
import 'package:namgim_eopsi/services/notification_service.dart';

final _today = DateTime(2026, 11, 24);

void main() {
  group('GS1 barcodes', () {
    test('reads AI 17 and treats DD 00 as the last day of the month', () {
      final expiry = parseGs1Payload('(17)261231', today: _today);
      expect(expiry.expiry, DateTime(2026, 12, 31));
      expect(expiry.bestBefore, isNull);

      final bestBefore = parseGs1Payload('(15)261200', today: _today);
      expect(bestBefore.bestBefore, DateTime(2026, 12, 31));
      expect(bestBefore.usesBestBefore, isTrue);

      final february = parseGs1Payload('(17)240200', today: _today);
      expect(february.expiry, DateTime(2024, 2, 29));
    });

    test(
      'prefers expiry over best-before and ignores a manufacturing date',
      () {
        final read = parseGs1Payload(
          '(11)260101(15)261130(17)261215',
          today: _today,
        );
        expect(read.expiry, DateTime(2026, 12, 15));
        expect(read.bestBefore, DateTime(2026, 11, 30));
        expect(
          interpretBarcodeValues([
            '(15)261130',
            '(11)260101(17)261215',
          ], today: _today).date,
          DateTime(2026, 12, 15),
        );
      },
    );

    test('walks a GS1 element string and a symbology prefix', () {
      const element = '010880123456789317261231';
      final walked = parseGs1Payload(element, today: _today);
      expect(walked.expiry, DateTime(2026, 12, 31));

      final separated = parseGs1Payload(
        '0108801234567893\u001d17261215',
        today: _today,
      );
      expect(separated.expiry, DateTime(2026, 12, 15));

      final prefixed = parseGs1Payload(']C1$element', today: _today);
      expect(prefixed.expiry, DateTime(2026, 12, 31));

      final compact = parseGs1Payload('17261231', today: _today);
      expect(compact.expiry, DateTime(2026, 12, 31));
    });

    test('plain EAN-13 and UPC do not invent a date', () {
      final ean = interpretBarcodeValues(['8801234567890'], today: _today);
      expect(ean.date, isNull);
      expect(ean.plainRetailCode, isTrue);

      final upc = interpretBarcodeValues(['012345678905'], today: _today);
      expect(upc.plainRetailCode, isTrue);
      expect(upc.date, isNull);

      final gtinOnly = parseGs1Payload('(01)08801234567893', today: _today);
      expect(gtinOnly.plainRetailCode, isTrue);
      expect(gtinOnly.chosen, isNull);

      final invalid = interpretBarcodeValues(['(17)261332'], today: _today);
      expect(invalid.date, isNull);
      expect(invalid.invalidDate, isTrue);
      expect(invalid.plainRetailCode, isFalse);
    });

    test('keeps a dated code when a retail code is scanned with it', () {
      final read = interpretBarcodeValues([
        '8801234567890',
        '(17)261231',
      ], today: _today);
      expect(read.date, DateTime(2026, 12, 31));
      expect(read.plainRetailCode, isFalse);
    });
  });

  group('packaging OCR text', () {
    test('reads Korean and numeric expiry formats', () {
      expect(
        parsePackagingExpiry('소비기한 2026년 12월 31일', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('2026.12.31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('2026-12-31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('2026/12/31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('26.12.31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('로트 20261231', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('까지 12.31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('01.02', today: _today),
        DateTime(2027, 1, 2),
      );
    });

    test('ignores a manufacturing date when an expiry is also printed', () {
      expect(
        parsePackagingExpiry('제조 2026.01.01\n유통기한 2026.12.31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('MFG 2024-01-01\nEXP 2026-12-31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(
        parsePackagingExpiry('BEST BEFORE 2026/12/31', today: _today),
        DateTime(2026, 12, 31),
      );
      expect(parsePackagingExpiry('제조일자 2026.01.01', today: _today), isNull);
      expect(parsePackagingExpiry('', today: _today), isNull);
      expect(parsePackagingExpiry('로트 ABC-12', today: _today), isNull);
      expect(parsePackagingExpiry('2026.13.40', today: _today), isNull);
    });
  });

  test('editing an ingredient persists and moves its reminder', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftIngredientRepository(
      database,
      DriftShelfLifeRepository(database),
    );
    final id = await repository.add(
      name: '두부',
      quantity: 1,
      location: StorageLocation.fridge,
      expiryDate: DateTime(2026, 11, 27),
    );
    await repository.updateDetails(
      id: id,
      name: '순두부',
      quantity: 2,
      location: StorageLocation.freezer,
      expiryDate: DateTime(2026, 12, 20),
      opened: true,
      openedAt: DateTime(2026, 11, 24, 9),
    );

    final stored = await repository.watchAll().first;
    final item = stored.firstWhere((row) => row.id == id);
    expect(item.name, '순두부');
    expect(item.quantity, 2);
    expect(item.storageLocation, StorageLocation.freezer);
    expect(dateOnly(item.expiryDate), DateTime(2026, 12, 20));
    expect(item.isOpened, isTrue);

    final reminders = planExpiryReminders(
      items: stored.where((row) => row.id == id).toList(),
      prefs: NotificationPrefs.defaults.copyWith(
        freezerLeadDays: 2,
        freezerOnTheDay: false,
      ),
      now: _today,
    );
    expect(reminders.single.name, '순두부');
    expect(reminders.single.fireAt, DateTime(2026, 12, 18, 8));
    expect(reminders.single.location, StorageLocation.freezer);
  });

  testWidgets(
    'add screen has no week placeholder and explains an unsupported scan',
    (tester) async {
      _phone(tester);
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
      await _openAdd(tester);

      expect(find.textContaining('주차'), findsNothing);
      expect(find.textContaining('붙여요'), findsNothing);
      expect(find.textContaining('예정'), findsNothing);
      final barcode = tester.widget<OutlinedButton>(
        find.byKey(const Key('scan-barcode')),
      );
      expect(barcode.onPressed, isNotNull);

      await _tapScan(tester, const Key('scan-barcode'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.textContaining('이 환경에서는 바코드를 읽을 수 없어요'), findsOneWidget);
    },
  );

  testWidgets('a GS1 barcode fills the date and a plain barcode does not', (
    tester,
  ) async {
    _phone(tester);
    final capture = _ScriptedCapture(barcodes: const ['(17)261231']);
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
          labelCaptureProvider.overrideWithValue(capture),
        ],
        child: const NamgimApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _openAdd(tester);
    await _tapScan(tester, const Key('scan-barcode'));
    await tester.tap(find.text('카메라로 찍기'));
    await tester.pumpAndSettle();

    expect(capture.fromCamera, isTrue);
    final read = interpretBarcodeValues(const ['(17)261231']);
    expect(find.textContaining('바코드의 유통기한으로 채웠어요'), findsOneWidget);
    expect(find.text(formatMonthDay(read.date!)), findsWidgets);

    capture.barcodes = const ['8801234567890'];
    await tester.pump(const Duration(seconds: 3));
    await _tapScan(tester, const Key('scan-barcode'));
    await tester.tap(find.text('앨범에서 고르기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(capture.fromCamera, isFalse);
    expect(find.textContaining('일반 바코드에는 날짜가 없어요'), findsOneWidget);
    expect(find.textContaining('바코드의 유통기한으로 채웠어요'), findsOneWidget);
  });

  testWidgets('date capture fills an expiry and ignores a manufacturing date', (
    tester,
  ) async {
    _phone(tester);
    final capture = _ScriptedCapture(text: '제조 2026.01.01\n유통기한 2026.12.31');
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
          labelCaptureProvider.overrideWithValue(capture),
        ],
        child: const NamgimApp(),
      ),
    );
    await tester.pumpAndSettle();
    await _openAdd(tester);
    await _tapScan(tester, const Key('scan-date'));
    await tester.tap(find.text('카메라로 찍기'));
    await tester.pumpAndSettle();
    expect(find.textContaining('포장지에서 읽은 날짜로 채웠어요'), findsWidgets);
    expect(find.textContaining('12월 31일'), findsWidgets);
    expect(find.textContaining('1월 1일'), findsNothing);
  });

  testWidgets('editing from the list saves and reschedules notifications', (
    tester,
  ) async {
    _phone(tester);
    final now = DateTime(2026, 11, 24);
    final original = IngredientItem(
      id: 7,
      name: '두부',
      quantity: 1,
      storageLocation: StorageLocation.fridge,
      expiryDate: DateTime(2026, 11, 27),
      isOpened: false,
      openedAt: null,
      status: IngredientStatus.stored,
      createdAt: now,
    );
    final updates = StreamController<List<IngredientItem>>();
    addTearDown(updates.close);
    final repository = _RecordingIngredients(onUpdate: updates.add);
    final service = _CountingNotifications();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientsProvider.overrideWith(
            (ref) => Stream.multi((listener) {
              listener.add([original]);
              final subscription = updates.stream.listen(listener.add);
              listener.onCancel = subscription.cancel;
            }),
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
          ingredientRepositoryProvider.overrideWithValue(repository),
          notificationServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(
          home: NotificationHost(child: IngredientsScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('주차'), findsNothing);
    expect(find.text('두부'), findsWidgets);
    final before = service.syncs;
    expect(before, greaterThan(0));

    await tester.tap(find.text('수정').first);
    await tester.pumpAndSettle();

    expect(find.text('재료 수정'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('edit-name')), '순두부');
    await tester.tap(find.byKey(const Key('edit-opened')));
    final quantityRow = find.ancestor(
      of: find.text('수량'),
      matching: find.byType(Row),
    );
    await tester.tap(
      find.descendant(of: quantityRow, matching: find.byIcon(Icons.add)),
    );
    await tester.tap(find.byKey(const Key('edit-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final saved = repository.saved;
    expect(saved, isNotNull);
    expect(saved!.name, '순두부');
    expect(saved.quantity, 2);
    expect(saved.opened, isTrue);
    expect(saved.location, StorageLocation.fridge);
    expect(dateOnly(saved.expiryDate), DateTime(2026, 11, 27));
    expect(service.syncs, greaterThan(before));
    expect(service.last.map((item) => item.name), contains('순두부'));
  });

  testWidgets('the home imminent row opens the editor', (tester) async {
    _phone(tester);
    final now = DateTime.now();
    final item = IngredientItem(
      id: 1,
      name: '두부',
      quantity: 1,
      storageLocation: StorageLocation.fridge,
      expiryDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1)),
      isOpened: false,
      openedAt: null,
      status: IngredientStatus.stored,
      createdAt: now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ingredientsProvider.overrideWith((ref) => Stream.value([item])),
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
    await tester.tap(find.text('두부'));
    await tester.pumpAndSettle();
    expect(find.text('재료 수정'), findsOneWidget);
    expect(find.textContaining('주차'), findsNothing);
  });
}

class _SavedDetails {
  const _SavedDetails({
    required this.name,
    required this.quantity,
    required this.location,
    required this.expiryDate,
    required this.opened,
  });

  final String name;
  final double quantity;
  final StorageLocation location;
  final DateTime expiryDate;
  final bool opened;
}

class _RecordingIngredients implements IngredientRepository {
  _RecordingIngredients({required this.onUpdate});

  final void Function(List<IngredientItem> items) onUpdate;
  _SavedDetails? saved;

  @override
  Stream<List<IngredientItem>> watchAll() => const Stream.empty();

  @override
  Future<int> add({
    required String name,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
  }) async => 0;

  @override
  Future<int> addFromFavorite(FavoriteItem favorite) async => 0;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<void> setStatus(int id, IngredientStatus status) async {}

  @override
  Future<OpenPlan> previewOpen(IngredientItem item, {DateTime? now}) {
    throw UnimplementedError();
  }

  @override
  Future<void> markOpened({
    required int id,
    required DateTime expiryDate,
    required bool moveToFridge,
    DateTime? openedAt,
  }) async {}

  @override
  Future<void> updateDetails({
    required int id,
    required String name,
    required double quantity,
    required StorageLocation location,
    required DateTime expiryDate,
    required bool opened,
    DateTime? openedAt,
  }) async {
    saved = _SavedDetails(
      name: name,
      quantity: quantity,
      location: location,
      expiryDate: expiryDate,
      opened: opened,
    );
    onUpdate([
      IngredientItem(
        id: id,
        name: name,
        quantity: quantity,
        storageLocation: location,
        expiryDate: expiryDate,
        isOpened: opened,
        openedAt: openedAt,
        status: IngredientStatus.stored,
        createdAt: DateTime(2026, 11, 24),
      ),
    ]);
  }
}

class _ScriptedCapture implements LabelCapture {
  _ScriptedCapture({this.barcodes = const [], this.text});

  List<String>? barcodes;
  String? text;
  bool fromCamera = false;

  @override
  bool get supported => true;

  @override
  Future<List<String>?> scanBarcode({required bool fromCamera}) async {
    this.fromCamera = fromCamera;
    return barcodes;
  }

  @override
  Future<String?> recognizePackagingText({required bool fromCamera}) async {
    this.fromCamera = fromCamera;
    return text;
  }
}

class _CountingNotifications extends NotificationService {
  _CountingNotifications() : super(supported: false);

  int syncs = 0;
  List<IngredientItem> last = const [];

  @override
  Future<void> sync({
    required List<IngredientItem> items,
    required NotificationPrefs prefs,
    DateTime? now,
  }) async {
    syncs += 1;
    last = items;
  }
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
  addTearDown(tester.view.reset);
}

Future<void> _openAdd(WidgetTester tester) async {
  final add = find.widgetWithText(FilledButton, '재료 추가');
  await tester.scrollUntilVisible(
    add,
    400,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(add);
  await tester.pumpAndSettle();
}

Future<void> _tapScan(WidgetTester tester, Key key) async {
  final scrollable = find.descendant(
    of: find.byKey(const Key('add-form')),
    matching: find.byWidgetPredicate(
      (widget) => widget is Scrollable && widget.axis == Axis.vertical,
    ),
  );
  final target = find.byKey(key);
  await tester.scrollUntilVisible(target, 80, scrollable: scrollable);
  await tester.drag(scrollable, const Offset(0, -180));
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void mainWidgets() {}
