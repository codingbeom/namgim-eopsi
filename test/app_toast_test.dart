import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namgim_eopsi/core/app_toast.dart';

void main() {
  test('toast durations stay short, and errors stay readable', () {
    expect(
      AppToast.durationFor(AppToastKind.success),
      AppToast.successDuration,
    );
    expect(AppToast.durationFor(AppToastKind.info), AppToast.infoDuration);
    expect(AppToast.durationFor(AppToastKind.error), AppToast.errorDuration);
    expect(
      AppToast.durationFor(AppToastKind.success, hasAction: true),
      AppToast.actionDuration,
    );
    expect(AppToast.successDuration, const Duration(seconds: 2));
    expect(AppToast.infoDuration, const Duration(seconds: 4));
    expect(AppToast.errorDuration, const Duration(seconds: 6));
    expect(AppToast.actionDuration, const Duration(seconds: 4));
    expect(AppToast.errorDuration, greaterThan(AppToast.successDuration));
  });

  testWidgets('snackbars dismiss on their timeout, even with an action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () => AppToast.show(
                    context,
                    '담았어요',
                    kind: AppToastKind.success,
                  ),
                  child: const Text('success'),
                ),
                TextButton(
                  onPressed: () => AppToast.show(
                    context,
                    '이름을 입력하세요',
                    kind: AppToastKind.error,
                  ),
                  child: const Text('error'),
                ),
                TextButton(
                  onPressed: () => AppToast.show(
                    context,
                    '두부 먹었어요',
                    kind: AppToastKind.success,
                    action: SnackBarAction(label: '되돌리기', onPressed: () {}),
                  ),
                  child: const Text('undo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future<void> showAndExpect(String label, Duration duration) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      final bar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(bar.duration, duration);
      expect(bar.persist, isFalse);
      await tester.pump(duration);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    }

    await showAndExpect('success', AppToast.successDuration);
    await showAndExpect('error', AppToast.errorDuration);
    await showAndExpect('undo', AppToast.actionDuration);
    expect(find.text('되돌리기'), findsNothing);
  });
}
