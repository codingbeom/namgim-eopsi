import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

const namgimWidgetProvider = 'NamgimWidgetProvider';
const namgimWidgetQualifiedName = 'kr.namgim.namgim_eopsi.NamgimWidgetProvider';

bool get _androidHomeWidget => Platform.isAndroid;

/// Desktop, tests, and a missing plugin channel leave the widget untouched.
Future<void> registerHomeWidgetInteractivity(
  Future<void> Function(Uri?) callback,
) async {
  if (!_androidHomeWidget) return;
  try {
    await HomeWidget.registerInteractivityCallback(callback);
  } on MissingPluginException {
    return;
  } catch (error, stack) {
    debugPrint('home widget callback was not registered: $error\n$stack');
  }
}

Future<void> writeHomeWidgetPayload(Map<String, String> payload) async {
  if (!_androidHomeWidget) return;
  try {
    for (final entry in payload.entries) {
      await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
    }
    await HomeWidget.updateWidget(
      name: namgimWidgetProvider,
      androidName: namgimWidgetProvider,
      qualifiedAndroidName: namgimWidgetQualifiedName,
    );
  } on MissingPluginException {
    return;
  } catch (error, stack) {
    debugPrint('home widget update skipped: $error\n$stack');
  }
}

Future<Uri?> initialHomeWidgetUri() async {
  if (!_androidHomeWidget) return null;
  try {
    return await HomeWidget.initiallyLaunchedFromHomeWidget();
  } on MissingPluginException {
    return null;
  } catch (error, stack) {
    debugPrint('home widget launch check skipped: $error\n$stack');
    return null;
  }
}

void Function() listenForHomeWidgetClicks(
  void Function(Uri? uri) onData,
  void Function(Object error, StackTrace stackTrace) onError,
) {
  if (!_androidHomeWidget) return () {};
  try {
    final subscription = HomeWidget.widgetClicked.listen(
      onData,
      onError: onError,
    );
    return () {
      subscription.cancel();
    };
  } on MissingPluginException {
    return () {};
  } catch (error, stack) {
    onError(error, stack);
    return () {};
  }
}
