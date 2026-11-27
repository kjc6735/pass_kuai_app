# Model

> 2026-11-19 정리 반영
> - 이름·위치: API 모델 `Word` → `WordAnalysis`, `lib/mapper/word_mapper.dart` 추가, DB 폴더 `lib/table/` → `lib/database/`
> - 버그 수정: `syllables`를 drift `TypeConverter`(`SyllablesConverter`)로 변경하고 깨진 값은 로그 + debug assert(옛 깨진 데이터는 v7 마이그레이션에서 삭제), 서버가 분석 결과를 검증(422 + 한국어 메시지), 저장 실패 문구(`lib/api/save_error.dart`)

이 앱에서 "모델"이라 부를 만한 것은 두 종류입니다.

1. **API 모델** (`lib/model/`): 서버 JSON 응답을 담는 손으로 쓴 불변 클래스. `fromJson`만 있고(예외: `Syllable.toJson`), 코드 생성(json_serializable, freezed)은 쓰지 않습니다. DB(drift)를 import하지 않습니다.
2. **DB 행 클래스** (`lib/database/database.g.dart`): drift가 생성한 `Word`, `Sentence`, `SavedWord` 등. 저장된 단어장·학습 화면에서는 이것이 그대로 화면 모델 역할을 합니다.

두 세계를 잇는 코드는 두 곳에 있습니다.
- **`lib/mapper/word_mapper.dart`**: API 모델 ↔ DB 행/Companion 필드 매핑(extension)
- **`lib/database/converters/syllables_converter.dart`**: `syllables` 컬럼의 JSON ↔ `List<Syllable>` 변환(drift `TypeConverter`)

관련 문서: [repository.md](repository.md) · [provider.md](provider.md) · [router.md](router.md) · [table.md](table.md)

---

## 1. API 모델

### 1-1. `analyze_result.dart` — 문장 분석 결과

`POST /analyze/sentence` 응답. 구조는 `AnalyzeResult → SentenceAnalysis[] → WordAnalysis[] → Syllable[]` 4단 중첩입니다.

| 클래스 | 필드 | 서버 타입 (`src/analyze/types/analyze.result.ts`) |
|---|---|---|
| `AnalyzeResult` (`lib/model/analyze_result.dart:1`) | `List<SentenceAnalysis> sentences` | `AnalyzeResult { sentences: SentenceAnalysis[] }` |
| `SentenceAnalysis` (`:14`) | `String sentence`, `String translation`, `List<WordAnalysis> words` + getter `pinyin` (`:36`) | `SentenceAnalysis` |
| `WordAnalysis` (`:39`) | `String text`, `String pinyin`, `String meaning`, `String? pos`, `List<Syllable> syllables` | `Word`, `pos?: string` 은 선택 필드 |
| `Syllable` (`:68`) | `String hanzi`, `String pinyin`, `int tone` | `Syllable { hanzi, pinyin, tone: number }` |

필드 이름은 서버 인터페이스와 1:1로 같습니다. **클래스 이름만** 서버 `Word` ↔ 앱 `WordAnalysis` 로 다릅니다(drift `Word` 와 겹치지 않게, 같은 파일의 `SentenceAnalysis` 와 짝을 맞춤).

`SentenceAnalysis.pinyin` 은 `words.map((w) => w.pinyin).join(' ')` 입니다. DB `sentences.pinyin` 에 저장되는 값이고, 서버도 같은 규칙으로 계산해 길이를 검사합니다. **이 규칙은 이 getter 한 곳에만** 둡니다.

**파싱 방식** (모든 `fromJson` 공통 패턴):

```dart
json['x'] as String? ?? ''                      // 없으면 빈 문자열
(json['list'] as List<dynamic>? ?? []).map((e) => X.fromJson(e as Map<String, dynamic>))
(json['tone'] as num?)?.toInt() ?? 0            // 숫자는 num으로 받아 변환
```

- 필드가 빠지거나 null이어도 예외 없이 기본값(`''`, `[]`, `0`)으로 채웁니다. `pos`만 nullable 그대로 둡니다.
- 리스트 원소가 Map이 아니면 `e as Map<String, dynamic>` 에서 예외가 납니다(관대한 것은 null/누락뿐).
- 이제 서버가 형식을 먼저 검증하므로(1-3절) 정상 경로에서는 기본값이 쓰일 일이 거의 없습니다. `fromJson` 의 관대함은 옛 서버나 예외 상황용 방어입니다.
- `tone` 0은 경성으로 쓰입니다(`lib/theme/app_colors.dart:31` `toneColor`, 범례 `lib/screens/analyze/sentence_detail_screen.dart:127` `_ToneLegend`).
- `Syllable.toJson()` (`:87`)은 **DB 저장용**으로만 존재합니다(`SyllablesConverter.toSql`).

### 1-2. `pronunciation_result.dart` — 발음 평가 결과

`POST /stt/transcribe` (multipart) 응답.

| 클래스 | 필드 | 서버 타입 |
|---|---|---|
| `PronunciationResult` (`lib/model/pronunciation_result.dart:1`) | `String text`, `PronunciationComparison? comparison` | `TranscribeResult { text; comparison? }` (`src/stt/stt.service.ts:8`) |
| `PronunciationComparison` (`:19`) | `List<SyllableMatch> syllables`, `double matchRate`, `int extraCount` | `PronunciationComparison` (`src/stt/compare.ts:12`) |
| `SyllableMatch` (`:43`) | `String hanzi`, `String pinyin`, `bool matched` | `SyllableResult` (`src/stt/compare.ts:6`) |

- 서버는 `target` 이 있을 때만 `comparison` 을 넣습니다(`stt.service.ts:37-39`). 클라이언트는 `c is Map<String, dynamic>` 로 검사해 없으면 `null` (`pronunciation_result.dart:12-14`).
- 서버 `PronunciationComparison` 의 `target`, `recognized` 필드는 **클라이언트 모델에 없습니다**(무시됨).
- 이름 차이: 서버 `SyllableResult` ↔ 앱 `SyllableMatch`.
- `matchRate` 는 0~1 (`compare.ts:16`), 화면에서 `*100` 해 퍼센트로 표시(`lib/screens/practice/pronunciation_screen.dart:330`).
- `extraCount` 는 "목표에 없는데 더 말한 음절 수" (`compare.ts:17`).

### 1-3. 서버의 분석 결과 검증 (앱과의 계약)

서버(`pass_kuai_server/src/analyze/analyze-result.validator.ts`)는 LLM 출력을 앱에 돌려주기 전에 검증합니다.

| 대상 | 서버 상한 (`ANALYZE_RESULT_LIMITS`) | 앱 DB 상한 (최후 방어선, [table.md](table.md)) |
|---|---|---|
| 문장 원문 | 1000 | 1000 |
| 문장 번역 | 4000 | 4000 |
| 문장 병음(단어 병음 join) | 8000 | 8000 |
| 단어 text | 50 | 50 |
| 단어 pinyin / meaning | 200 / 200 | 200 / 200 |
| pos | 50 | 제한 없음 |
| 음절 hanzi / pinyin | 10 / 50 | (JSON 안이라 검사 없음) |
| 그 밖 | 모든 문자열 앞뒤 공백 제거 후 빈 값 금지(pos는 선택), `tone` 0~4 정수, 문장마다 단어 1개 이상 | 모든 문자열 최소 1자 |

- 서버 상한은 앱 상한과 **같거나 더 엄격**해야 합니다. 한쪽을 바꾸면 다른 쪽도 확인하세요.
- 검증 실패 시 `422 { statusCode, error, message }`. `message`는 한국어이고 앱의 `friendlyErrorMessage`(`lib/api/api_error.dart`)가 그대로 보여 줍니다.
  - 길이·개수 초과만: "분석 결과가 너무 길어 처리하지 못했어요. 문장을 나눠서 다시 시도해 주세요."
  - 형식 오류(누락, 타입, 빈 값, tone)가 섞임: "분석 결과를 제대로 만들지 못했어요. 잠시 후 다시 시도해 주세요."
- 서버는 앞뒤 공백 제거와 빈 `pos` 제거만 정규화하고, 자르기(truncate)는 하지 않습니다. 실패는 자동 재시도 없이 바로 422입니다.

---

## 2. 누가 만들고 누가 쓰나

### 생성 (JSON → 모델)

| 모델 | 생성 위치 |
|---|---|
| `AnalyzeResult` | `lib/repository/analyze_repository.dart` `AnalyzeResult.fromJson(res.data)` |
| `PronunciationResult` | `lib/repository/stt_repository.dart` `PronunciationResult.fromJson(res.data ?? const {})` |
| `AnalyzeResult` 빈 초기값 | `lib/screens/analyze/analyze_home_screen.dart:26` `const AnalyzeResult(sentences: [])` |
| `SentenceAnalysis`/`WordAnalysis` (DB에서 복원) | `lib/service/sentence_service.dart:84` `loadAnalysis` → mapper `toAnalysis()` |
| `List<Syllable>` (DB에서 복원) | `SyllablesConverter.fromSql` — drift가 행을 읽을 때 자동 호출. `Word.syllables` 가 이미 `List<Syllable>` |

### 사용

| 위치 | 사용 내용 |
|---|---|
| `lib/screens/analyze/analyze_home_screen.dart:42-45` | `repo.analyzeSentence()` 결과를 state `_analyzeResult` 에 저장 |
| `analyze_home_screen.dart:127-134` | `sentences` 를 `SentenceRow` 로 나열, 탭 시 `SentenceAnalysis` 를 `extra` 로 상세 화면에 전달 |
| `lib/screens/analyze/sentence_detail_screen.dart:23` | `extra` 를 `SentenceAnalysis` 로 타입 검사 |
| `sentence_detail_screen.dart:30, 53-59` | 모든 단어의 `syllables` 를 펼쳐 성조 색으로 병음/한자 표시 |
| `sentence_detail_screen.dart:185-228` | `_SaveSentenceButton` — `vocabService.saveSentence(data)` (연타 방지, 실패 스낵바) |
| `sentence_detail_screen.dart:166-283` | `_WordRow` 가 `WordAnalysis` 를 받아 `WordRow` 컴포넌트에 원시값으로 풀어 전달, `vocabService.saveWord(word)` 호출 |
| `lib/service/vocab_service.dart:27, 40` | `saveWord(WordAnalysis)`, `saveSentence(SentenceAnalysis)` |
| `lib/service/sentence_service.dart:51, 84` | `createSentence(SentenceAnalysis)`, `loadAnalysis(Sentence)` |
| `lib/screens/practice/pronunciation_screen.dart:40, 115-119` | `PronunciationResult? _result` 에 저장 |
| `pronunciation_screen.dart:254-290` | `comparison` null 여부로 결과 UI 분기, `syllables`/`extraCount` 표시 |
| `pronunciation_screen.dart:313` (`_ScoreHeader`), `:387` (`_SyllableChip`) | `PronunciationComparison`, `SyllableMatch` 를 직접 받는 위젯 |

**components는 모델을 모릅니다.** `lib/components/word_row.dart`, `lib/components/sentence_row.dart` 는 `String text/pinyin/meaning`, `List<Color>? charColors` 같은 원시값만 받습니다. 그래서 API 모델(`WordAnalysis.text/meaning`)과 drift 행(`Word.word/translation`) 양쪽에서 같은 컴포넌트를 씁니다(`sentence_detail_screen.dart:263`, `vocab_screen.dart:153` `_SavedWordList`).

---

## 3. API 모델 ↔ DB 행 변환

DB 스키마 자체는 [table.md](table.md) 참고.

### 필드 대응

| API 모델 `WordAnalysis` | drift `Word` / `Words` 테이블 (`lib/database/tables/words_table.dart`) |
|---|---|
| — | `int id` |
| `text` | `word` |
| `meaning` | `translation` |
| `pinyin` | `pinyin` |
| `pos` | `pos` (nullable) |
| `List<Syllable> syllables` | `List<Syllable> syllables` (SQL에서는 JSON TEXT, 기본값 `'[]'`, `SyllablesConverter`) |

| API 모델 `SentenceAnalysis` | drift `Sentence` |
|---|---|
| — | `int id`, `DateTime createdAt` |
| `sentence` | `sentence` (유니크. 같은 문장의 기준) |
| `translation` | `translation` |
| getter `pinyin` (단어 병음을 공백으로 join) | `pinyin` |
| `List<WordAnalysis> words` | 별도 테이블 `SentenceWords(sentenceId, position, wordId)` 로 순서대로 연결 |

**필드 이름이 다릅니다**: `text`↔`word`, `meaning`↔`translation`. 이 매핑은 mapper에만 적혀 있습니다.

### mapper 구성 (`lib/mapper/word_mapper.dart`)

```dart
extension WordRowMapper on Word {             // drift 행 → API 모델
  WordAnalysis toAnalysis();                  // :7
}

extension WordAnalysisMapper on WordAnalysis { // API 모델 → drift Companion
  WordsCompanion toCompanion();               // :17
}
```

JSON 처리는 mapper에 없습니다. `syllables` 는 양쪽 모두 `List<Syllable>` 이라 그대로 넘기고, JSON 변환은 converter가 맡습니다.

`Companion` 은 drift가 테이블마다 만드는 insert/update용 클래스입니다. 각 필드를 `Value(...)` 로 감싸며, 생략한 필드(`id` 등)는 `Value.absent()` 라서 DB 기본값/자동 증가가 적용됩니다.

### `SyllablesConverter` (`lib/database/converters/syllables_converter.dart`)

```dart
class SyllablesConverter extends TypeConverter<List<Syllable>, String> {
  static List<Syllable> parse(String raw); // 해석, 깨져 있으면 예외
  static bool isValid(String raw);        // v7 마이그레이션에서 깨진 값 찾기
  List<Syllable> fromSql(String fromDb);   // parse, 실패 시 onDecodeError 후 []
  String toSql(List<Syllable> value);      // jsonEncode(toJson 목록)
  static SyllablesDecodeErrorHandler onDecodeError;  // 기본값 defaultOnDecodeError
}
```

**깨진 값 처리.** 옛 버전에서 깨진 채 저장된 값은 v7 마이그레이션이 `'[]'`로 지웠습니다(단어 행은 유지, [table.md](table.md) 5.2). 지금 `syllables`에 쓰는 경로는 `toSql` 하나뿐이라, 앞으로 깨지는 경우는 버그나 직접 DB 수정 정도입니다. 피해는 "성조 색이 안 나옴"뿐이므로 화면을 죽이지 않되, 조용히 넘기지도 않습니다.
- `defaultOnDecodeError`(`:23`): `debugPrint`로 원본 값과 에러를 남기고 `assert(false, ...)`.
- **debug 빌드**: assert가 터져 개발자가 바로 알 수 있습니다. 이때 그 행을 읽는 쿼리 전체가 실패합니다(의도된 동작).
- **release 빌드**: assert가 빠져 빈 리스트로 계속 동작합니다(성조 색만 없음).
- 테스트에서 깨진 값을 일부러 읽을 때는 `SyllablesConverter.onDecodeError`를 바꿔 끼우고 tearDown에서 `defaultOnDecodeError`로 되돌립니다(`test/word_mapper_test.dart`).

### 저장 방향 (API 모델 → DB)

- `lib/service/sentence_service.dart:51-82` `createSentence` (get-or-insert)
  - 같은 원문(`findIdBySentence`)이 이미 있으면 그 id를 돌려주고 아무것도 쓰지 않음
  - 없으면 `SentencesCompanion(pinyin: Value(analysis.pinyin), ...)` insert → 각 단어 `w.toCompanion()` 을 `insertIfAbsent` → `sentence_words` 에 `position`(단어 목록 인덱스)과 함께 insert
- `lib/service/vocab_service.dart:27-32` `saveWord` — `wordRepository.insertIfAbsent(word.toCompanion())` 후 `savedWordRepository.save`
- `lib/service/vocab_service.dart:40-49` `saveSentence` — 트랜잭션 하나로 `findIdBySentence` → 없으면 `createSentence` → `save`

길이 상한을 넘으면 drift가 SQL을 보내기 전에 `InvalidDataException`을 던지고 트랜잭션 전체가 롤백됩니다. 화면은 이를 `friendlySaveErrorMessage`(`lib/api/save_error.dart`)로 바꿔 스낵바에 보여 줍니다.
- `InvalidDataException`: "내용이 너무 길거나 비어 있어서 저장하지 못했어요."
- 그 밖: "저장하지 못했어요. 잠시 후 다시 시도해 주세요."
- 네트워크용 `friendlyErrorMessage`와 따로 둔 이유: 로컬 저장 실패에 "인터넷 연결" 문구가 섞이면 안 되고, API 쪽이 drift를 알 필요도 없기 때문입니다.

### 복원 방향 (DB → API 모델)

- `lib/service/sentence_service.dart:84-93` `loadAnalysis(Sentence)`: `findWordsBySentenceId` 로 drift `Word` 목록을 **position 순서대로** 읽고 `toAnalysis()` 로 바꿔 `SentenceAnalysis` 를 조립합니다. 같은 단어가 두 번 나오는 문장도 원래대로 복원됩니다.
- 호출: `lib/screens/vocab/vocab_screen.dart:224-228` — 저장된 문장을 탭하면 `loadAnalysis` 결과를 상세 화면으로 `extra` 전달.
  → **상세 화면은 항상 API 모델만 받고**, 저장 문장도 API 모델로 되돌려서 같은 화면을 재사용합니다.
- `lib/screens/study/study_screen.dart:264`: 플래시카드 `_CardFace` 는 drift `Word` 를 그대로 받고 `word.syllables` 를 성조 색에 씁니다.

### drift 행이 그대로 모델로 쓰이는 곳

- `savedWordsProvider` → `Future<List<Word>>` (`lib/provider/saved_words_provider.dart:5`) → `vocab_screen.dart` `_SavedWordList`
- `savedSentencesProvider` → `Future<List<Sentence>>` (`lib/provider/saved_sentences_provider.dart:5`) → `vocab_screen.dart` `_SavedSentenceList`
- `StudySession(List<Word>)` (`lib/service/study_service.dart:5-27`) → `study_screen.dart` `_CardFace(word: Word)` (`:259`)

`SavedWord`(srsLevel, nextReviewAt 등)와 `SavedSentence` 행은 repository 안에서만 쓰이고 화면에는 `Word`/`Sentence` 만 올라옵니다.

---

## 4. go_router `state.extra` 로 모델 넘기기

라우트 정의 자체는 [router.md](router.md) 참고.

| 라우트 | 빌더 (`lib/router/router.dart`) | 보내는 쪽 | extra 타입 | 받는 쪽 검사 |
|---|---|---|---|---|
| `sentenceDetail` (`/detail`) | `:90` `SentenceDetailScreen(sentence: state.extra)` | `analyze_home_screen.dart:131-134`, `vocab_screen.dart:228` | `SentenceAnalysis` | `sentence_detail_screen.dart:23` `if (data is! SentenceAnalysis)` → "문장 정보가 없어요" |
| `practice` (`/practice`) | `:97` `PronunciationScreen(target: state.extra)` | `sentence_detail_screen.dart:92-95` | `String` (`data.sentence`) | `pronunciation_screen.dart:42` `widget.target is String ? ... : ''`, `:141` 빈 문자열이면 안내 UI |

두 화면 모두 생성자 파라미터를 `Object?` 로 받고 화면 안에서 `is` 로 검사합니다. 객체를 메모리로 넘기는 방식이라 직렬화는 없고, 앱 재시작·딥링크로 진입하면 extra가 없어 "정보 없음" 화면이 됩니다.

---

## 5. 헷갈릴 만한 부분

### 정리됨 (2026-11-19)

- ~~`Word` 이름 충돌~~ → API 모델을 `WordAnalysis` 로 바꿔 해결. 한 파일에 `Word` 는 drift 것 하나만 있습니다. (drift 쪽을 `@DataClassName` 으로 바꾸지 않은 이유: 생성 코드 전체 이름이 바뀌어 영향 범위가 큼.)
- ~~변환 코드 중복~~ → 필드 매핑은 mapper, pinyin join 은 `SentenceAnalysis.pinyin`, JSON 은 `SyllablesConverter` 한 곳씩.
- ~~`syllables` 는 DB에선 그냥 `String`, 디코드 코드가 여러 곳~~ → `TypeConverter` 로 `List<Syllable>` 노출. 깨진 값은 로그 + debug assert, release 에서는 빈 리스트.
- ~~복원 시 단어 순서/중복~~ → `sentence_words.position` 으로 순서 보장, 같은 단어 반복 가능.
- ~~서버가 LLM 출력을 검증 없이 그대로 반환~~ → 서버 검증 + 422 한국어 메시지(1-3절).
- ~~저장 실패 시 안내 없음~~ → `friendlySaveErrorMessage` 스낵바.

### 남아 있는 것 (메모만)

1. **`Object?` extra + 런타임 `is` 검사.** 잘못된 타입을 넘겨도 컴파일러가 못 잡고, 화면은 조용히 "정보 없음"/빈 target으로 동작합니다.
2. **`res.data` 타입.** `AnalyzeRepository.analyzeSentence` 는 `dio.post` 에 제네릭이 없어 `res.data` 가 `dynamic` → `fromJson(Map<String, dynamic>)` 에 암시적 캐스팅(Map이 아니면 런타임 에러). 반면 `SttRepository` 는 `post<Map<String, dynamic>>` + `?? const {}`.
3. **서버 검증이 실제 LLM 출력을 막을 수 있음.** 숫자·영문 토큰의 음절 pinyin 이 비어 있거나 `tone` 5(경성 표기 혼동)가 오면 422가 됩니다. 배포 후 서버 로그(`invalid analyze result`) 빈도를 보고 규칙을 조정하는 게 좋습니다. 형식 오류는 의미상 서버 쪽 오류인데 4xx로 집계된다는 점도 참고.
4. **서버 필드 일부 무시.** STT 응답의 `comparison.target`, `comparison.recognized` 는 파싱하지 않습니다. 서버의 `lookupWord` 엔드포인트(`pass_kuai_server/src/analyze/analyze.controller.ts`)를 쓰는 클라이언트 코드는 없습니다.
5. **`fromJson` 은 관대, 화면은 길이 비교로 방어.** 음절 수와 글자 수가 다르면 색을 포기합니다(`sentence_detail_screen.dart:259-261`, `study_screen.dart:266` 의 `colored` 판정). 저장된 단어 목록(`_SavedWordList`)은 `charColors` 를 넘기지 않아 성조 색이 없습니다.
6. **`toJson` 비대칭.** `Syllable` 에만 `toJson` 이 있고 나머지 클래스에는 없습니다. `==`/`hashCode`/`copyWith` 도 없습니다(drift 클래스에는 생성되어 있음).

---

## 6. 새 모델 추가 패턴

1. `lib/model/<기능>_result.dart` 에 `const` 생성자 + `final` 필드 클래스를 만들고, 서버 TS 인터페이스와 **같은 필드 이름**을 씁니다. 클래스 이름이 drift 행 클래스(`Word`, `Sentence` …)와 겹치면 `XxxAnalysis`/`XxxResult` 처럼 접미사를 붙여 피합니다(import 접두사로 피하지 않음).
2. `factory X.fromJson(Map<String, dynamic> json)` 에서 `as T? ?? 기본값`, 리스트는 `as List<dynamic>? ?? []` 후 `.map(fromJson)`, 숫자는 `as num?` 후 `toInt()/toDouble()`, 선택 객체는 `is Map<String, dynamic>` 검사.
3. API 호출은 `lib/repository/<기능>_repository.dart` 에서 `Dio` 응답을 받아 `X.fromJson(res.data ...)` 로 반환합니다. provider는 `lib/provider/` 에 따로 둡니다([provider.md](provider.md)). LLM 출력처럼 믿을 수 없는 응답이면 서버에서 먼저 검증하고(1-3절 방식), 서버 상한 ≤ 앱 DB 상한을 지킵니다.
4. DB에 저장해야 하면: 테이블에 컬럼 추가([table.md](table.md)) → 중첩 리스트는 `toJson` 을 만들고 `TypeConverter`(`SyllablesConverter` 참고)로 TEXT 컬럼에 저장 → 모델 ↔ Companion/행 필드 매핑은 `lib/mapper/` 에 extension으로 추가하고 service에서 호출.
5. 화면 간 전달은 `context.pushNamed(name, extra: model)` + 받는 화면에서 `Object?` 를 `is X` 로 검사하는 기존 방식.
