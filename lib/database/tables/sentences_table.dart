import 'package:drift/drift.dart';

/// 같은 문장 = 원문(sentence)이 같은 문장. 처음 저장한 행을 유지하고,
/// 다시 분석해 번역·병음이 달라져도 새 행을 만들지 않는다.
///
/// 유니크 제약은 테이블 제약 대신 유니크 인덱스로 건다. SQLite는 기존 테이블에
/// 제약을 추가할 수 없어 테이블을 다시 만들어야 하는데, sentences는
/// saved_sentences·sentence_words가 FK로 가리키고 있어 재생성 위험이 크다.
/// 인덱스는 CREATE UNIQUE INDEX 한 번으로 붙일 수 있고 중복 방지 효과는 같다.
@TableIndex(
  name: 'sentences_sentence_unique',
  columns: {#sentence},
  unique: true,
)
class Sentences extends Table {
  IntColumn get id => integer().autoIncrement()();

  // 앱 DB는 최후 방어선이다. 서버 검증 상한보다 넉넉하게 잡는다.
  // 원문은 서버 입력 제한(MAX_SENTENCE_LENGTH = 1000)과 맞춘다.
  // (withLength는 Dart 쪽 검사라 SQL 스키마에는 영향이 없다.)
  TextColumn get sentence => text().withLength(min: 1, max: 1000)();
  TextColumn get translation => text().withLength(min: 1, max: 4000)();
  TextColumn get pinyin => text().withLength(min: 1, max: 8000)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
