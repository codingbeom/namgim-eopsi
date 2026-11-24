import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'label_capture.dart';

LabelCapture createLabelCapture() => MobileLabelCapture();

class MobileLabelCapture implements LabelCapture {
  MobileLabelCapture({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  bool get supported => Platform.isAndroid || Platform.isIOS;

  Future<String?> _pick(bool fromCamera) async {
    final file = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 90,
    );
    return file?.path;
  }

  @override
  Future<List<String>?> scanBarcode({required bool fromCamera}) async {
    if (!supported) return null;
    final path = await _pick(fromCamera);
    if (path == null) return null;
    final scanner = BarcodeScanner(formats: const [BarcodeFormat.all]);
    try {
      final codes = await scanner.processImage(InputImage.fromFilePath(path));
      final values = <String>[];
      for (final code in codes) {
        final raw = code.rawValue?.trim();
        final display = code.displayValue?.trim();
        if (raw != null && raw.isNotEmpty) values.add(raw);
        if (display != null && display.isNotEmpty && display != raw) {
          values.add(display);
        }
      }
      return values;
    } finally {
      await scanner.close();
    }
  }

  @override
  Future<String?> recognizePackagingText({required bool fromCamera}) async {
    if (!supported) return null;
    final path = await _pick(fromCamera);
    if (path == null) return null;
    final scripts = Platform.isAndroid
        ? const [TextRecognitionScript.korean, TextRecognitionScript.latin]
        : const [TextRecognitionScript.latin];
    final chunks = <String>[];
    for (final script in scripts) {
      final recognizer = TextRecognizer(script: script);
      try {
        final recognized = await recognizer.processImage(
          InputImage.fromFilePath(path),
        );
        final text = recognized.text.trim();
        if (text.isNotEmpty) chunks.add(text);
      } catch (error, stack) {
        debugPrint('text recognition ($script) failed: $error\n$stack');
      } finally {
        await recognizer.close();
      }
    }
    return chunks.join('\n');
  }
}
