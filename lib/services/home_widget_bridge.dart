import 'home_widget_bridge_stub.dart'
    if (dart.library.io) 'home_widget_bridge_io.dart'
    as bridge;

Future<void> registerHomeWidgetInteractivity(
  Future<void> Function(Uri?) callback,
) {
  return bridge.registerHomeWidgetInteractivity(callback);
}

Future<void> writeHomeWidgetPayload(Map<String, String> payload) {
  return bridge.writeHomeWidgetPayload(payload);
}

Future<Uri?> initialHomeWidgetUri() => bridge.initialHomeWidgetUri();

void Function() listenForHomeWidgetClicks(
  void Function(Uri? uri) onData,
  void Function(Object error, StackTrace stackTrace) onError,
) {
  return bridge.listenForHomeWidgetClicks(onData, onError);
}
