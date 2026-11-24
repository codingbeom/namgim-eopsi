import 'dates.dart';
import 'enums.dart';
import 'models.dart';
import 'notification_prefs.dart';
import 'urgency.dart';

/// Rows the Android home widget can show. The layout reads the same keys.
const homeWidgetImminentSlots = 3;
const homeWidgetFavoriteSlots = 4;

class HomeWidgetImminent {
  const HomeWidgetImminent({
    required this.name,
    required this.days,
    required this.badge,
    required this.tone,
  });

  final String name;
  final int days;
  final String badge;
  final String tone;
}

class HomeWidgetFavoriteSlot {
  const HomeWidgetFavoriteSlot({required this.id, required this.name});

  final int id;
  final String name;
}

class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.storedCount,
    required this.imminentCount,
    required this.summary,
    required this.detail,
    required this.imminent,
    required this.favorites,
    required this.favoritesLabel,
    required this.favoritesHint,
  });

  final int storedCount;
  final int imminentCount;
  final String summary;
  final String detail;
  final List<HomeWidgetImminent> imminent;
  final List<HomeWidgetFavoriteSlot> favorites;
  final String favoritesLabel;
  final String favoritesHint;

  bool get isEmpty => imminentCount == 0;

  Map<String, String> toPayload() {
    final payload = <String, String>{
      'summary': summary,
      'detail': detail,
      'imminent_count': '$imminentCount',
      'stored_count': '$storedCount',
      'favorite_count': '${favorites.length}',
      'favorites_label': favoritesLabel,
      'favorites_hint': favoritesHint,
    };
    for (var index = 0; index < homeWidgetImminentSlots; index++) {
      final item = index < imminent.length ? imminent[index] : null;
      final slot = index + 1;
      payload['item${slot}_name'] = item?.name ?? '';
      payload['item${slot}_badge'] = item?.badge ?? '';
      payload['item${slot}_tone'] = item?.tone ?? '';
    }
    for (var index = 0; index < homeWidgetFavoriteSlots; index++) {
      final favorite = index < favorites.length ? favorites[index] : null;
      final slot = index + 1;
      payload['fav${slot}_id'] = favorite == null ? '' : '${favorite.id}';
      payload['fav${slot}_name'] = favorite?.name ?? '';
    }
    return payload;
  }
}

/// Compact badge for the widget. Overdue is `D+2`, today is `D-Day`.
String widgetDdayLabel(int days) {
  if (days < 0) return 'D+${-days}';
  if (days == 0) return 'D-Day';
  return 'D-$days';
}

String widgetDdayTone(int days) {
  if (days < 0) return 'overdue';
  if (days == 0) return 'today';
  return 'soon';
}

/// Imminent rows follow the same thresholds as the home screen.
///
/// Fridge and freezer use their lead days. Pantry uses the later reminder,
/// which is what the home list already calls 임박. Only stored food counts.
HomeWidgetSnapshot buildHomeWidgetSnapshot({
  required List<IngredientItem> items,
  required List<FavoriteItem> favorites,
  required NotificationPrefs prefs,
  required DateTime now,
}) {
  final stored = [
    for (final item in items)
      if (item.status == IngredientStatus.stored) item,
  ];
  final imminent =
      [
        for (final item in stored)
          if (needsAttention(
            expiry: item.expiryDate,
            location: item.storageLocation,
            now: now,
            prefs: prefs,
          ))
            item,
      ]..sort((a, b) {
        final byDays = daysUntil(
          a.expiryDate,
          now,
        ).compareTo(daysUntil(b.expiryDate, now));
        if (byDays != 0) return byDays;
        final byName = a.name.compareTo(b.name);
        if (byName != 0) return byName;
        return a.id.compareTo(b.id);
      });
  final visible = [
    for (final item in imminent.take(homeWidgetImminentSlots))
      HomeWidgetImminent(
        name: item.name,
        days: daysUntil(item.expiryDate, now),
        badge: widgetDdayLabel(daysUntil(item.expiryDate, now)),
        tone: widgetDdayTone(daysUntil(item.expiryDate, now)),
      ),
  ];
  final favoriteSlots = [
    for (final favorite
        in (favorites.toList()..sort((a, b) => a.id.compareTo(b.id))).take(
          homeWidgetFavoriteSlots,
        ))
      HomeWidgetFavoriteSlot(id: favorite.id, name: favorite.name),
  ];
  final count = imminent.length;
  final summary = count == 0 ? '임박한 재료 없음' : '임박 $count개';
  final detail = count == 0
      ? (stored.isEmpty ? '냉장고가 비어 있어요' : '오늘은 바로 챙길 재료가 없어요')
      : '보관 ${stored.length}개 · 오늘 확인할 재료';
  return HomeWidgetSnapshot(
    storedCount: stored.length,
    imminentCount: count,
    summary: summary,
    detail: detail,
    imminent: visible,
    favorites: favoriteSlots,
    favoritesLabel: favoriteSlots.isEmpty ? '즐겨찾기가 없어요' : '즐겨찾기',
    favoritesHint: favoriteSlots.isEmpty ? '앱에서 담아 두면 여기서 바로 추가해요' : '',
  );
}
