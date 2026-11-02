import 'enums.dart';
import 'models.dart';
import 'names.dart';

class ExpirySuggestion {
  const ExpirySuggestion({
    required this.days,
    required this.location,
    required this.fromFallback,
    this.matchedKeyword,
    this.openedDays,
    this.refrigerateAfterOpen = false,
  });

  final int days;
  final StorageLocation location;
  final bool fromFallback;
  final String? matchedKeyword;
  final int? openedDays;
  final bool refrigerateAfterOpen;

  String get helper {
    if (fromFallback) {
      return '${location.label} 기본 $days일로 채웠어요';
    }
    return '$matchedKeyword · ${location.label} $days일';
  }
}

int fallbackShelfDays(StorageLocation location) => switch (location) {
  StorageLocation.fridge => 7,
  StorageLocation.freezer => 30,
  StorageLocation.pantry => 30,
};

bool keywordHits(String name, String keyword) {
  final normalizedName = compactName(name);
  final normalizedKeyword = compactName(keyword);
  if (normalizedName.isEmpty || normalizedKeyword.isEmpty) return false;
  if (normalizedName == normalizedKeyword) return true;
  return normalizedKeyword.length >= 2 &&
      normalizedName.contains(normalizedKeyword);
}

int _locationTieBreak(StorageLocation location) => switch (location) {
  StorageLocation.fridge => 3,
  StorageLocation.pantry => 2,
  StorageLocation.freezer => 1,
};

ShelfLifeRule? bestRule(
  List<ShelfLifeRule> rules,
  String name, {
  StorageLocation? prefer,
  bool requireLocation = false,
}) {
  ShelfLifeRule? best;
  var bestScore = -1;
  for (final rule in rules) {
    if (requireLocation && prefer != null && rule.storageLocation != prefer) {
      continue;
    }
    if (!keywordHits(name, rule.nameKeyword)) continue;
    var score = compactName(rule.nameKeyword).length * 10;
    if (compactName(name) == compactName(rule.nameKeyword)) score += 5;
    if (prefer != null && rule.storageLocation == prefer) score += 4;
    score += _locationTieBreak(rule.storageLocation);
    if (score > bestScore) {
      best = rule;
      bestScore = score;
    }
  }
  return best;
}

ExpirySuggestion suggestExpiry({
  required List<ShelfLifeRule> rules,
  required String name,
  required StorageLocation location,
  required bool lockLocation,
}) {
  final sameLocation = bestRule(
    rules,
    name,
    prefer: location,
    requireLocation: true,
  );
  if (sameLocation != null) {
    return ExpirySuggestion(
      days: sameLocation.days,
      location: location,
      fromFallback: false,
      matchedKeyword: sameLocation.nameKeyword,
      openedDays: sameLocation.openedDays,
      refrigerateAfterOpen: sameLocation.refrigerateAfterOpen,
    );
  }

  if (!lockLocation) {
    final anyLocation = bestRule(rules, name, prefer: location);
    if (anyLocation != null) {
      return ExpirySuggestion(
        days: anyLocation.days,
        location: anyLocation.storageLocation,
        fromFallback: false,
        matchedKeyword: anyLocation.nameKeyword,
        openedDays: anyLocation.openedDays,
        refrigerateAfterOpen: anyLocation.refrigerateAfterOpen,
      );
    }
  }

  return ExpirySuggestion(
    days: fallbackShelfDays(location),
    location: location,
    fromFallback: true,
  );
}
