/// Web has no home screen widget channel. Every call is a no-op.
Future<void> registerHomeWidgetInteractivity(
  Future<void> Function(Uri?) callback,
) async {}

Future<void> writeHomeWidgetPayload(Map<String, String> payload) async {}

Future<Uri?> initialHomeWidgetUri() async => null;

void Function() listenForHomeWidgetClicks(
  void Function(Uri? uri) onData,
  void Function(Object error, StackTrace stackTrace) onError,
) {
  return () {};
}
