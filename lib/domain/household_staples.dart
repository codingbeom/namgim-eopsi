import 'names.dart';

/// Rice and kimchi are in almost every kitchen, so recipes treat them as
/// already owned unless a stored row should be used instead.
const householdStapleRice = '밥';
const householdStapleKimchi = '김치';

/// One-syllable `밥` is not covered by [namesMatch], which only fuzzy-matches
/// names of two characters or more. These are the rice aliases recipes should
/// still treat as the household staple.
const riceStapleNames = <String>{'밥', '흰밥', '찬밥', '공기밥', '쌀밥', '냉동밥'};

/// `밥` or `김치` when [name] is that staple or a longer alias such as `찬밥`
/// or `배추김치`. Dish names like `김밥` stay out.
String? householdStapleKey(String name) {
  final compact = compactName(name);
  if (compact.isEmpty) return null;
  if (riceStapleNames.contains(compact)) return householdStapleRice;
  if (compact == householdStapleKimchi ||
      (compact.length > householdStapleKimchi.length &&
          compact.contains(householdStapleKimchi))) {
    return householdStapleKimchi;
  }
  return null;
}

bool isHouseholdStaple(String name) => householdStapleKey(name) != null;

/// True when a stored name can satisfy a recipe ingredient.
///
/// Ordinary names use [namesMatch]. Staples also match their aliases, so a
/// stored `찬밥` covers a recipe that asks for `밥` and can be marked eaten.
bool coversIngredient(String storedName, String needed) {
  if (namesMatch(storedName, needed)) return true;
  final storedKey = householdStapleKey(storedName);
  final neededKey = householdStapleKey(needed);
  return storedKey != null && storedKey == neededKey;
}
