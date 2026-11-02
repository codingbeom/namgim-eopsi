String compactName(String value) =>
    value.replaceAll(RegExp(r'\s+'), '').toLowerCase();

bool namesMatch(String left, String right) {
  final a = compactName(left);
  final b = compactName(right);
  if (a.isEmpty || b.isEmpty) return false;
  if (a == b) return true;
  if (a.length >= 2 && b.length >= 2 && (a.contains(b) || b.contains(a))) {
    return true;
  }
  return false;
}
