import 'dates.dart';
import 'enums.dart';

class OpenPlan {
  const OpenPlan({
    required this.expiryDate,
    required this.suggestFridge,
    required this.openedDays,
    required this.shortened,
  });

  final DateTime expiryDate;
  final bool suggestFridge;
  final int openedDays;
  final bool shortened;
}

OpenPlan planOpen({
  required DateTime now,
  required DateTime currentExpiry,
  required StorageLocation location,
  required int? openedDays,
  required bool refrigerateAfterOpen,
}) {
  final days =
      openedDays ??
      switch (location) {
        StorageLocation.fridge => 3,
        StorageLocation.freezer => 30,
        StorageLocation.pantry => 14,
      };
  final openedExpiry = addDays(now, days);
  final current = dateOnly(currentExpiry);
  final shortened = openedExpiry.isBefore(current);
  return OpenPlan(
    expiryDate: shortened ? openedExpiry : current,
    suggestFridge: refrigerateAfterOpen && location == StorageLocation.pantry,
    openedDays: days,
    shortened: shortened,
  );
}
