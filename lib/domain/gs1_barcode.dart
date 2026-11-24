import 'dates.dart';

/// A date read from a GS1 barcode.
class Gs1Date {
  const Gs1Date({required this.date, required this.bestBefore});

  /// Calendar day. `DD = 00` is already expanded to the last day of the month.
  final DateTime date;

  /// True when the date came from AI (15), false for AI (17).
  final bool bestBefore;
}

/// What a barcode value means for the expiry field.
class Gs1Read {
  const Gs1Read({
    this.expiry,
    this.bestBefore,
    this.plainRetailCode = false,
    this.invalidDate = false,
  });

  final DateTime? expiry;
  final DateTime? bestBefore;
  final bool plainRetailCode;
  final bool invalidDate;

  DateTime? get chosen => expiry ?? bestBefore;

  bool get usesBestBefore => expiry == null && bestBefore != null;
}

/// Several raw barcode strings from one scan.
class BarcodeInterpretation {
  const BarcodeInterpretation({
    this.date,
    this.bestBefore = false,
    this.plainRetailCode = false,
    this.invalidDate = false,
  });

  final DateTime? date;
  final bool bestBefore;
  final bool plainRetailCode;
  final bool invalidDate;
}

/// GS1 two-digit year: 49 years in the past through 50 years ahead.
int expandGs1Year(int yy, int currentYear) {
  final century = currentYear - (currentYear % 100);
  var year = century + yy;
  if (year > currentYear + 50) year -= 100;
  if (year < currentYear - 49) year += 100;
  return year;
}

/// Parses one barcode payload.
///
/// Prefers AI (17) expiry over AI (15) best-before. A plain EAN-13/UPC/GTIN
/// with no date AI is reported as [Gs1Read.plainRetailCode] and does not
/// invent a date. `DD = 00` means the last calendar day of that month.
Gs1Read parseGs1Payload(String input, {required DateTime today}) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return const Gs1Read();

  if (trimmed.contains('(')) {
    return _fromPairs(_parenthesized(trimmed), today: today, plain: false);
  }

  final normalized = _stripSymbology(trimmed);
  final pairs = _walkElements(normalized);
  final onlyDigits = RegExp(r'^\d+$').hasMatch(normalized);
  final compactDate = onlyDigits ? _compactDateAi(normalized) : null;
  if (compactDate != null && pairs.isEmpty) {
    pairs.add(compactDate);
  }
  final plainLength = normalized.length;
  final plain =
      pairs.isEmpty &&
      onlyDigits &&
      (plainLength == 8 ||
          plainLength == 12 ||
          plainLength == 13 ||
          plainLength == 14);
  return _fromPairs(pairs, today: today, plain: plain);
}

BarcodeInterpretation interpretBarcodeValues(
  List<String> values, {
  DateTime? today,
}) {
  final now = today ?? DateTime.now();
  DateTime? expiry;
  DateTime? bestBefore;
  var plain = false;
  var invalid = false;
  for (final value in values) {
    final read = parseGs1Payload(value, today: now);
    expiry ??= read.expiry;
    bestBefore ??= read.bestBefore;
    plain = plain || read.plainRetailCode;
    invalid = invalid || read.invalidDate;
  }
  if (expiry != null) {
    return BarcodeInterpretation(date: dateOnly(expiry));
  }
  if (bestBefore != null) {
    return BarcodeInterpretation(date: dateOnly(bestBefore), bestBefore: true);
  }
  return BarcodeInterpretation(plainRetailCode: plain, invalidDate: invalid);
}

Gs1Read _fromPairs(
  List<({String ai, String value})> pairs, {
  required DateTime today,
  required bool plain,
}) {
  DateTime? expiry;
  DateTime? bestBefore;
  var invalid = false;
  for (final pair in pairs) {
    if (pair.ai != '17' && pair.ai != '15') continue;
    final parsed = _parseYyMmDd(pair.value, today);
    if (parsed == null) {
      invalid = true;
      continue;
    }
    if (pair.ai == '17') {
      expiry ??= parsed;
    } else {
      bestBefore ??= parsed;
    }
  }
  final sawProduct = pairs.any((pair) => pair.ai == '01' || pair.ai == '02');
  return Gs1Read(
    expiry: expiry,
    bestBefore: bestBefore,
    plainRetailCode:
        (plain || sawProduct) && expiry == null && bestBefore == null,
    invalidDate: invalid && expiry == null && bestBefore == null,
  );
}

DateTime? _parseYyMmDd(String raw, DateTime today) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 6) return null;
  final yy = int.tryParse(digits.substring(0, 2));
  final month = int.tryParse(digits.substring(2, 4));
  final day = int.tryParse(digits.substring(4, 6));
  if (yy == null || month == null || day == null) return null;
  if (month < 1 || month > 12) return null;
  final year = expandGs1Year(yy, today.year);
  final last = DateTime(year, month + 1, 0).day;
  if (day == 0) return DateTime(year, month, last);
  if (day > last) return null;
  return DateTime(year, month, day);
}

String _stripSymbology(String value) {
  final match = RegExp(r'^\][A-Za-z]\d').firstMatch(value);
  if (match == null) return value;
  return value.substring(match.end);
}

/// AI (17) or (15) packed as exactly eight digits, e.g. `17261231`.
({String ai, String value})? _compactDateAi(String digits) {
  if (digits.length != 8) return null;
  final ai = digits.substring(0, 2);
  if (ai != '17' && ai != '15') return null;
  if (!_looksLikeDate(digits.substring(2))) return null;
  return (ai: ai, value: digits.substring(2));
}

bool _looksLikeDate(String yymmdd) {
  if (yymmdd.length < 6) return false;
  final month = int.tryParse(yymmdd.substring(2, 4));
  final day = int.tryParse(yymmdd.substring(4, 6));
  if (month == null || day == null) return false;
  return month >= 1 && month <= 12 && day >= 0 && day <= 31;
}

const _fixedLength = <String, int>{
  '00': 18,
  '01': 14,
  '02': 14,
  '11': 6,
  '12': 6,
  '13': 6,
  '15': 6,
  '16': 6,
  '17': 6,
  '20': 2,
};

const _variableMax = <String, int>{'10': 20, '21': 20, '30': 8, '37': 8};

List<({String ai, String value})> _parenthesized(String input) {
  final pairs = <({String ai, String value})>[];
  final pattern = RegExp(r'\((\d{2,4})\)([^()]*)');
  for (final match in pattern.allMatches(input)) {
    pairs.add((ai: match.group(1)!, value: match.group(2)!.trim()));
  }
  return pairs;
}

List<({String ai, String value})> _walkElements(String input) {
  final pairs = <({String ai, String value})>[];
  var index = 0;
  final chars = input.split('');
  while (index < chars.length) {
    if (chars[index] == '\u001d') {
      index += 1;
      continue;
    }
    if (!_isDigit(chars[index])) break;
    final ai = _matchAi(input, index);
    if (ai == null) break;
    index += ai.length;
    final fixed = _fixedLength[ai];
    if (fixed != null) {
      final value = _takeDigits(input, index, fixed);
      if (value == null) break;
      pairs.add((ai: ai, value: value));
      index += value.length;
      continue;
    }
    final max = _variableMax[ai];
    if (max == null) break;
    final end = _variableEnd(input, index, max);
    pairs.add((ai: ai, value: input.substring(index, end)));
    index = end;
  }
  return pairs;
}

String? _matchAi(String input, int index) {
  for (final length in [4, 3, 2]) {
    if (index + length > input.length) continue;
    final candidate = input.substring(index, index + length);
    if (_fixedLength.containsKey(candidate) ||
        _variableMax.containsKey(candidate)) {
      return candidate;
    }
  }
  return null;
}

String? _takeDigits(String input, int index, int count) {
  if (index + count > input.length) return null;
  final value = input.substring(index, index + count);
  if (!RegExp(r'^\d+$').hasMatch(value)) return null;
  return value;
}

int _variableEnd(String input, int index, int max) {
  var cursor = index;
  final limit = index + max < input.length ? index + max : input.length;
  while (cursor < limit && input[cursor] != '\u001d') {
    cursor += 1;
  }
  return cursor;
}

bool _isDigit(String char) {
  final code = char.codeUnitAt(0);
  return code >= 48 && code <= 57;
}
