import 'package:intl/intl.dart';

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

String formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toInt().toString();
  }
  return quantity.toStringAsFixed(1);
}

String formatMonthDay(DateTime date) {
  final formatted = DateFormat("M'월' d'일'").format(date);
  return '$formatted (${_weekdays[date.weekday - 1]})';
}

String formatExpiry(DateTime expiry, DateTime now) {
  final days = DateTime(
    expiry.year,
    expiry.month,
    expiry.day,
  ).difference(DateTime(now.year, now.month, now.day)).inDays;
  if (days < 0) return '${-days}일 지남';
  if (days == 0) return '오늘까지';
  if (days == 1) return '내일까지';
  if (days < 14) return '$days일 남음';
  return formatMonthDay(expiry);
}

String formatClock(int hour, int minute) {
  final period = hour < 12 ? '오전' : '오후';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  final minutes = minute.toString().padLeft(2, '0');
  return '$period $hour12:$minutes';
}
