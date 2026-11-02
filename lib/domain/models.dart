import 'enums.dart';

class IngredientItem {
  const IngredientItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.storageLocation,
    required this.expiryDate,
    required this.isOpened,
    required this.openedAt,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String name;
  final double quantity;
  final StorageLocation storageLocation;
  final DateTime expiryDate;
  final bool isOpened;
  final DateTime? openedAt;
  final IngredientStatus status;
  final DateTime createdAt;
}

class FavoriteItem {
  const FavoriteItem({
    required this.id,
    required this.name,
    required this.defaultStorageLocation,
    required this.defaultShelfDays,
  });

  final int id;
  final String name;
  final StorageLocation defaultStorageLocation;
  final int? defaultShelfDays;
}

class ShelfLifeRule {
  const ShelfLifeRule({
    required this.id,
    required this.nameKeyword,
    required this.storageLocation,
    required this.days,
    this.category,
    this.openedDays,
    this.refrigerateAfterOpen = false,
  });

  final int id;
  final String nameKeyword;
  final String? category;
  final StorageLocation storageLocation;
  final int days;
  final int? openedDays;
  final bool refrigerateAfterOpen;
}
