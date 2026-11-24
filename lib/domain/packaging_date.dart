import 'dates.dart';
import 'gs1_barcode.dart';

/// Reads a packaging expiry date out of OCR text.
///
/// Manufacturing dates (`제조`, `MFG`) are ignored when a separate expiry is
/// present. Returns null when the text is empty or has no usable date.
DateTime? parsePackagingExpiry(String text, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final source = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  if (source.trim().isEmpty) return null;

  final hits = <_Hit>[];
  void consider(RegExp pattern, DateTime? Function(RegExpMatch match) parse) {
    for (final match in pattern.allMatches(source)) {
      final date = parse(match);
      if (date == null) continue;
      final covered = hits.any(
        (hit) =>
            match.start >= hit.start &&
            match.end <= hit.end &&
            (hit.end - hit.start) > (match.end - match.start),
      );
      if (covered) continue;
      hits.add(
        _Hit(
          date: dateOnly(date),
          start: match.start,
          end: match.end,
          priority: _priority(source, match.start, match.end),
        ),
      );
    }
  }

  consider(
    RegExp(r'(\d{4})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})\s*일'),
    (match) => _ymd(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    ),
  );
  consider(
    RegExp(r'(?<!\d)(\d{4})\s*[./\-]\s*(\d{1,2})\s*[./\-]\s*(\d{1,2})(?!\d)'),
    (match) => _ymd(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    ),
  );
  consider(
    RegExp(r'(?<!\d)(\d{2})\s*[./\-]\s*(\d{1,2})\s*[./\-]\s*(\d{1,2})(?!\d)'),
    (match) => _ymd(
      expandGs1Year(int.parse(match.group(1)!), now.year),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    ),
  );
  consider(
    RegExp(
      r'(?<!\d)((?:19|20)\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])(?!\d)',
    ),
    (match) => _ymd(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    ),
  );
  consider(
    RegExp(r'(?<!\d)(0?[1-9]|1[0-2])\s*[./\-]\s*(0?[1-9]|[12]\d|3[01])(?!\d)'),
    (match) =>
        _monthDay(int.parse(match.group(1)!), int.parse(match.group(2)!), now),
  );

  final usable = hits.where((hit) => hit.priority >= 0).toList();
  if (usable.isEmpty) return null;
  final labeled = usable.where((hit) => hit.priority > 0).toList();
  final pool = labeled.isNotEmpty ? labeled : usable;
  pool.sort((a, b) {
    final byPriority = b.priority.compareTo(a.priority);
    if (byPriority != 0) return byPriority;
    return a.start.compareTo(b.start);
  });
  return pool.first.date;
}

class _Hit {
  const _Hit({
    required this.date,
    required this.start,
    required this.end,
    required this.priority,
  });

  final DateTime date;
  final int start;
  final int end;
  final int priority;
}

const _expiryWords = [
  '소비기한',
  '유통기한',
  '품질유지기한',
  '까지',
  'EXPIRY',
  'EXP',
  'BEST BEFORE',
  'BEST-BEFORE',
  'BBE',
  'USE BY',
  'USE-BY',
];

const _mfgWords = [
  '제조일자',
  '제조일',
  '제조',
  'MFG',
  'MANUFACTURED',
  'MANUFACTURE',
  'PRODUCTION DATE',
  'PROD',
];

int _priority(String text, int start, int end) {
  final window = _labelWindow(text, start, end).toUpperCase();
  final expiry = _expiryWords.any(window.contains);
  final mfg = _mfgWords.any((word) => window.contains(word.toUpperCase()));
  if (expiry) return 2;
  if (mfg) return -1;
  return 0;
}

/// Labels belong on the date's own line. If that line has no words before the
/// date, the previous line is included so a heading like `유통기한` still counts.
/// The next line is not included, so a following label cannot mark the wrong date.
String _labelWindow(String text, int start, int end) {
  final lineStart = start == 0 ? 0 : text.lastIndexOf('\n', start - 1) + 1;
  var from = lineStart;
  if (text.substring(lineStart, start).trim().isEmpty && lineStart > 0) {
    final previous = text.lastIndexOf('\n', lineStart - 2);
    from = previous < 0 ? 0 : previous + 1;
  }
  final lineEnd = text.indexOf('\n', end);
  final to = lineEnd < 0 ? text.length : lineEnd;
  return text.substring(from, to);
}

DateTime? _ymd(int year, int month, int day) {
  if (year < 1990 || year > 2100) return null;
  if (month < 1 || month > 12 || day < 1) return null;
  final last = DateTime(year, month + 1, 0).day;
  if (day > last) return null;
  return DateTime(year, month, day);
}

DateTime? _monthDay(int month, int day, DateTime today) {
  final thisYear = _ymd(today.year, month, day);
  if (thisYear == null) return null;
  if (!dateOnly(thisYear).isBefore(dateOnly(today))) return thisYear;
  return _ymd(today.year + 1, month, day);
}
