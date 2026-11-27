import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pass_kuai/database/converters/syllables_converter.dart';
import 'package:pass_kuai/database/tables/saved_sentences_table.dart';
import 'package:pass_kuai/database/tables/saved_words_table.dart';
import 'package:pass_kuai/database/tables/sentence_words_table.dart';
import 'package:pass_kuai/database/tables/sentences_table.dart';
import 'package:pass_kuai/database/tables/words_table.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Sentences, Words, SentenceWords, SavedWords, SavedSentences],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(words, words.syllables);
      }
      if (from < 3) {
        await m.addColumn(words, words.pos);
      }
      if (from < 4) {
        await m.addColumn(savedWords, savedWords.srsLevel);
        await m.addColumn(savedWords, savedWords.nextReviewAt);
        await m.addColumn(savedWords, savedWords.lastReviewedAt);
      }
      if (from < 5) {
        // sentence_words: PK (sentence_id, word_id) -> (sentence_id, position).
        // PK는 addColumn으로 못 바꾸므로 테이블을 새로 만들어 옮긴다.
        // 기존 행의 position은 같은 문장 안에서 들어간 순서(rowid 순)로 0부터 채운다.
        await m.alterTable(
          TableMigration(
            sentenceWords,
            newColumns: [sentenceWords.position],
            columnTransformer: {
              sentenceWords.position: const CustomExpression<int>(
                '(SELECT COUNT(*) FROM "sentence_words" AS "prev" '
                'WHERE "prev"."sentence_id" = "sentence_words"."sentence_id" '
                'AND "prev"."rowid" < "sentence_words"."rowid")',
              ),
            },
          ),
        );
      }
      if (from < 6) {
        // drift는 마이그레이션을 트랜잭션으로 감싸지 않는다. 병합 도중 실패하면
        // 반쯤 지워진 상태가 남지 않도록 병합과 인덱스 생성을 한 트랜잭션으로 묶는다.
        // (실패 시 user_version은 5로 남아 다음 실행 때 처음부터 다시 시도한다.)
        await transaction(() async {
          await _mergeDuplicateSentences();
          await m.createIndex(sentencesSentenceUnique);
        });
      }
      if (from < 7) {
        // 옛 버전에서 깨진 채 저장된 syllables를 지운다(빈 목록으로).
        // 지금은 쓰기가 SyllablesConverter.toSql 하나뿐이라 새로 깨질 일은 없다.
        await transaction(_clearBrokenSyllables);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// v7: 해석할 수 없는 words.syllables 값을 '[]'로 지운다.
  ///
  /// 단어 행 자체는 지우지 않는다. 행을 지우면 그 단어를 가리키는 sentence_words
  /// (저장 문장의 단어 순서)와 saved_words(단어장·복습 기록)까지 지워야 해서
  /// 깨진 건 음절(성조 색칠용 부가 정보)뿐인데 사용자 데이터가 크게 사라진다.
  /// 비운 단어는 성조 색만 빠지고 나머지는 그대로 동작한다.
  Future<void> _clearBrokenSyllables() async {
    final rows = await customSelect(
      'SELECT "id", "syllables" FROM "words"',
    ).get();
    for (final row in rows) {
      final raw = row.read<String>('syllables');
      if (SyllablesConverter.isValid(raw)) continue;
      await customUpdate(
        'UPDATE "words" SET "syllables" = \'[]\' WHERE "id" = ?',
        variables: [Variable.withInt(row.read<int>('id'))],
        updates: {words},
      );
    }
  }

  /// v6: 원문(sentence)이 같은 행을 하나로 합친다. 유니크 인덱스를 걸기 전에 실행한다.
  ///
  /// - 남길 행: 그룹 안에서 saved_sentences에 있는 행 중 가장 작은 id,
  ///   저장된 행이 없으면 그룹에서 가장 작은 id.
  /// - saved_sentences: 지워질 행의 저장 기록은 남길 행으로 합친다. 저장된 행이 하나라도
  ///   있으면 남길 행이 저장된 행이므로 남길 행의 기록만 두고 saved_at을 그룹 최솟값으로 당긴다.
  /// - sentence_words: 지워질 행의 매핑은 버린다(남길 행의 매핑 유지).
  /// - 자식(saved_sentences, sentence_words)을 먼저 지우고 sentences를 지운다.
  ///   saved_sentences -> sentences FK에는 cascade가 없기 때문.
  /// - 매핑을 잃은 words는 지우지 않는다. 저장 안 된 고아 단어는 cleanupSearchData가 정리한다.
  Future<void> _mergeDuplicateSentences() async {
    await customStatement('DROP TABLE IF EXISTS temp."sentence_merge"');
    await customStatement(
      'CREATE TEMP TABLE "sentence_merge" ('
      '"old_id" INTEGER NOT NULL PRIMARY KEY, "keep_id" INTEGER NOT NULL)',
    );
    await customStatement(
      'INSERT INTO "sentence_merge" ("old_id", "keep_id") '
      'SELECT "s"."id", COALESCE('
      '(SELECT MIN("k"."id") FROM "sentences" AS "k" '
      'JOIN "saved_sentences" AS "ks" ON "ks"."sentence_id" = "k"."id" '
      'WHERE "k"."sentence" = "s"."sentence"), '
      '(SELECT MIN("k"."id") FROM "sentences" AS "k" '
      'WHERE "k"."sentence" = "s"."sentence")) '
      'FROM "sentences" AS "s"',
    );
    await customStatement(
      'DELETE FROM "sentence_merge" WHERE "old_id" = "keep_id"',
    );
    await customStatement(
      'UPDATE "saved_sentences" SET "saved_at" = ('
      'SELECT MIN("ss"."saved_at") FROM "saved_sentences" AS "ss" '
      'WHERE "ss"."sentence_id" = "saved_sentences"."sentence_id" '
      'OR "ss"."sentence_id" IN (SELECT "old_id" FROM "sentence_merge" '
      'WHERE "keep_id" = "saved_sentences"."sentence_id")) '
      'WHERE "sentence_id" IN (SELECT "keep_id" FROM "sentence_merge")',
    );
    await customStatement(
      'DELETE FROM "saved_sentences" '
      'WHERE "sentence_id" IN (SELECT "old_id" FROM "sentence_merge")',
    );
    await customStatement(
      'DELETE FROM "sentence_words" '
      'WHERE "sentence_id" IN (SELECT "old_id" FROM "sentence_merge")',
    );
    await customStatement(
      'DELETE FROM "sentences" '
      'WHERE "id" IN (SELECT "old_id" FROM "sentence_merge")',
    );
    await customStatement('DROP TABLE temp."sentence_merge"');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'passKuai',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
