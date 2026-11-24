import 'label_capture.dart';
import 'label_capture_stub.dart'
    if (dart.library.io) 'label_capture_mobile.dart'
    as impl;

LabelCapture createLabelCapture() => impl.createLabelCapture();
