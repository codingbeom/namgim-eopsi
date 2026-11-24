/// On-device barcode and packaging-photo capture.
///
/// Web, desktop, and tests use [UnavailableLabelCapture]. Android and iOS
/// use the camera or gallery, then ML Kit, without leaving the device.
abstract class LabelCapture {
  bool get supported;

  /// Raw and display strings from one photo. Null when the user cancels.
  Future<List<String>?> scanBarcode({required bool fromCamera});

  /// Recognized packaging text. Null when the user cancels.
  Future<String?> recognizePackagingText({required bool fromCamera});
}

class UnavailableLabelCapture implements LabelCapture {
  const UnavailableLabelCapture();

  @override
  bool get supported => false;

  @override
  Future<List<String>?> scanBarcode({required bool fromCamera}) async => null;

  @override
  Future<String?> recognizePackagingText({required bool fromCamera}) async =>
      null;
}
