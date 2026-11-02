import 'dates.dart';
import 'enums.dart';
import 'models.dart';
import 'names.dart';
import 'notification_prefs.dart';
import 'urgency.dart';

enum RecipeCategory {
  rice('밥·면'),
  soup('국·찌개'),
  stir('볶음·구이'),
  side('반찬'),
  quick('간편');

  const RecipeCategory(this.label);

  final String label;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.minutes,
    required this.summary,
    required this.steps,
    required this.ingredients,
  });

  final String id;
  final String name;
  final RecipeCategory category;
  final int minutes;
  final String summary;
  final String steps;
  final List<String> ingredients;
}


/// How actionable a recipe is for the fridge right now.
///
/// Rescue meals use something expiring soon and need at most one extra
/// ingredient. Ready meals can be cooked with what you already have.
/// Stretch meals are weaker partial matches and stay below both.
enum RecommendBand { rescue, ready, stretch, none }

class ScoredRecipe {
  const ScoredRecipe({
    required this.recipe,
    required this.used,
    required this.missing,
    required this.urgentIds,
    required this.urgentCount,
    required this.score,
    required this.scoredAt,
    required this.soonestDays,
    required this.reason,
  });

  final Recipe recipe;
  final List<IngredientItem> used;
  final List<String> missing;
  final List<int> urgentIds;
  final int urgentCount;
  final int score;
  final DateTime scoredAt;
  final int? soonestDays;
  final String reason;

  bool get hasMatch => used.isNotEmpty;

  RecommendBand get band {
    if (!hasMatch) return RecommendBand.none;
    if (urgentCount > 0 && missing.length <= 1) return RecommendBand.rescue;
    if (missing.isEmpty) return RecommendBand.ready;
    return RecommendBand.stretch;
  }
}

class RecipeGroups {
  const RecipeGroups({
    required this.rescue,
    required this.ready,
    required this.stretch,
  });

  final List<ScoredRecipe> rescue;
  final List<ScoredRecipe> ready;
  final List<ScoredRecipe> stretch;

  bool get isEmpty => rescue.isEmpty && ready.isEmpty && stretch.isEmpty;
}

const sampleRecipes = <Recipe>[
  Recipe(
    id: 'egg-fried-rice',
    name: '계란볶음밥',
    category: RecipeCategory.rice,
    minutes: 12,
    summary: '찬밥이 있으면 대파·계란·굴소스로 마무리해요.',
    steps: '대파를 볶고 찬밥을 넣어 풀어줘요. 계란을 가장자리에 스크램블한 뒤 굴소스로 간해요.',
    ingredients: ['계란', '대파', '굴소스'],
  ),
  Recipe(
    id: 'kimchi-fried-rice',
    name: '김치볶음밥',
    category: RecipeCategory.rice,
    minutes: 12,
    summary: '익은 김치와 찬밥만 있어도 한 끼가 돼요.',
    steps: '김치를 먼저 볶아 신맛을 날리고 찬밥과 대파를 넣어요. 계란은 옆에 익혀 올려요.',
    ingredients: ['김치', '밥', '계란', '대파'],
  ),
  Recipe(
    id: 'bibimbap',
    name: '비빔밥',
    category: RecipeCategory.rice,
    minutes: 20,
    summary: '나물과 계란을 밥에 비비는 상차림.',
    steps: '시금치와 당근은 각각 무치고, 계란은 부쳐요. 밥 위에 올리고 고추장에 비벼요.',
    ingredients: ['밥', '계란', '시금치', '당근', '고추장'],
  ),
  Recipe(
    id: 'kongnamul-bap',
    name: '콩나물밥',
    category: RecipeCategory.rice,
    minutes: 20,
    summary: '콩나물과 밥을 한 냄비에 익혀요.',
    steps: '불린 쌀 위에 콩나물과 대파를 올리고 물을 잡아 끓여요. 간장은 비벼 먹어요.',
    ingredients: ['콩나물', '밥', '대파', '간장'],
  ),
  Recipe(
    id: 'gimbap',
    name: '김밥',
    category: RecipeCategory.rice,
    minutes: 25,
    summary: '계란, 햄, 단무지를 김에 마는 도시락.',
    steps: '밥에 소금만 약하게 간하고, 계란지단과 햄, 당근, 단무지를 올려 김으로 말아요.',
    ingredients: ['김', '밥', '계란', '단무지', '햄', '당근'],
  ),
  Recipe(
    id: 'janchi-guksu',
    name: '잔치국수',
    category: RecipeCategory.rice,
    minutes: 20,
    summary: '멸치국물에 소면과 애호박, 계란을 올려요.',
    steps: '멸치 육수에 간장을 타고 소면을 삶아요. 애호박, 대파, 계란지단을 얹어요.',
    ingredients: ['소면', '애호박', '계란', '대파', '간장'],
  ),
  Recipe(
    id: 'kalguksu',
    name: '칼국수',
    category: RecipeCategory.rice,
    minutes: 25,
    summary: '애호박과 감자를 넣어 끓이는 면.',
    steps: '멸치물에 감자, 애호박, 대파를 먼저 익히고 칼국수를 넣어 면이 퍼질 때까지 끓여요.',
    ingredients: ['칼국수', '애호박', '감자', '대파'],
  ),
  Recipe(
    id: 'omurice',
    name: '오므라이스',
    category: RecipeCategory.rice,
    minutes: 15,
    summary: '양파 볶음밥을 계란으로 감싸요.',
    steps: '양파와 찬밥을 케첩에 볶아요. 계란은 반숙으로 부쳐 밥을 덮어요.',
    ingredients: ['밥', '계란', '양파', '케첩'],
  ),
  Recipe(
    id: 'curry-rice',
    name: '카레라이스',
    category: RecipeCategory.rice,
    minutes: 25,
    summary: '감자, 당근, 양파를 무른 카레.',
    steps: '양파, 감자, 당근을 볶다가 물을 붓고 익혀요. 카레가루를 풀어 밥에 올려요.',
    ingredients: ['밥', '감자', '당근', '양파', '카레'],
  ),
  Recipe(
    id: 'tuna-mayo-rice',
    name: '참치마요덮밥',
    category: RecipeCategory.rice,
    minutes: 8,
    summary: '캔참치와 마요네즈를 밥에 얹는 야식.',
    steps: '참치는 기름을 빼고 마요네즈에 버무려요. 따뜻한 밥 위에 올리고 김을 부셔요.',
    ingredients: ['참치캔', '밥', '마요네즈', '김'],
  ),
  Recipe(
    id: 'bibim-guksu',
    name: '비빔국수',
    category: RecipeCategory.rice,
    minutes: 15,
    summary: '고추장 양념에 비비는 차가운 면.',
    steps: '소면을 삶아 찬물에 헹궈요. 고추장, 식초, 설탕을 풀고 오이, 계란을 올려요.',
    ingredients: ['소면', '고추장', '오이', '계란'],
  ),
  Recipe(
    id: 'egg-drop-soup',
    name: '대파계란국',
    category: RecipeCategory.soup,
    minutes: 10,
    summary: '물 끓이고 대파와 계란만 넣어요.',
    steps: '물을 끓여 대파를 먼저 넣고, 푼 계란을 저으며 부어요. 소금이나 굴소스가 있으면 간해요.',
    ingredients: ['대파', '계란'],
  ),
  Recipe(
    id: 'mandu-guk',
    name: '만두국',
    category: RecipeCategory.soup,
    minutes: 15,
    summary: '냉동만두를 끓이고 계란과 대파를 올려요.',
    steps: '물을 끓여 만두를 넣고 떠오를 때까지 끓여요. 대파를 올리고 계란을 풀어 한 번 더 끓여요.',
    ingredients: ['만두', '대파', '계란'],
  ),
  Recipe(
    id: 'kimchi-jjigae',
    name: '김치찌개',
    category: RecipeCategory.soup,
    minutes: 25,
    summary: '익은 김치와 돼지고기를 끓이는 집밥 찌개.',
    steps: '김치를 먼저 볶다가 물을 부어요. 돼지고기, 두부, 양파, 대파를 넣고 한소끔 끓여요.',
    ingredients: ['김치', '돼지고기', '두부', '대파', '양파'],
  ),
  Recipe(
    id: 'doenjang-jjigae',
    name: '된장찌개',
    category: RecipeCategory.soup,
    minutes: 20,
    summary: '된장에 두부와 애호박을 넣어 끓여요.',
    steps: '물에 된장을 풀고 양파, 애호박, 두부를 넣어요. 대파를 마지막에 올려요.',
    ingredients: ['된장', '두부', '애호박', '양파', '대파'],
  ),
  Recipe(
    id: 'sundubu-jjigae',
    name: '순두부찌개',
    category: RecipeCategory.soup,
    minutes: 15,
    summary: '부드러운 순두부에 계란을 톡 넣는 찌개.',
    steps: '양파와 대파를 볶아 물을 부어요. 순두부를 넣고 끓으면 계란을 깨 넣어요.',
    ingredients: ['순두부', '계란', '대파', '양파'],
  ),
  Recipe(
    id: 'budae-jjigae',
    name: '부대찌개',
    category: RecipeCategory.soup,
    minutes: 25,
    summary: '햄, 소시지, 김치를 한 냄비에 끓여요.',
    steps: '김치를 볶고 물을 부은 뒤 햄, 소시지, 두부를 넣어요. 대파를 얹어 마무리해요.',
    ingredients: ['햄', '소시지', '김치', '두부', '대파'],
  ),
  Recipe(
    id: 'miyeok-guk',
    name: '미역국',
    category: RecipeCategory.soup,
    minutes: 20,
    summary: '불린 미역과 소고기를 맑게 끓여요.',
    steps: '불린 미역과 소고기를 참기름에 볶다가 물을 부어요. 마늘을 넣고 소금으로 간해요.',
    ingredients: ['미역', '소고기', '마늘'],
  ),
  Recipe(
    id: 'sogogi-muguk',
    name: '소고기무국',
    category: RecipeCategory.soup,
    minutes: 30,
    summary: '무가 투명해질 때까지 끓이는 국.',
    steps: '소고기를 먼저 볶고 무, 마늘, 대파를 넣어요. 물을 부어 무가 익을 때까지 끓여요.',
    ingredients: ['소고기', '무', '대파', '마늘'],
  ),
  Recipe(
    id: 'eomuk-guk',
    name: '어묵국',
    category: RecipeCategory.soup,
    minutes: 15,
    summary: '어묵과 무를 간장 국물에 끓여요.',
    steps: '무를 먼저 끓이다가 어묵과 대파를 넣어요. 간장으로 간을 맞춰요.',
    ingredients: ['어묵', '대파', '무', '간장'],
  ),
  Recipe(
    id: 'tteokguk',
    name: '떡국',
    category: RecipeCategory.soup,
    minutes: 20,
    summary: '떡국떡을 맑은 장국에 올려요.',
    steps: '육수에 간장을 타고 떡을 넣어 떠오를 때까지 끓여요. 계란지단과 대파를 올려요.',
    ingredients: ['떡국떡', '계란', '대파', '간장'],
  ),
  Recipe(
    id: 'yukgaejang',
    name: '육개장',
    category: RecipeCategory.soup,
    minutes: 40,
    summary: '소고기와 고사리를 얼큰하게 끓여요.',
    steps: '소고기를 삶아 찢고 숙주, 대파와 고추장을 넣어 한 번 더 끓여요.',
    ingredients: ['소고기', '대파', '숙주', '고추장'],
  ),
  Recipe(
    id: 'onion-stir',
    name: '양파볶음',
    category: RecipeCategory.stir,
    minutes: 10,
    summary: '양파를 굴소스로 빠르게 볶아요.',
    steps: '양파를 채 썰어 팬에 볶다가 숨이 죽으면 굴소스를 둘러요. 밥 위에 얹어 먹어도 돼요.',
    ingredients: ['양파', '굴소스'],
  ),
  Recipe(
    id: 'aehobak-bokkeum',
    name: '애호박볶음',
    category: RecipeCategory.stir,
    minutes: 10,
    summary: '애호박과 양파를 소금간으로 볶아요.',
    steps: '애호박, 양파, 대파를 함께 볶다가 숨이 죽으면 소금으로 간해요.',
    ingredients: ['애호박', '양파', '대파'],
  ),
  Recipe(
    id: 'jeyuk-bokkeum',
    name: '제육볶음',
    category: RecipeCategory.stir,
    minutes: 20,
    summary: '돼지고기를 고추장에 달큰하게 볶아요.',
    steps: '돼지고기를 양파, 대파, 마늘과 볶다가 고추장을 넣어 윤기가 나게 조려요.',
    ingredients: ['돼지고기', '양파', '대파', '고추장', '마늘'],
  ),
  Recipe(
    id: 'bulgogi',
    name: '불고기',
    category: RecipeCategory.stir,
    minutes: 25,
    summary: '얇은 소고기를 간장 양념에 재워 구워요.',
    steps: '소고기를 간장, 양파, 대파, 당근에 재워요. 팬에 국물이 자작할 때까지 볶아요.',
    ingredients: ['소고기', '양파', '대파', '간장', '당근'],
  ),
  Recipe(
    id: 'dubu-kimchi',
    name: '두부김치',
    category: RecipeCategory.stir,
    minutes: 15,
    summary: '따뜻한 두부 옆에 볶은 김치를 붙여요.',
    steps: '두부는 노릇하게 굽고, 김치와 돼지고기, 대파를 따로 볶아 곁들여요.',
    ingredients: ['두부', '김치', '대파', '돼지고기'],
  ),
  Recipe(
    id: 'dak-bokkeumtang',
    name: '닭볶음탕',
    category: RecipeCategory.stir,
    minutes: 40,
    summary: '닭과 감자를 매콤한 양념에 조려요.',
    steps: '닭고기를 양파, 감자, 당근과 볶다가 고추장과 물을 넣고 걸쭉해질 때까지 졸여요. 대파를 올려요.',
    ingredients: ['닭고기', '감자', '당근', '양파', '대파', '고추장'],
  ),
  Recipe(
    id: 'samgyeopsal',
    name: '삼겹살구이',
    category: RecipeCategory.stir,
    minutes: 15,
    summary: '팬에 구운 삼겹살에 마늘과 파를 얹어요.',
    steps: '팬에 돼지고기를 노릇하게 구워요. 마늘, 대파, 양파를 옆에 같이 구워 먹어요.',
    ingredients: ['돼지고기', '마늘', '대파', '양파'],
  ),
  Recipe(
    id: 'godeungeo-gui',
    name: '고등어구이',
    category: RecipeCategory.stir,
    minutes: 15,
    summary: '소금 뿌린 고등어를 노릇하게 구워요.',
    steps: '고등어에 소금을 뿌려 수분을 닦아요. 팬에 껍질부터 중불로 구워요.',
    ingredients: ['고등어', '소금'],
  ),
  Recipe(
    id: 'sausage-veg',
    name: '소시지야채볶음',
    category: RecipeCategory.stir,
    minutes: 12,
    summary: '소시지에 양파와 당근을 섞어 볶아요.',
    steps: '소시지를 먼저 굴려 굽고 양파, 당근, 대파를 넣어 숨이 죽을 때까지 볶아요.',
    ingredients: ['소시지', '양파', '대파', '당근'],
  ),
  Recipe(
    id: 'beoseot-bokkeum',
    name: '버섯볶음',
    category: RecipeCategory.stir,
    minutes: 10,
    summary: '버섯을 간장에 빠르게 볶아요.',
    steps: '버섯을 먹기 좋게 찢어 양파, 대파와 볶아요. 간장을 한 숟갈 둘러요.',
    ingredients: ['버섯', '양파', '대파', '간장'],
  ),
  Recipe(
    id: 'tofu-jorim',
    name: '두부조림',
    category: RecipeCategory.side,
    minutes: 15,
    summary: '노릇하게 구운 두부에 굴소스와 대파를 얹어요.',
    steps: '두부는 도톰하게 썰어 팬에 구워요. 굴소스 1숟갈과 물을 조금 넣고, 송송 썬 대파를 올려 1분만 졸여요.',
    ingredients: ['두부', '대파', '굴소스'],
  ),
  Recipe(
    id: 'gyeran-jjim',
    name: '계란찜',
    category: RecipeCategory.side,
    minutes: 12,
    summary: '대파만 올리면 되는 짧은 계란찜.',
    steps: '계란을 풀고 물을 조금 넣어요. 대파를 얹어 약불로 찌거나 전자레인지에 2분 돌려요.',
    ingredients: ['계란', '대파'],
  ),
  Recipe(
    id: 'japchae',
    name: '잡채',
    category: RecipeCategory.side,
    minutes: 30,
    summary: '당면과 채소를 간장에 버무려요.',
    steps: '당면은 삶아 건지고, 시금치, 당근, 버섯, 양파는 각각 볶아요. 간장에 모두 버무려요.',
    ingredients: ['당면', '시금치', '당근', '버섯', '양파', '간장'],
  ),
  Recipe(
    id: 'sigeumchi-namul',
    name: '시금치나물',
    category: RecipeCategory.side,
    minutes: 10,
    summary: '데친 시금치를 간장에 무쳐요.',
    steps: '시금치를 소금물에 데쳐 물기를 짜요. 마늘과 간장으로 무쳐요.',
    ingredients: ['시금치', '마늘', '간장'],
  ),
  Recipe(
    id: 'kongnamul-muchim',
    name: '콩나물무침',
    category: RecipeCategory.side,
    minutes: 10,
    summary: '데친 콩나물에 파와 마늘을 넣어요.',
    steps: '콩나물을 뚜껑 덮어 데친 뒤 대파, 마늘, 소금으로 무쳐요.',
    ingredients: ['콩나물', '대파', '마늘'],
  ),
  Recipe(
    id: 'myeolchi-bokkeum',
    name: '멸치볶음',
    category: RecipeCategory.side,
    minutes: 10,
    summary: '잔멸치를 간장에 바삭하게 조려요.',
    steps: '멸치를 마른 팬에 볶아 비린내를 날려요. 간장, 마늘, 물엿이 있으면 조금 넣어 조려요.',
    ingredients: ['멸치', '마늘', '간장'],
  ),
  Recipe(
    id: 'gyeran-mari',
    name: '계란말이',
    category: RecipeCategory.side,
    minutes: 10,
    summary: '대파와 당근을 넣어 돌돌 마는 계란.',
    steps: '계란에 대파와 당근을 풀어 팬에 얇게 부쳐요. 가장자리부터 말아 썰어요.',
    ingredients: ['계란', '대파', '당근'],
  ),
  Recipe(
    id: 'gamja-jorim',
    name: '감자조림',
    category: RecipeCategory.side,
    minutes: 20,
    summary: '감자 모서리가 풀릴 때까지 간장에 졸여요.',
    steps: '감자를 깍둑 썰어 물을 조금 넣고 익혀요. 간장과 대파를 넣어 국물이 없어질 때까지 졸여요.',
    ingredients: ['감자', '간장', '대파'],
  ),
  Recipe(
    id: 'kimchi-jeon',
    name: '김치전',
    category: RecipeCategory.side,
    minutes: 15,
    summary: '잘 익은 김치로 부치는 전.',
    steps: '김치를 송송 썰어 부침가루와 대파를 섞어요. 팬에 노릇하게 앞뒤를 부쳐요.',
    ingredients: ['김치', '부침가루', '대파'],
  ),
  Recipe(
    id: 'oi-muchim',
    name: '오이무침',
    category: RecipeCategory.side,
    minutes: 10,
    summary: '아삭한 오이를 새콤하게 무쳐요.',
    steps: '오이는 소금에 절여 물기를 짜요. 양파, 고춧가루, 식초에 무쳐요.',
    ingredients: ['오이', '양파', '고춧가루', '식초'],
  ),
  Recipe(
    id: 'french-toast',
    name: '프렌치토스트',
    category: RecipeCategory.quick,
    minutes: 15,
    summary: '식빵을 계란·우유에 적셔 노릇하게 굽는 아침.',
    steps: '계란과 우유를 풀어 식빵을 적셔요. 팬에 약불로 앞뒤를 구워요. 설탕은 집에 있는 만큼만.',
    ingredients: ['식빵', '계란', '우유'],
  ),
  Recipe(
    id: 'ramyeon',
    name: '라면',
    category: RecipeCategory.quick,
    minutes: 8,
    summary: '대파와 계란을 올린 기본 라면.',
    steps: '물을 끓여 면과 스프를 넣어요. 대파를 올리고 계란은 반숙으로 얹어요.',
    ingredients: ['라면', '대파', '계란'],
  ),
  Recipe(
    id: 'tteokbokki',
    name: '떡볶이',
    category: RecipeCategory.quick,
    minutes: 15,
    summary: '어묵과 떡을 고추장에 조려요.',
    steps: '떡볶이떡을 물에 불리고 어묵, 대파와 고추장 양념을 넣어 걸쭉해질 때까지 끓여요.',
    ingredients: ['떡볶이떡', '어묵', '대파', '고추장'],
  ),
  Recipe(
    id: 'jumeokbap',
    name: '주먹밥',
    category: RecipeCategory.quick,
    minutes: 10,
    summary: '참기름과 김으로 쥐는 한 끼.',
    steps: '따뜻한 밥에 참기름과 소금을 넣고 김을 부셔 섞어요. 손에 물을 묻혀 동그랗게 쥐어요.',
    ingredients: ['밥', '참기름', '김', '소금'],
  ),
  Recipe(
    id: 'bread-pizza',
    name: '식빵피자',
    category: RecipeCategory.quick,
    minutes: 10,
    summary: '식빵 위에 케첩, 치즈, 햄을 올려 구워요.',
    steps: '식빵에 케첩을 바르고 햄과 치즈를 올려요. 치즈가 녹을 때까지 팬이나 오븐에 구워요.',
    ingredients: ['식빵', '케첩', '치즈', '햄'],
  ),
  Recipe(
    id: 'gunmandu',
    name: '군만두',
    category: RecipeCategory.quick,
    minutes: 12,
    summary: '냉동만두를 바닥만 바삭하게 구워요.',
    steps: '팬에 식용유를 두르고 만두를 올려요. 물을 조금 붓고 뚜껑을 덮었다가, 바닥이 노릇해지면 꺼내요.',
    ingredients: ['만두', '식용유'],
  ),
];


/// Higher means this ingredient should be cooked sooner.
int expiryPriority(int days) {
  if (days < 0) {
    final overdue = days.abs().clamp(1, 14);
    return 100 + overdue;
  }
  const near = <int>[72, 58, 46, 36, 26, 20, 14, 10];
  if (days < near.length) return near[days];
  if (days <= 14) return 4;
  return 0;
}

String expiryPhrase(String name, int days) {
  if (days < 0) return '$name ${-days}일 지남';
  if (days == 0) return '$name 오늘까지';
  if (days == 1) return '$name 내일까지';
  return '$name $days일 남음';
}

String recommendationReason({
  required List<IngredientItem> used,
  required List<String> missing,
  required List<IngredientItem> urgent,
  required DateTime now,
}) {
  if (used.isEmpty) return '가진 재료가 없어요';

  final urgentBySoonest = [...urgent]
    ..sort((a, b) {
      final byDays = daysUntil(
        a.expiryDate,
        now,
      ).compareTo(daysUntil(b.expiryDate, now));
      if (byDays != 0) return byDays;
      return a.name.compareTo(b.name);
    });
  final phrases = [
    for (final item in urgentBySoonest)
      expiryPhrase(item.name, daysUntil(item.expiryDate, now)),
  ];

  if (missing.isEmpty) {
    if (phrases.isEmpty) {
      return '가진 재료 ${used.length}개로 바로 만들 수 있어요';
    }
    return '${phrases.join(', ')}. 가진 재료로 바로 만들 수 있어요';
  }

  final gap = '없는 재료 ${missing.length}개 (${missing.join(', ')})';
  if (phrases.isEmpty) return '가진 재료 ${used.length}개 · $gap';
  return '${phrases.join(', ')}. $gap';
}

String matchedIngredientLabel({
  required String name,
  required ScoredRecipe scored,
}) {
  IngredientItem? match;
  for (final item in scored.used) {
    if (namesMatch(item.name, name)) {
      match = item;
      break;
    }
  }
  if (match == null) return '$name 없음';
  if (!scored.urgentIds.contains(match.id)) return name;
  return expiryPhrase(name, daysUntil(match.expiryDate, scored.scoredAt));
}

ScoredRecipe scoreRecipe({
  required Recipe recipe,
  required List<IngredientItem> stored,
  required DateTime now,
  required NotificationPrefs prefs,
}) {
  final pool = [...stored];
  final used = <IngredientItem>[];
  final missing = <String>[];
  for (final needed in recipe.ingredients) {
    IngredientItem? best;
    for (final item in pool) {
      if (!namesMatch(item.name, needed)) continue;
      if (best == null || item.expiryDate.isBefore(best.expiryDate)) {
        best = item;
      }
    }
    if (best == null) {
      missing.add(needed);
      continue;
    }
    used.add(best);
    pool.remove(best);
  }

  final urgentItems = <IngredientItem>[];
  for (final item in used) {
    final urgent = needsAttention(
      expiry: item.expiryDate,
      location: item.storageLocation,
      now: now,
      prefs: prefs,
    );
    if (urgent) urgentItems.add(item);
  }

  int? soonestDays;
  var score = 0;
  if (used.isEmpty) {
    score = -100;
  } else {
    for (final item in used) {
      final days = daysUntil(item.expiryDate, now);
      final current = soonestDays;
      if (current == null || days < current) soonestDays = days;
      // Owned food is worth using. Days left matter more than a headcount.
      score += expiryPriority(days) + 8;
    }
    if (missing.isEmpty) score += 36;
    score -= missing.length * 16;
  }

  return ScoredRecipe(
    recipe: recipe,
    used: used,
    missing: missing,
    urgentIds: [for (final item in urgentItems) item.id],
    urgentCount: urgentItems.length,
    score: score,
    scoredAt: now,
    soonestDays: soonestDays,
    reason: recommendationReason(
      used: used,
      missing: missing,
      urgent: urgentItems,
      now: now,
    ),
  );
}

List<ScoredRecipe> rankRecipes({
  required List<Recipe> recipes,
  required List<IngredientItem> stored,
  required DateTime now,
  required NotificationPrefs prefs,
}) {
  final active = stored
      .where((item) => item.status == IngredientStatus.stored)
      .toList();
  final ranked = [
    for (final recipe in recipes)
      scoreRecipe(recipe: recipe, stored: active, now: now, prefs: prefs),
  ];
  ranked.sort((a, b) {
    final byBand = a.band.index.compareTo(b.band.index);
    if (byBand != 0) return byBand;
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final aSoon = a.soonestDays ?? (1 << 20);
    final bSoon = b.soonestDays ?? (1 << 20);
    final bySoon = aSoon.compareTo(bSoon);
    if (bySoon != 0) return bySoon;
    final byMissing = a.missing.length.compareTo(b.missing.length);
    if (byMissing != 0) return byMissing;
    final byMinutes = a.recipe.minutes.compareTo(b.recipe.minutes);
    if (byMinutes != 0) return byMinutes;
    return a.recipe.name.compareTo(b.recipe.name);
  });
  return ranked;
}

RecipeGroups groupRecipes(List<ScoredRecipe> ranked) {
  return RecipeGroups(
    rescue: [
      for (final scored in ranked)
        if (scored.band == RecommendBand.rescue) scored,
    ],
    ready: [
      for (final scored in ranked)
        if (scored.band == RecommendBand.ready) scored,
    ],
    stretch: [
      for (final scored in ranked)
        if (scored.band == RecommendBand.stretch) scored,
    ],
  );
}

String recommendIntro({
  required RecipeGroups groups,
  required bool fridgeEmpty,
}) {
  if (fridgeEmpty) {
    return '재료를 담으면, 곧 상할 것부터 쓰는 메뉴를 골라 드려요.';
  }
  if (groups.isEmpty) {
    return '가진 재료와 겹치는 예시 메뉴가 없어요. 두부, 계란, 대파, 양파처럼 자주 담는 이름이면 맞아요.';
  }
  if (groups.rescue.isNotEmpty) {
    return '곧 상할 재료를 쓰는 메뉴를 위로 올렸어요.';
  }
  if (groups.ready.isNotEmpty) {
    return '임박한 재료는 없어요. 가진 것만으로 만들 수 있는 메뉴예요.';
  }
  return '바로 만들 메뉴는 없어요. 없는 재료가 적은 순으로 보여 드려요.';
}

List<ScoredRecipe> matchedRecipes(List<ScoredRecipe> ranked) {
  return [
    for (final scored in ranked)
      if (scored.hasMatch) scored,
  ];
}

List<Recipe> filterRecipes(
  List<Recipe> recipes, {
  String query = '',
  RecipeCategory? category,
}) {
  final needle = compactName(query);
  return [
    for (final recipe in recipes)
      if ((category == null || recipe.category == category) &&
          _recipeMatches(recipe, needle))
        recipe,
  ];
}

bool _recipeMatches(Recipe recipe, String needle) {
  if (needle.isEmpty) return true;
  if (compactName(recipe.name).contains(needle)) return true;
  if (compactName(recipe.summary).contains(needle)) return true;
  if (compactName(recipe.category.label).contains(needle)) return true;
  for (final ingredient in recipe.ingredients) {
    if (compactName(ingredient).contains(needle)) return true;
  }
  return false;
}

String recipeGapLabel(ScoredRecipe scored) {
  if (scored.missing.isEmpty) return '재료가 다 있어요';
  return '없는 재료 ${scored.missing.length}개 · ${scored.missing.join(', ')}';
}
