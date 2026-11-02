import 'package:flutter/material.dart';

enum AppToastKind { success, info, error }

/// Shared SnackBar timeouts.
///
/// Success confirms a tap and leaves quickly. Info stays long enough to read
/// a sentence. Errors stay longer, then dismiss on their own. An action such
/// as 되돌리기 keeps the bar up long enough to tap, without leaving it open.
abstract final class AppToast {
  static const successDuration = Duration(seconds: 2);
  static const infoDuration = Duration(seconds: 4);
  static const errorDuration = Duration(seconds: 6);
  static const actionDuration = Duration(seconds: 4);

  static Duration durationFor(AppToastKind kind, {bool hasAction = false}) {
    if (hasAction) return actionDuration;
    return switch (kind) {
      AppToastKind.success => successDuration,
      AppToastKind.info => infoDuration,
      AppToastKind.error => errorDuration,
    };
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    AppToastKind kind = AppToastKind.info,
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: durationFor(kind, hasAction: action != null),
        // A SnackBar with an action stays up forever unless persist is false.
        // Undo still has a few seconds to tap, then the bar leaves on its own.
        persist: false,
        action: action,
      ),
    );
  }
}
