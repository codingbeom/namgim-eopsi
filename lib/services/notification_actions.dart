import 'dart:convert';

import '../data/repositories/ingredient_repository.dart';
import '../domain/enums.dart';

const notificationActionEaten = 'eaten';
const notificationActionDiscarded = 'discarded';
const notificationActionRecipes = 'recipes';

const expiryPayloadVersion = 1;

enum NotificationActionKind { markEaten, markDiscarded, openRecipes, ignore }

class NotificationActionPlan {
  const NotificationActionPlan({
    required this.kind,
    required this.ingredientIds,
  });

  final NotificationActionKind kind;
  final List<int> ingredientIds;

  bool get updatesStorage =>
      kind == NotificationActionKind.markEaten ||
      kind == NotificationActionKind.markDiscarded;
}

String encodeExpiryPayload(List<int> ingredientIds) {
  return jsonEncode({'v': expiryPayloadVersion, 'ids': ingredientIds});
}

List<int> decodeExpiryIngredientIds(String? payload) {
  if (payload == null || payload.isEmpty) return const [];
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! Map) return const [];
    final ids = decoded['ids'];
    if (ids is! List) return const [];
    return [
      for (final id in ids)
        if (id is int)
          id
        else if (id is num && id == id.roundToDouble())
          id.toInt(),
    ];
  } catch (_) {
    return const [];
  }
}

/// Maps a notification tap or action id onto a database or navigation plan.
///
/// A body tap and 메뉴 보기 open the recommendation tab. 먹음 and 버림 update
/// only the ids in the payload, so a grouped or single notification cannot
/// change a row that was not listed.
NotificationActionPlan planNotificationAction({
  required String? actionId,
  required String? payload,
}) {
  final ids = decodeExpiryIngredientIds(payload);
  return switch (actionId) {
    notificationActionEaten when ids.isNotEmpty => NotificationActionPlan(
      kind: NotificationActionKind.markEaten,
      ingredientIds: ids,
    ),
    notificationActionDiscarded when ids.isNotEmpty => NotificationActionPlan(
      kind: NotificationActionKind.markDiscarded,
      ingredientIds: ids,
    ),
    notificationActionEaten ||
    notificationActionDiscarded => const NotificationActionPlan(
      kind: NotificationActionKind.ignore,
      ingredientIds: [],
    ),
    null || notificationActionRecipes => NotificationActionPlan(
      kind: NotificationActionKind.openRecipes,
      ingredientIds: ids,
    ),
    _ => const NotificationActionPlan(
      kind: NotificationActionKind.ignore,
      ingredientIds: [],
    ),
  };
}

/// Applies 먹음 / 버림. Missing ids update zero rows and do not throw.
Future<void> applyNotificationAction({
  required IngredientRepository repository,
  required NotificationActionPlan plan,
}) async {
  final status = switch (plan.kind) {
    NotificationActionKind.markEaten => IngredientStatus.eaten,
    NotificationActionKind.markDiscarded => IngredientStatus.discarded,
    _ => null,
  };
  if (status == null) return;
  for (final id in plan.ingredientIds) {
    await repository.setStatus(id, status);
  }
}
