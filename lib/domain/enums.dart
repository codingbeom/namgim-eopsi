/// Stored as a Drift intEnum. Do not reorder existing values.
enum StorageLocation {
  fridge,
  freezer,
  pantry;

  String get label => switch (this) {
    StorageLocation.fridge => '냉장',
    StorageLocation.freezer => '냉동',
    StorageLocation.pantry => '상온',
  };

  String get place => switch (this) {
    StorageLocation.fridge => '냉장고',
    StorageLocation.freezer => '냉동실',
    StorageLocation.pantry => '찬장',
  };
}

/// Stored as a Drift intEnum. Do not reorder existing values.
enum IngredientStatus {
  stored,
  eaten,
  discarded;

  String get label => switch (this) {
    IngredientStatus.stored => '보관 중',
    IngredientStatus.eaten => '먹음',
    IngredientStatus.discarded => '버림',
  };
}
