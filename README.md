# 남김없이

입력은 간편하게, 식재료는 남김없이.

혼자 사는 사람이 냉장·냉동·상온 재료를 적게 입력하고 기한 안에 쓰도록 돕는 Flutter 앱이다. 기획서 원문은 `docs/namgim-plan-simple.txt`와 `docs/namgim-eopsi-plan.pdf`에 있다. 패키지 이름은 `namgim_eopsi`이다.

## 실행

Flutter stable이 필요하다. 이 저장소는 Flutter 3.47.9 / Dart 3.13.7에서 확인했다.

```bash
flutter pub get
flutter run
```

웹으로 보려면 `web/sqlite3.wasm`과 `web/drift_worker.js`가 필요하다. 둘 다 저장소에 들어 있다.

```bash
flutter run -d chrome
# 또는
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 43123
```

디버그 웹은 CanvasKit을 CDN에서 받는다. 그 주소가 막혀 흰 화면이면 `--no-web-resources-cdn`을 붙인다.

Drift 스키마를 바꾼 뒤에만 코드를 다시 생성한다. 생성된 `*.g.dart`는 커밋되어 있어서 처음 실행에는 필요 없다.

```bash
dart run build_runner build --delete-conflicting-outputs
```

확인:

```bash
flutter analyze
flutter test
```

Android 애플리케이션 ID는 `kr.namgim.namgim_eopsi`이다. 첫 실행에는 계란, 우유, 두부, 대파를 포함한 즐겨찾기와 데모 재료가 들어 있다. 데모 재료는 밀어서 먹음/버림으로 지울 수 있다.

## 구조

화면은 상태를 직접 저장하지 않는다. Riverpod이 Drift 스트림을 구독하고, 저장은 리포지토리만 한다.

```
lib/features   화면 (홈, 식재료, 추가, 추천, 레시피, 설정)
lib/providers  Riverpod. 데이터베이스와 리포지토리를 연결
lib/data/repositories
lib/data/daos
lib/data/db    Drift 테이블, 마이그레이션, 시드
lib/domain     보관 장소, 기한 계산, 개봉, 레시피 정렬
```

하단 탭은 홈, 식재료, 추천, 레시피, 설정이다. 추천은 냉장고와 겹치는 메뉴만 임박한 재료 순으로 올리고, 레시피는 샘플 메뉴 전체를 검색·분류로 본다. 재료 추가는 탭 위의 전체 화면이다.

## 데이터

Drift + SQLite. 기기에만 저장하고 계정은 없다.

- `Ingredients`: 이름, 수량, 보관 장소(냉장/냉동/상온), 유통기한, 개봉 여부, 개봉 시각, 상태(보관/먹음/버림), 만든 시각
- `Favorites`: 이름, 기본 보관 장소, 기본 보관 일수
- `ShelfLifeDefaults`: 이름 키워드, 분류, 보관 장소, 기본 일수, 개봉 후 일수, 개봉 후 냉장 안내
- `NotificationSettings`: 알림 시각과 보관 장소별 시점. 홈의 임박 기준도 이 값을 쓴다

기본 보관 일수는 자취 기준으로 넣은 초안이다. 1주차에 조사한 숫자로 바꿔도 화면 코드는 그대로 둔다.

## 지금 되는 것

기획서 3–4주차에 해당하는 흐름이다.

- 즐겨찾기 칩을 누르면 보관 장소와 유통기한이 채워져 바로 등록된다
- 이름을 입력하면 `ShelfLifeDefaults`에서 기한과 보관 장소를 제안한다
- 식재료 목록은 전체/냉장/냉동/상온, 유통기한 빠른 순, 임박 색
- 밀거나 버튼으로 먹음/버림. 스낵바에서 되돌릴 수 있다
- 개봉을 누르면 개봉 후 기한으로 다시 계산한다. 굴소스처럼 개봉 후 냉장이 필요한 재료는 옮길지 묻는다
- 추천 탭은 네트워크 없이 예시 메뉴 중 냉장고와 겹치는 것만 보여 주고, 임박 재료를 쓰는 메뉴를 위로 올린다. 요리 후 쓴 재료를 한 번에 먹음으로 정리할 수 있다
- 레시피 탭은 샘플 집밥 전체를 이름·재료·분류로 둘러본다. 없는 재료 개수도 같이 보여 준다
- 설정에서 알림 시각과 냉장/냉동 3일+당일, 상온 14일+7일 시점을 저장한다

바코드, 날짜 촬영 버튼은 눌러지지 않는다. 6주차용 자리다.

## 다음 작업

알림은 플러그인만 초기화한다. 예약은 하지 않는다.

- 5주차: `workmanager`로 하루에 한 번 기한을 확인하고, `flutter_local_notifications`로 보관 장소별 알림을 예약한다. 알림의 먹음/버림은 앱을 열지 않고 처리한다. Android 매니페스트에는 예약용 receiver를 미리 넣어 두었다. 코드의 TODO는 `lib/services/notification_service.dart`에 있다.
- 6주차: ML Kit 바코드(GS1 날짜)와 포장지 날짜 OCR. 둘 다 실패하면 지금처럼 기본 기한으로 채운다.
- 7주차: `home_widget`으로 홈 화면에서 임박 재료를 보고 즐겨찾기를 담는다. 추천은 지금 예시 목록을 실제 레시피로 바꿀 자리이다.
- 8주차: 사용 테스트와 발표.

2단계 계정/서버, 3단계 나눔은 이 과제의 범위 밖이다.

## 글꼴

IBM Plex Sans KR (SIL Open Font License). 라이선스 전문은 `licenses/IBMPlexSansKR-OFL.txt`이다. 웹 캔버스에서도 한글이 보이도록 앱에 포함했다.
