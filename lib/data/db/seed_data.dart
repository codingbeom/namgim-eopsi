import '../../domain/enums.dart';

class ShelfLifeSeed {
  const ShelfLifeSeed(
    this.keyword,
    this.location,
    this.days, {
    this.category,
    this.openedDays,
    this.refrigerateAfterOpen = false,
  });

  final String keyword;
  final StorageLocation location;
  final int days;
  final String? category;
  final int? openedDays;
  final bool refrigerateAfterOpen;
}

class FavoriteSeed {
  const FavoriteSeed(this.name, this.location, this.shelfDays);

  final String name;
  final StorageLocation location;
  final int? shelfDays;
}

class IngredientSeed {
  const IngredientSeed(this.name, this.location, this.daysFromToday);

  final String name;
  final StorageLocation location;
  final int daysFromToday;
}

/// Starter shelf-life guesses for a one-person kitchen.
/// Week 1 of the plan is the place to replace these with researched numbers.
const shelfLifeSeeds = <ShelfLifeSeed>[
  ShelfLifeSeed('계란', StorageLocation.fridge, 21, category: '단백질'),
  ShelfLifeSeed(
    '우유',
    StorageLocation.fridge,
    7,
    openedDays: 3,
    category: '유제품',
  ),
  ShelfLifeSeed(
    '두부',
    StorageLocation.fridge,
    5,
    openedDays: 2,
    category: '단백질',
  ),
  ShelfLifeSeed('대파', StorageLocation.fridge, 7, openedDays: 5, category: '채소'),
  ShelfLifeSeed(
    '양파',
    StorageLocation.pantry,
    30,
    openedDays: 7,
    refrigerateAfterOpen: true,
    category: '채소',
  ),
  ShelfLifeSeed('마늘', StorageLocation.pantry, 45, category: '채소'),
  ShelfLifeSeed('감자', StorageLocation.pantry, 21, category: '채소'),
  ShelfLifeSeed('당근', StorageLocation.fridge, 14, category: '채소'),
  ShelfLifeSeed('배추', StorageLocation.fridge, 7, category: '채소'),
  ShelfLifeSeed('시금치', StorageLocation.fridge, 4, category: '채소'),
  ShelfLifeSeed('콩나물', StorageLocation.fridge, 3, category: '채소'),
  ShelfLifeSeed('버섯', StorageLocation.fridge, 5, category: '채소'),
  ShelfLifeSeed('애호박', StorageLocation.fridge, 5, category: '채소'),
  ShelfLifeSeed('브로콜리', StorageLocation.fridge, 5, category: '채소'),
  ShelfLifeSeed(
    '김치',
    StorageLocation.fridge,
    60,
    openedDays: 30,
    category: '채소',
  ),
  ShelfLifeSeed(
    '닭가슴살',
    StorageLocation.fridge,
    2,
    openedDays: 1,
    category: '단백질',
  ),
  ShelfLifeSeed('닭가슴살', StorageLocation.freezer, 90, category: '단백질'),
  ShelfLifeSeed(
    '소고기',
    StorageLocation.fridge,
    3,
    openedDays: 1,
    category: '단백질',
  ),
  ShelfLifeSeed('소고기', StorageLocation.freezer, 90, category: '단백질'),
  ShelfLifeSeed(
    '돼지고기',
    StorageLocation.fridge,
    3,
    openedDays: 1,
    category: '단백질',
  ),
  ShelfLifeSeed('돼지고기', StorageLocation.freezer, 60, category: '단백질'),
  ShelfLifeSeed('생선', StorageLocation.fridge, 1, category: '단백질'),
  ShelfLifeSeed('생선', StorageLocation.freezer, 30, category: '단백질'),
  ShelfLifeSeed('햄', StorageLocation.fridge, 14, openedDays: 3, category: '가공'),
  ShelfLifeSeed(
    '소시지',
    StorageLocation.fridge,
    10,
    openedDays: 3,
    category: '가공',
  ),
  ShelfLifeSeed(
    '베이컨',
    StorageLocation.fridge,
    14,
    openedDays: 5,
    category: '가공',
  ),
  ShelfLifeSeed(
    '어묵',
    StorageLocation.fridge,
    10,
    openedDays: 3,
    category: '가공',
  ),
  ShelfLifeSeed(
    '치즈',
    StorageLocation.fridge,
    21,
    openedDays: 7,
    category: '유제품',
  ),
  ShelfLifeSeed(
    '요거트',
    StorageLocation.fridge,
    14,
    openedDays: 3,
    category: '유제품',
  ),
  ShelfLifeSeed(
    '버터',
    StorageLocation.fridge,
    60,
    openedDays: 30,
    category: '유제품',
  ),
  ShelfLifeSeed(
    '굴소스',
    StorageLocation.pantry,
    365,
    openedDays: 90,
    refrigerateAfterOpen: true,
    category: '양념',
  ),
  ShelfLifeSeed(
    '간장',
    StorageLocation.pantry,
    365,
    openedDays: 180,
    category: '양념',
  ),
  ShelfLifeSeed(
    '고추장',
    StorageLocation.pantry,
    365,
    openedDays: 120,
    refrigerateAfterOpen: true,
    category: '양념',
  ),
  ShelfLifeSeed(
    '된장',
    StorageLocation.pantry,
    180,
    openedDays: 90,
    refrigerateAfterOpen: true,
    category: '양념',
  ),
  ShelfLifeSeed(
    '마요네즈',
    StorageLocation.pantry,
    120,
    openedDays: 30,
    refrigerateAfterOpen: true,
    category: '양념',
  ),
  ShelfLifeSeed(
    '케첩',
    StorageLocation.pantry,
    180,
    openedDays: 30,
    refrigerateAfterOpen: true,
    category: '양념',
  ),
  ShelfLifeSeed('참기름', StorageLocation.pantry, 180, category: '양념'),
  ShelfLifeSeed('식용유', StorageLocation.pantry, 365, category: '양념'),
  ShelfLifeSeed('라면', StorageLocation.pantry, 180, category: '가공'),
  ShelfLifeSeed('쌀', StorageLocation.pantry, 365, category: '곡류'),
  ShelfLifeSeed(
    '통조림',
    StorageLocation.pantry,
    365,
    openedDays: 2,
    refrigerateAfterOpen: true,
    category: '가공',
  ),
  ShelfLifeSeed(
    '참치캔',
    StorageLocation.pantry,
    365,
    openedDays: 1,
    refrigerateAfterOpen: true,
    category: '가공',
  ),
  ShelfLifeSeed('식빵', StorageLocation.pantry, 4, openedDays: 2, category: '곡류'),
  ShelfLifeSeed('냉동만두', StorageLocation.freezer, 90, category: '가공'),
  ShelfLifeSeed('만두', StorageLocation.freezer, 90, category: '가공'),
  ShelfLifeSeed('냉동밥', StorageLocation.freezer, 30, category: '곡류'),
  ShelfLifeSeed('딸기', StorageLocation.fridge, 3, category: '과일'),
  ShelfLifeSeed('바나나', StorageLocation.pantry, 5, category: '과일'),
  ShelfLifeSeed('사과', StorageLocation.fridge, 14, category: '과일'),
  ShelfLifeSeed('귤', StorageLocation.pantry, 14, category: '과일'),
];

const favoriteSeeds = <FavoriteSeed>[
  FavoriteSeed('계란', StorageLocation.fridge, 21),
  FavoriteSeed('우유', StorageLocation.fridge, 7),
  FavoriteSeed('두부', StorageLocation.fridge, 5),
  FavoriteSeed('대파', StorageLocation.fridge, 7),
  FavoriteSeed('양파', StorageLocation.pantry, 30),
  FavoriteSeed('김치', StorageLocation.fridge, 30),
  FavoriteSeed('라면', StorageLocation.pantry, 180),
  FavoriteSeed('굴소스', StorageLocation.pantry, 365),
  FavoriteSeed('닭가슴살', StorageLocation.fridge, 2),
  FavoriteSeed('쌀', StorageLocation.pantry, 365),
  FavoriteSeed('냉동만두', StorageLocation.freezer, 90),
  FavoriteSeed('식빵', StorageLocation.pantry, 4),
];

/// Demo inventory so home and recipes are useful on first launch.
const sampleIngredients = <IngredientSeed>[
  IngredientSeed('두부', StorageLocation.fridge, 1),
  IngredientSeed('우유', StorageLocation.fridge, 2),
  IngredientSeed('대파', StorageLocation.fridge, 3),
  IngredientSeed('식빵', StorageLocation.pantry, 2),
  IngredientSeed('계란', StorageLocation.fridge, 16),
  IngredientSeed('양파', StorageLocation.pantry, 25),
  IngredientSeed('굴소스', StorageLocation.pantry, 120),
  IngredientSeed('냉동만두', StorageLocation.freezer, 40),
];
