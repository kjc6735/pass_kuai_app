# Repository 계층

> 이 프로젝트의 repository를 어떻게 쓰고 있는지 정리한 문서입니다. 모든 내용은 실제 코드에서 확인했고, 참조는 `파일경로:줄번호` 형식입니다.
> 2026-11-19 정리 반영
> - 이름·위치: 메서드 이름 규칙 통일, `SentenceWordsRepository` → `SentenceWordRepository`, API repository를 `lib/repository/` 로 이동, 미사용 `insert` 삭제
> - 버그 수정: 같은 단어가 두 번 나오는 문장 저장 실패(`position` 도입), 단어 순서 보장, 문장 저장 경쟁 상태(트랜잭션), "같은 문장 = 원문이 같은 문장"(유니크 키 + `findIdBySentence`)
>
> 관련 문서: [table.md](./table.md) (Drift 테이블 스키마), [model.md](./model.md) (`AnalyzeResult`/`SentenceAnalysis`/`WordAnalysis` 같은 API 모델), [provider.md](./provider.md) (Riverpod provider 구성), [router.md](./router.md) (화면 이동)

---

## 1. 역할: 두 종류의 repository

repository는 "데이터를 어디서 가져오는가"를 숨기는 계층입니다. 성격이 다른 두 그룹이 있고, 둘 다 `lib/repository/` 에 있습니다.

| 구분 | 클래스 | 의존성 | 하는 일 |
|---|---|---|---|
| **로컬 DB (Drift/SQLite)** | `SentenceRepository`, `WordRepository`, `SentenceWordRepository`, `SavedWordRepository`, `SavedSentenceRepository` | `AppDatabase` (`dbProvider`) | 테이블 하나의 CRUD와 조인 조회 |
| **서버 API (Dio)** | `AnalyzeRepository`, `SttRepository` | `Dio` (`dioProvider`, 인증 인터셉터 포함) | HTTP 호출 한 번 하고 JSON을 모델로 변환 |

provider 선언은 전부 `lib/provider/<이름>_repository_provider.dart` 에 따로 있습니다([provider.md](./provider.md)).

공통 규칙(DB 계열):
- 필드 `final AppDatabase database;` + `late final $XxxTable table;` → 빈 줄 → 생성자 `({required this.database})` 에서 `table = database.<테이블>` 지정 (예: `lib/repository/word_repository.dart:4-10`).
- 반환 타입은 Drift가 생성한 데이터 클래스(`Sentence`, `Word`, `SavedWord` …)와 `*Companion`입니다. API 모델(`WordAnalysis` 등)은 repository가 모르고, 변환은 service + `lib/mapper/` 가 맡습니다.
- 트랜잭션은 repository 안에서 열지 않습니다. 여러 repository를 묶는 트랜잭션은 service가 `database.transaction`으로 엽니다.

### 메서드 이름 규칙

| 접두어 | 의미 | 예 |
|---|---|---|
| `find*` | 조회 (`Future`) | `findById`, `findIdBySentence`, `findAllWords`, `findDueWords` |
| `watch*` | 조회 (`Stream`, DB 변경 시 자동 재발행) | `watchDueCount` |
| `insert*` | 행 추가 | `insert`, `insertIfAbsent` |
| `update*` | 행 수정 | `updateReview` |
| `delete*` | 행 삭제 | `deleteById`, `deleteByWordId` |
| `save` | 저장함(북마크)에 추가, 이미 있으면 `false` | `SavedWordRepository.save` |

- 클래스 이름이 이미 대상을 말하므로 메서드에 엔티티 이름을 반복하지 않습니다 (`SentenceRepository.addSentence` ✗ → `insert`).
- 조건 키가 PK `id`면 `ById`, 그 밖의 컬럼이면 `By<컬럼명>`(`ByWordId`, `BySentenceId`, `BySentence`). **파라미터 이름도 그 컬럼명과 같게** 씁니다.

DB 테이블 관계는 간단히 이렇습니다(자세한 내용은 [table.md](./table.md)).
`sentences`(원문 유니크) ─< `sentence_words`(문장·순서, cascade) >─ `words`, `saved_sentences` → `sentences`, `saved_words` → `words` (SRS 컬럼 포함). `PRAGMA foreign_keys = ON` (`lib/database/database.dart:66`).

---

## 2. Repository별 상세

### 2.1 SentenceRepository — `sentences` 테이블
파일: `lib/repository/sentence_repository.dart` / provider: `sentenceRepositoryProvider` (`lib/provider/sentence_repository_provider.dart:5`)

| 메서드 | 줄 | 하는 일 | 호출하는 곳 |
|---|---|---|---|
| `findIdBySentence(sentence)` | :12 | **원문이 같은** 행의 id, 없으면 null. 원문에 유니크 인덱스가 있어 최대 1행 | `lib/service/vocab_service.dart:42`, `lib/service/sentence_service.dart:60` |
| `findAll()` | :19 | 전체 조회 | **호출하는 곳 없음** |
| `findById(sentenceId)` | :23 | id로 한 건 조회 (`getSingle`, 없으면 예외) | **호출하는 곳 없음** |
| `insert(sentence)` | :29 | insert하고 새 id 반환. 같은 원문이 있으면 유니크 위반 예외 | `lib/service/sentence_service.dart:65` |
| `deleteById(sentenceId)` | :33 | id로 삭제 (매핑은 FK cascade로 함께 지워짐) | `lib/service/sentence_service.dart:23` (그 service 메서드는 테스트에서만 호출) |

### 2.2 WordRepository — `words` 테이블
파일: `lib/repository/word_repository.dart` / provider: `wordRepositoryProvider` (`lib/provider/word_repository_provider.dart:5`)

| 메서드 | 줄 | 하는 일 | 호출하는 곳 |
|---|---|---|---|
| `findById(wordId)` | :12 | 한 건 조회 (`getSingleOrNull`) | **호출하는 곳 없음** |
| `insertIfAbsent(word)` | :18 | `(word, pinyin, translation)`이 같은 행이 있으면 **그 id를 반환**하고, 없으면 insert 후 새 id 반환(get-or-insert). 이 세 컬럼에는 unique 키도 걸려 있습니다 (`lib/database/tables/words_table.dart`) | `lib/service/sentence_service.dart:68`, `lib/service/vocab_service.dart:29` |

### 2.3 SentenceWordRepository — `sentence_words` 매핑 테이블
파일: `lib/repository/sentence_word_repository.dart` / provider: `sentenceWordRepositoryProvider` (`lib/provider/sentence_word_repository_provider.dart:5`)

| 메서드 | 줄 | 하는 일 | 호출하는 곳 |
|---|---|---|---|
| `insert(sentenceWord)` | :12 | 매핑 insert. `position`(문장 안 순서, 0부터)을 함께 넣음 | `lib/service/sentence_service.dart:72` |
| `findWordsBySentenceId(sentenceId)` | :16 | `words`와 inner join, **`position` 오름차순**으로 그 문장의 `Word` 목록 반환. 같은 단어가 두 번 나오면 두 번 들어 있음(我爱我家 → [我, 爱, 我, 家]) | `SentenceService.loadAnalysis` (`lib/service/sentence_service.dart:85`) |
| `deleteBySentenceId(sentenceId)` | :28 | 문장에 딸린 매핑 삭제 | **호출하는 곳 없음** (FK cascade가 같은 일을 함) |

### 2.4 SavedWordRepository — `saved_words` 테이블 (단어장 + SRS 복습)
파일: `lib/repository/saved_word_repository.dart` / provider: `savedWordRepositoryProvider` (`lib/provider/saved_word_repository_provider.dart:5`)

| 메서드 | 줄 | 하는 일 | 호출하는 곳 |
|---|---|---|---|
| `findAllWords()` | :12 | `words` join, `savedAt` 내림차순으로 `List<Word>` 반환 | `SavedWordsNotifier.build` (`lib/provider/saved_words_provider.dart:8`) |
| `findByWordId(wordId)` | :21 | `SavedWord` 한 건 조회 (`getSingle`) | **호출하는 곳 없음** |
| `save(wordId)` | :27 | 이미 있으면 `false`, 없으면 insert하고 `true` 반환 | `lib/service/vocab_service.dart:30` |
| `deleteByWordId(wordId)` | :39 | 단어장에서 제거 (`words` 행은 남음) | `SavedWordsNotifier.remove` (`lib/provider/saved_words_provider.dart:15`) |
| `_dueFilter(now)` | :45 | `nextReviewAt IS NULL OR nextReviewAt <= now` | 아래 두 메서드 내부 |
| `findDueWords(now, {limit = 50})` | :49 | 복습할 단어를 `nextReviewAt` 오름차순으로 조회 | `lib/service/study_service.dart:45` |
| `watchDueCount(now)` | :62 | 복습할 단어 수 `Stream<int>` (Drift `watchSingle`). `now`는 쿼리 파라미터로 고정되므로, 기준일이 바뀌면 새로 구독해야 함([provider.md](./provider.md) `todayProvider`) | `lib/service/study_service.dart:51` |
| `findSrsLevel(wordId)` | :70 | 현재 `srsLevel`, 없으면 0 | `lib/service/study_service.dart` `record` |
| `updateReview(wordId, level, nextReviewAt, reviewedAt)` | :77 | SRS 컬럼 3개 갱신 | `lib/service/study_service.dart` `record` |

### 2.5 SavedSentenceRepository — `saved_sentences` 테이블
파일: `lib/repository/saved_sentence_repository.dart` / provider: `savedSentenceRepositoryProvider` (`lib/provider/saved_sentence_repository_provider.dart:5`)

SavedWordRepository에서 SRS 부분만 뺀 구조와 같습니다.

| 메서드 | 줄 | 하는 일 | 호출하는 곳 |
|---|---|---|---|
| `findAllSentences()` | :12 | `sentences` join, `savedAt` 내림차순 | `SavedSentencesNotifier.build` (`lib/provider/saved_sentences_provider.dart:8`) |
| `findBySentenceId(sentenceId)` | :21 | `SavedSentence` 한 건 (`getSingle`) | **호출하는 곳 없음** |
| `save(sentenceId)` | :27 | 중복이면 `false`, 아니면 insert하고 `true` | `lib/service/vocab_service.dart:47` |
| `deleteBySentenceId(sentenceId)` | :39 | 저장 해제 (`sentences` 행은 남음) | `SavedSentencesNotifier.remove` (`lib/provider/saved_sentences_provider.dart`) |

### 2.6 AnalyzeRepository — `POST /analyze/sentence`
파일: `lib/repository/analyze_repository.dart` / provider: `analyzeRepositoryProvider` (`lib/provider/analyze_repository_provider.dart:5`)

- `analyzeSentence({required sentence})` (:9): body `{'sentence': ...}`를 보내고 응답을 `AnalyzeResult.fromJson`으로 변환합니다.
- 서버가 LLM 출력을 검증하고, 형식 오류·길이 초과면 422 + 한국어 `message`를 돌려줍니다. 화면은 `friendlyErrorMessage`로 그 문구를 그대로 보여 줍니다([model.md](./model.md) 1-3절).
- 호출: `lib/screens/analyze/analyze_home_screen.dart:42-43` (화면에서 직접 호출, service 없음)

### 2.7 SttRepository — `POST /stt/transcribe`
파일: `lib/repository/stt_repository.dart` / provider: `sttRepositoryProvider` (`lib/provider/stt_repository_provider.dart:5`)

- `transcribe({path, duration, target})` (:9): multipart(`durationMs`, `target`, `file`=`speech.m4a`, `audio/mp4`)를 보내고 `PronunciationResult.fromJson`으로 변환합니다. 응답이 null이면 `{}`를 씁니다.
- 호출: `lib/screens/practice/pronunciation_screen.dart:115-117` (화면에서 직접 호출)

---

## 3. Service 계층과의 관계

service는 **여러 repository를 묶고, API 모델을 DB Companion으로 바꾸고(`lib/mapper/word_mapper.dart` 사용), 트랜잭션 경계를 정하는** 곳입니다. 모두 `lib/service/`에 있고 provider는 `lib/provider/*_service_provider.dart`에 있습니다.

| Service | 주입받는 것 | 묶는 방식 |
|---|---|---|
| `SentenceService` (`lib/service/sentence_service.dart`) | `database`, `SentenceRepository`, `WordRepository`, `SentenceWordRepository` (`lib/provider/sentence_service_provider.dart`) | `createSentence`(:51): **get-or-insert**. 트랜잭션 안에서 같은 원문이 있으면 그 id를 돌려주고 아무것도 쓰지 않음. 없으면 문장 `insert` → 단어마다 `insertIfAbsent` → 매핑 `insert(position: 인덱스)`. `loadAnalysis`(:84): 저장된 문장의 단어를 순서대로 읽어 `SentenceAnalysis` 로 복원. `deleteSentence`(:22)는 `deleteById` 위임. `cleanupSearchData`(:26)는 **repository를 거치지 않고** `database`로 직접 쿼리해서, 저장 안 된 문장과 어디에도 안 쓰이는 단어를 삭제 |
| `VocabService` (`lib/service/vocab_service.dart`) | `database`, `WordRepository`, `SavedWordRepository`, `SentenceService`, `SentenceRepository`, `SavedSentenceRepository` (`lib/provider/vocab_service_provider.dart`) | `saveWord`(:27): 트랜잭션 안에서 `insertIfAbsent` 후 `savedWordRepository.save`. `saveSentence`(:40): **전체가 하나의 트랜잭션**. `findIdBySentence`로 원문이 같은 문장을 찾고, 없으면 `createSentence`, 그다음 `savedSentenceRepository.save`. 동시에 여러 번 불려도 문장 1행·저장 1행만 생김. **service가 다른 service를 주입받는** 유일한 경우 |
| `StudyService` (`lib/service/study_service.dart`) | `SavedWordRepository`, `now` 함수(`clockProvider`) (`lib/provider/study_service_provider.dart:6`) | `start`(:44): 지금 기준 "오늘 23:59:59.999"(`_endOfToday`)로 `findDueWords`. `watchDueCount(day)`(:51): **받은 날짜**의 끝을 기준으로 스트림 생성(날짜는 `todayProvider`가 넘김). `record`(:54): `findSrsLevel`로 레벨을 읽고, 순수 함수 `reviewWord`(`lib/service/srs.dart:13`)로 다음 레벨과 날짜를 계산한 뒤 `updateReview` 호출 |
| `TtsService` (`lib/service/tts_service.dart`) | 없음 (`flutter_tts` 직접 생성) | zh-CN 음성 재생. repository와는 무관 |

### "같은 문장"의 기준

**원문(`sentences.sentence`)이 같으면 같은 문장**이고, 처음 저장한 행을 유지합니다.
- LLM은 같은 문장도 분석할 때마다 번역이 조금씩 달라서, `(원문, 병음, 번역)`을 기준으로 하면 단어장에 같은 문장이 번역만 다르게 여러 번 쌓입니다.
- 그래서 다시 분석해 번역·병음이 달라져도 기존 행을 쓰고 새 번역은 버립니다. 저장 버튼에는 "이미 단어장에 있어요"가 뜹니다.
- DB에서도 원문에 유니크 인덱스가 있어 중복 행이 생길 수 없습니다([table.md](./table.md)).

화면에서 데이터에 접근하는 경로:
1. **service를 거침**: 저장(`vocabServiceProvider`), 복습(`studyServiceProvider`), 저장 문장 다시 열기(`sentenceServiceProvider.loadAnalysis`)
2. **AsyncNotifier를 거침**: 저장 목록 조회와 삭제(`savedWordsProvider`, `savedSentencesProvider`, 낙관적 삭제 후 실패하면 롤백). Notifier는 `lib/provider/saved_words_provider.dart`, `saved_sentences_provider.dart` 에 있음
3. **화면에서 API repository 직접 호출**: `analyzeRepositoryProvider`, `sttRepositoryProvider` (호출 한 번 + 모델 변환뿐이라 service를 두지 않음)

---

## 4. 데이터 흐름 예시

### 예시 A: 문장 분석 → 문장/단어 저장
```
AnalyzeHomeScreen._analyze  (lib/screens/analyze/analyze_home_screen.dart:34)
  └ AnalyzeRepository.analyzeSentence → POST /analyze/sentence → AnalyzeResult
     (서버가 LLM 출력을 검증. 이 단계에서는 DB에 아무것도 쓰지 않고 화면 state에만 보관)
  └ 문장 탭 → pushNamed(sentenceDetail, extra: SentenceAnalysis)   (:131)

SentenceDetailScreen
  ├ [문장 저장] _SaveSentenceButton._save   (sentence_detail_screen.dart:198)
  │    저장 중에는 버튼 비활성화(연타 방지)
  │    vocabService.saveSentence(data)  ── 트랜잭션 하나 ──
  │      ├ sentenceRepository.findIdBySentence(원문)   있으면 재사용
  │      ├ (없으면) sentenceService.createSentence(...)
  │      │     sentences insert → words insertIfAbsent → sentence_words insert(position)
  │      └ savedSentenceRepository.save(id)  → true/false
  │    true면 ref.invalidate(savedSentencesProvider)
  │    실패하면 friendlySaveErrorMessage 스낵바 (lib/api/save_error.dart)
  └ [단어 저장] _WordRowState._save          (:235)
       vocabService.saveWord(word)  → 트랜잭션 안에서 insertIfAbsent → savedWordRepository.save
       true면 ref.invalidate(savedWordsProvider), 성공하면 체크 표시
```
단어장 화면에서 저장된 문장을 다시 열 때는 `sentenceService.loadAnalysis(s)` 가 `findWordsBySentenceId` 로 단어를 순서대로 읽고 mapper `toAnalysis()` 로 `SentenceAnalysis`를 다시 조립합니다(`lib/screens/vocab/vocab_screen.dart:224-228`).

### 예시 B: 단어 저장 → 복습(SRS)
```
saved_words 행 생성 (srsLevel=0, nextReviewAt=NULL → 바로 복습 대상)
  ↓
dueCountProvider (StreamProvider)  → studyService.watchDueCount(todayProvider 날짜) → savedWordRepository.watchDueCount
  탭 배지와 화면에서 watch: lib/layout/root_shell.dart:66, lib/screens/study/study_screen.dart:103, lib/screens/analyze/analyze_home_screen.dart:180
  자정이 지나거나 앱이 foreground로 돌아와 날짜가 바뀌면 todayProvider가 바뀌고 스트림을 새 기준으로 다시 구독
  ↓
StudyScreen._start → studyService.start() → findDueWords(오늘 끝)  → StudySession(메모리 큐)   (study_screen.dart:28)
  ↓
StudyScreen._answer → session.answer() (틀리면 큐 뒤로) + studyService.record(word.id, correct)  (:48)
     → findSrsLevel → reviewWord(맞으면 레벨+1, 간격 [0,1,3,7,14,30]일 / 틀리면 0, 지금) → updateReview
  ↓
saved_words가 바뀌면 Drift stream이 dueCount를 자동으로 다시 계산
```

---

## 5. 헷갈리거나 일관되지 않은 부분

### 정리됨 (2026-11-19)
- provider 이름 오타 `workdRepositoryProvider` → `wordRepositoryProvider`
- provider 파일 `sentence_words_repository.provider.dart` → `sentence_word_repository_provider.dart`, 클래스 `SentenceWordsRepository` → `SentenceWordRepository` (파일·클래스 모두 단수)
- 메서드 이름 스타일 두 가지 → 위 1장 규칙 하나로 통일. `Saved*` 의 `findById(id)`/`delete(id)` 처럼 실제로는 FK를 받던 메서드는 `findByWordId`/`deleteByWordId` 등으로 이름에 드러냄
- 파라미터 오타 `senctenceId`, 변수 오타 `pinin` 제거
- Drift `Word` 와 API `Word` 충돌 → API 쪽을 `WordAnalysis` 로 변경
- API repository가 provider 파일 안에 있던 것 → `lib/repository/` 로 이동. `Saved*Notifier` 도 별도 파일로 분리
- provider 타입 표기 혼재 → 전부 `Provider<T>` 명시. provider 본문 의존성은 `ref.watch`
- 화면에서 `sentenceWordsRepository` 직접 호출 + 화면 안 변환 → `SentenceService.loadAnalysis` + mapper 로 이동
- `addWord` 이름과 실제 동작(get-or-insert) 불일치 → `insertIfAbsent`
- `Saved*Repository.insert` (미사용, `save`와 중복) 삭제
- **같은 단어가 두 번 나오는 문장(我爱我家) 저장 실패** → `sentence_words` PK를 `{sentenceId, position}`으로 변경(v5)
- **다시 열 때 단어 순서 보장 없음** → `findWordsBySentenceId`가 `position` 정렬
- **`saveSentence`가 한 트랜잭션이 아니어서 동시 호출 시 같은 문장이 여러 행 생김** → 전체를 트랜잭션으로 감쌈 + 화면 연타 방지
- **`sentences`에 유니크 키 없음 / `findIdByContent`가 중복 행에서 예외** → 원문 유니크 인덱스(v6, 기존 중복은 마이그레이션에서 병합) + `findIdBySentence`
- **저장 실패 시 안내 없음** → 저장 버튼에서 예외를 잡아 `friendlySaveErrorMessage` 스낵바

### 남아 있는 것 (메모만)
- `SentenceService.cleanupSearchData`는 repository를 거치지 않고 `database`에 직접 쿼리함 (여러 테이블을 서브쿼리로 묶는 정리 작업이라 의도적으로 둠)
- `WordRepository.insertIfAbsent`는 id를, `Saved*.save`는 bool(새로 저장했는지)을 반환함. 둘 다 중복 처리를 repository가 하지만 반환값 의미가 다름
- 원문 비교는 완전 일치라서, 공백이나 문장부호만 다른 원문은 다른 문장으로 저장됨
- `SentenceRepository.insert`를 `createSentence`를 거치지 않고 직접 부르면 같은 원문에서 유니크 위반 예외가 남(현재 그런 호출부는 없음)

**안 쓰이는 코드 (lib 기준)**
- `SentenceRepository.findAll`, `findById`
- `WordRepository.findById`
- `SentenceWordRepository.deleteBySentenceId` (FK `onDelete: cascade`와 기능이 겹침)
- `SavedWordRepository.findByWordId` / `SavedSentenceRepository.findBySentenceId`
- `SentenceService.deleteSentence`, `cleanupSearchData`: 테스트에서만 호출. 그래서 단어장에서 삭제하면 `saved_*` 행만 지워지고 `sentences`/`words` 원본은 계속 남음

**동작 메모**
- 저장된 문장을 `deleteSentence`로 직접 지우면 FK(`saved_sentences` → `sentences`, cascade 없음) 때문에 실패함. 테스트가 이 동작을 의도한 것으로 확인함 (`test/vocab_design_test.dart`, "저장된 문장은 FK 보호로 직접 삭제되지 않는다")

---

## 6. 새 repository를 추가할 때 따를 패턴

**로컬 DB repository**
1. 테이블을 `lib/database/tables/<복수형>_table.dart`에 만들고 `@DriftDatabase(tables: [...])`에 등록한 뒤 `schemaVersion`과 `onUpgrade`를 갱신 ([table.md](./table.md) 참고)
2. `lib/repository/<단수형>_repository.dart` 파일을 만듦
   ```dart
   class FooRepository {
     final AppDatabase database;
     late final $FoosTable table;

     FooRepository({required this.database}) {
       table = database.foos;
     }

     // 메서드는 1장 이름 규칙(find/watch/insert/update/delete/save)을 따름
     // Drift 데이터 클래스나 Companion만 다루고, 트랜잭션은 열지 않음
   }
   ```
3. `lib/provider/foo_repository_provider.dart`에 provider만 작성
   ```dart
   final fooRepositoryProvider = Provider<FooRepository>((ref) {
     return FooRepository(database: ref.watch(dbProvider));
   });
   ```
4. 여러 테이블에 쓰거나 "조회 후 없으면 삽입"처럼 여러 단계가 한 덩어리여야 하면 service(`lib/service/`)에 두고 `database.transaction`으로 묶음(중첩 트랜잭션은 바깥에 합류). 변환 코드는 `lib/mapper/` 에. 목록과 삭제처럼 화면 상태가 필요하면 `lib/provider/foos_provider.dart` 에 `AsyncNotifier`를 만들고, 저장한 뒤 `ref.invalidate`로 새로고침
5. 테스트는 `test/vocab_design_test.dart`처럼 메모리 DB(`AppDatabase(NativeDatabase.memory())`)로 repository를 직접 생성해서 service에 주입하는 방식. 동시성은 `test/vocab_concurrency_test.dart`처럼 `Future.wait`로 확인

**서버 API repository**
- `lib/repository/foo_repository.dart` 에 `class FooRepository { final Dio dio; ... }`, provider는 `lib/provider/foo_repository_provider.dart` 에 `Provider<FooRepository>((ref) => FooRepository(dio: ref.watch(dioProvider)))`.
- 메서드는 `dio.post`를 호출하고 `Model.fromJson(res.data)`를 반환하며, 에러는 그대로 던짐(화면에서 `friendlyErrorMessage`로 처리, `analyze_home_screen.dart:48-51`)
