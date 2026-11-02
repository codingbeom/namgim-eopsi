DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime addDays(DateTime from, int days) =>
    dateOnly(from).add(Duration(days: days));

int daysUntil(DateTime expiry, DateTime now) =>
    dateOnly(expiry).difference(dateOnly(now)).inDays;
