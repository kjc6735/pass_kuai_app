import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';

/// schemaVersion 4 시점의 실제 스키마(drift가 만든 CREATE 문 그대로).
const _v4Schema = [
  'CREATE TABLE "sentences" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "sentence" TEXT NOT NULL, "translation" TEXT NOT NULL, "pinyin" TEXT NOT NULL, "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))',
  'CREATE TABLE "words" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "word" TEXT NOT NULL, "translation" TEXT NOT NULL, "pinyin" TEXT NOT NULL, "pos" TEXT NULL, "syllables" TEXT NOT NULL DEFAULT \'[]\', UNIQUE ("word", "pinyin", "translation"))',
  'CREATE TABLE "sentence_words" ("sentence_id" INTEGER NOT NULL REFERENCES sentences (id) ON DELETE CASCADE, "word_id" INTEGER NOT NULL REFERENCES words (id), PRIMARY KEY ("sentence_id", "word_id"))',
  'CREATE TABLE "saved_words" ("word_id" INTEGER NOT NULL REFERENCES words (id), "saved_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), "srs_level" INTEGER NOT NULL DEFAULT 0, "next_review_at" INTEGER NULL, "last_reviewed_at" INTEGER NULL, PRIMARY KEY ("word_id"))',
  'CREATE TABLE "saved_sentences" ("sentence_id" INTEGER NOT NULL REFERENCES sentences (id), "saved_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), PRIMARY KEY ("sentence_id"))',
];

/// v4 DB에 데이터를 넣어 두고 AppDatabase로 열어 현재 버전으로 올린다.
AppDatabase _openUpgradedFromV4() {
  return AppDatabase(
    NativeDatabase.memory(
      setup: (raw) {
        for (final sql in _v4Schema) {
          raw.execute(sql);
        }
        raw.execute(
          "INSERT INTO sentences (id, sentence, translation, pinyin) VALUES "
          "(1, '你好世界', '안녕 세계', 'nǐ hǎo shì jiè'), "
          "(2, '我们', '우리', 'wǒ men')",
        );
        raw.execute(
          "INSERT INTO words (id, word, translation, pinyin) VALUES "
          "(1, '世界', '세계', 'shì jiè'), "
          "(2, '你', '너', 'nǐ'), "
          "(3, '好', '좋다', 'hǎo'), "
          "(4, '我们', '우리', 'wǒ men')",
        );
        // 문장 1은 word_id가 등장 순서와 다르게(2, 3, 1) 들어가 있다.
        raw.execute(
          'INSERT INTO sentence_words (sentence_id, word_id) VALUES '
          '(1, 2), (2, 4), (1, 3), (1, 1)',
        );
        raw.execute(
          'INSERT INTO saved_words (word_id, srs_level) VALUES (2, 3)',
        );
        raw.execute('INSERT INTO saved_sentences (sentence_id) VALUES (1)');
        raw.userVersion = 4;
      },
    ),
  );
}

/// schemaVersion 5 시점의 실제 스키마(drift가 만든 CREATE 문 그대로).
/// sentences에는 아직 원문 유니크 인덱스가 없다.
const _v5Schema = [
  'CREATE TABLE "sentences" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "sentence" TEXT NOT NULL, "translation" TEXT NOT NULL, "pinyin" TEXT NOT NULL, "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))',
  'CREATE TABLE "words" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "word" TEXT NOT NULL, "translation" TEXT NOT NULL, "pinyin" TEXT NOT NULL, "pos" TEXT NULL, "syllables" TEXT NOT NULL DEFAULT \'[]\', UNIQUE ("word", "pinyin", "translation"))',
  'CREATE TABLE "sentence_words" ("sentence_id" INTEGER NOT NULL REFERENCES sentences (id) ON DELETE CASCADE, "word_id" INTEGER NOT NULL REFERENCES words (id), "position" INTEGER NOT NULL, PRIMARY KEY ("sentence_id", "position"))',
  'CREATE TABLE "saved_words" ("word_id" INTEGER NOT NULL REFERENCES words (id), "saved_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), "srs_level" INTEGER NOT NULL DEFAULT 0, "next_review_at" INTEGER NULL, "last_reviewed_at" INTEGER NULL, PRIMARY KEY ("word_id"))',
  'CREATE TABLE "saved_sentences" ("sentence_id" INTEGER NOT NULL REFERENCES sentences (id), "saved_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), PRIMARY KEY ("sentence_id"))',
];

AppDatabase _openUpgraded(List<String> schema, int version, List<String> seed) {
  return AppDatabase(
    NativeDatabase.memory(
      setup: (raw) {
        for (final sql in [...schema, ...seed]) {
          raw.execute(sql);
        }
        raw.userVersion = version;
      },
    ),
  );
}

Future<List<String>> _schemaOf(AppDatabase db) async {
  final rows = await db
      .customSelect(
        "SELECT sql FROM sqlite_master WHERE sql IS NOT NULL "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .get();
  return rows.map((r) => r.read<String>('sql')).toList();
}

/// (sentence_id, saved_at 초) 목록.
Future<List<(int, int)>> _savedRows(AppDatabase db) async {
  final rows = await db
      .customSelect(
        'SELECT sentence_id, saved_at FROM saved_sentences ORDER BY sentence_id',
      )
      .get();
  return [
    for (final r in rows) (r.read<int>('sentence_id'), r.read<int>('saved_at')),
  ];
}

Future<Map<int, List<int>>> _mappings(AppDatabase db) async {
  final rows =
      await (db.select(db.sentenceWords)..orderBy([
            (t) => OrderingTerm.asc(t.sentenceId),
            (t) => OrderingTerm.asc(t.position),
          ]))
          .get();
  final result = <int, List<int>>{};
  for (final r in rows) {
    result.putIfAbsent(r.sentenceId, () => []).add(r.wordId);
  }
  return result;
}

void main() {
  _v7Tests();
  test('v4 -> v5: 기존 매핑이 보존되고 position이 삽입 순서로 채워진다', () async {
    final db = _openUpgradedFromV4();
    addTearDown(db.close);

    final rows =
        await (db.select(db.sentenceWords)..orderBy([
              (t) => OrderingTerm.asc(t.sentenceId),
              (t) => OrderingTerm.asc(t.position),
            ]))
            .get();
    expect(rows.map((r) => (r.sentenceId, r.position, r.wordId)).toList(), [
      (1, 0, 2),
      (1, 1, 3),
      (1, 2, 1),
      (2, 0, 4),
    ]);

    final words = await SentenceWordRepository(
      database: db,
    ).findWordsBySentenceId(1);
    expect(words.map((w) => w.word), ['你', '好', '世界']);

    // 다른 테이블 데이터도 그대로다.
    expect(await db.select(db.words).get(), hasLength(4));
    expect((await db.select(db.savedWords).getSingle()).srsLevel, 3);
    expect(await db.select(db.savedSentences).get(), hasLength(1));
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 7);
  });

  test('v4 -> 현재: 업그레이드된 스키마가 새로 만든 스키마와 같다', () async {
    final upgraded = _openUpgradedFromV4();
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(upgraded.close);
    addTearDown(fresh.close);

    Future<List<String>> schema(AppDatabase db) async {
      final rows = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE sql IS NOT NULL "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();
      return rows.map((r) => r.read<String>('sql')).toList();
    }

    expect(await schema(upgraded), await schema(fresh));

    final fkCheck = await upgraded
        .customSelect('PRAGMA foreign_key_check')
        .get();
    expect(fkCheck, isEmpty);
  });

  test('v4 -> v5 후: 중복 단어 문장 저장과 cascade 삭제가 동작한다', () async {
    final db = _openUpgradedFromV4();
    addTearDown(db.close);
    final sentenceRepo = SentenceRepository(database: db);
    final sentenceWordRepo = SentenceWordRepository(database: db);
    final service = SentenceService(
      database: db,
      sentenceRepository: sentenceRepo,
      wordRepository: WordRepository(database: db),
      sentenceWordRepository: sentenceWordRepo,
    );

    WordAnalysis w(String text, String pinyin, String meaning) => WordAnalysis(
      text: text,
      pinyin: pinyin,
      meaning: meaning,
      syllables: const [],
    );

    final id = await service.createSentence(
      SentenceAnalysis(
        sentence: '我爱我家',
        translation: '나는 우리 집을 사랑한다',
        words: [
          w('我', 'wǒ', '나'),
          w('爱', 'ài', '사랑하다'),
          w('我', 'wǒ', '나'),
          w('家', 'jiā', '집'),
        ],
      ),
    );
    final words = await sentenceWordRepo.findWordsBySentenceId(id);
    expect(words.map((w) => w.word), ['我', '爱', '我', '家']);

    await service.deleteSentence(2);
    final left = await (db.select(
      db.sentenceWords,
    )..where((t) => t.sentenceId.equals(2))).get();
    expect(left, isEmpty);
  });

  group('v5 -> v6: 원문이 같은 문장 병합 + 유니크 인덱스', () {
    const words =
        "INSERT INTO words (id, word, translation, pinyin) VALUES "
        "(1, '你', '너', 'nǐ'), (2, '好', '좋다', 'hǎo'), "
        "(3, '你好', '안녕', 'nǐ hǎo'), (4, '我们', '우리', 'wǒ men')";
    // 你好: 1(미저장) 2(저장 200) 3(저장 100) -> 2를 남기고 saved_at은 100
    // 再见: 4, 5(둘 다 미저장)            -> 가장 작은 id 4
    // 谢谢: 6(저장 50, 중복 없음)          -> 그대로
    // 我们: 7(저장 300) 8(미저장)          -> 7, saved_at 300
    const sentences =
        "INSERT INTO sentences (id, sentence, translation, pinyin) VALUES "
        "(1, '你好', '안녕(1)', 'nǐ hǎo'), (2, '你好', '안녕(2)', 'nǐ hǎo'), "
        "(3, '你好', '안녕(3)', 'nǐhǎo'), (4, '再见', '잘가(4)', 'zài jiàn'), "
        "(5, '再见', '잘가(5)', 'zàijiàn'), (6, '谢谢', '고마워', 'xiè xie'), "
        "(7, '我们', '우리(7)', 'wǒ men'), (8, '我们', '우리(8)', 'wǒmen')";
    const mappings =
        'INSERT INTO sentence_words (sentence_id, position, word_id) VALUES '
        '(1, 0, 3), (2, 0, 1), (2, 1, 2), (3, 0, 3), (4, 0, 1), (5, 0, 2), '
        '(7, 0, 4), (8, 0, 1)';
    const saved =
        'INSERT INTO saved_sentences (sentence_id, saved_at) VALUES '
        '(2, 200), (3, 100), (6, 50), (7, 300)';
    const savedWord =
        'INSERT INTO saved_words (word_id, srs_level) VALUES (3, 2)';

    AppDatabase open() => _openUpgraded(_v5Schema, 5, [
      words,
      sentences,
      mappings,
      saved,
      savedWord,
    ]);

    test('남길 행 선택, saved_sentences 병합, 매핑 정리가 규칙대로 된다', () async {
      final db = open();
      addTearDown(db.close);

      final rows = await (db.select(
        db.sentences,
      )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
      expect(rows.map((r) => (r.id, r.sentence, r.translation)).toList(), [
        (2, '你好', '안녕(2)'),
        (4, '再见', '잘가(4)'),
        (6, '谢谢', '고마워'),
        (7, '我们', '우리(7)'),
      ]);

      expect(await _savedRows(db), [(2, 100), (6, 50), (7, 300)]);
      expect(await _mappings(db), {
        2: [1, 2],
        4: [1],
        7: [4],
      });

      // 단어와 단어 저장 기록은 건드리지 않는다.
      expect(await db.select(db.words).get(), hasLength(4));
      expect((await db.select(db.savedWords).getSingle()).srsLevel, 2);

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 7);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    });

    test('업그레이드된 스키마가 새로 만든 스키마와 같고 유니크가 동작한다', () async {
      final upgraded = open();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(upgraded.close);
      addTearDown(fresh.close);

      final schema = await _schemaOf(upgraded);
      expect(schema, await _schemaOf(fresh));
      expect(
        schema,
        contains(
          'CREATE UNIQUE INDEX sentences_sentence_unique ON sentences (sentence)',
        ),
      );
      // 길이 상한(withLength)은 SQL에 CHECK로 들어가지 않는다.
      expect(schema.where((sql) => sql.contains('CHECK')), isEmpty);

      await expectLater(
        upgraded.customStatement(
          "INSERT INTO sentences (sentence, translation, pinyin) "
          "VALUES ('你好', 'x', 'y')",
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('중복 없는 v5 DB는 그대로 올라간다', () async {
      final db = _openUpgraded(_v5Schema, 5, [
        words,
        "INSERT INTO sentences (id, sentence, translation, pinyin) VALUES "
            "(1, '你好', '안녕', 'nǐ hǎo'), (2, '我们', '우리', 'wǒ men')",
        'INSERT INTO sentence_words (sentence_id, position, word_id) VALUES '
            '(1, 0, 1), (1, 1, 2), (2, 0, 4)',
        'INSERT INTO saved_sentences (sentence_id, saved_at) VALUES (1, 10)',
      ]);
      addTearDown(db.close);

      expect(await db.select(db.sentences).get(), hasLength(2));
      expect(await _savedRows(db), [(1, 10)]);
      expect(await _mappings(db), {
        1: [1, 2],
        2: [4],
      });
    });
  });

  test('v4 -> v6: position 채우기와 중복 병합이 함께 된다', () async {
    final db = _openUpgraded(_v4Schema, 4, [
      "INSERT INTO words (id, word, translation, pinyin) VALUES "
          "(1, '你好', '안녕', 'nǐ hǎo'), (2, '你', '너', 'nǐ'), "
          "(3, '好', '좋다', 'hǎo')",
      // 1(미저장), 2(저장): 2를 남긴다. 3(미저장), 4(미저장): 3을 남긴다.
      "INSERT INTO sentences (id, sentence, translation, pinyin) VALUES "
          "(1, '你好', '안녕(1)', 'nǐ hǎo'), (2, '你好', '안녕(2)', 'nǐhǎo'), "
          "(3, '好', '좋다(3)', 'hǎo'), (4, '好', '좋다(4)', 'hao')",
      'INSERT INTO sentence_words (sentence_id, word_id) VALUES '
          '(1, 1), (2, 3), (2, 2), (3, 3), (4, 3)',
      'INSERT INTO saved_sentences (sentence_id, saved_at) VALUES (2, 70)',
    ]);
    addTearDown(db.close);

    final rows = await (db.select(
      db.sentences,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    expect(rows.map((r) => (r.id, r.translation)).toList(), [
      (2, '안녕(2)'),
      (3, '좋다(3)'),
    ]);
    expect(await _savedRows(db), [(2, 70)]);
    // 문장 2의 매핑은 v4 삽입 순서(3, 2) 그대로 position 0, 1.
    expect(await _mappings(db), {
      2: [3, 2],
      3: [3],
    });
    final fresh = AppDatabase(NativeDatabase.memory());
    addTearDown(fresh.close);
    expect(await _schemaOf(db), await _schemaOf(fresh));
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
  });
}

/// schemaVersion 6 시점의 스키마 = v5 + 원문 유니크 인덱스.
const _v6Schema = [
  ..._v5Schema,
  'CREATE UNIQUE INDEX sentences_sentence_unique ON sentences (sentence)',
];

void _v7Tests() {
  group('v6 -> v7: 깨진 syllables 정리', () {
    const good = '[{"hanzi":"你","pinyin":"nǐ","tone":3}]';
    final broken = [
      'not json',
      '{"a":1}',
      '[1, 2]',
      '[{"hanzi":1,"pinyin":"x","tone":1}]',
      '',
    ];

    AppDatabase open() => _openUpgraded(_v6Schema, 6, [
      "INSERT INTO words (id, word, translation, pinyin, syllables) VALUES "
          "(1, '你', '너', 'nǐ', '${good.replaceAll("'", "''")}')",
      for (var i = 0; i < broken.length; i++)
        "INSERT INTO words (id, word, translation, pinyin, syllables) VALUES "
            "(${i + 2}, 'w$i', 't$i', 'p$i', '${broken[i].replaceAll("'", "''")}')",
      // 깨진 단어도 단어장·문장에 걸려 있으면 그대로 남아야 한다.
      'INSERT INTO saved_words (word_id) VALUES (2)',
      "INSERT INTO sentences (id, sentence, translation, pinyin) VALUES (1, 'w0你', 't', 'p')",
      'INSERT INTO sentence_words (sentence_id, word_id, position) VALUES (1, 2, 0), (1, 1, 1)',
    ]);

    test('깨진 값만 [] 로 지우고 정상 값·행·참조는 그대로 둔다', () async {
      final db = open();
      addTearDown(db.close);

      final rows = await db
          .customSelect('SELECT id, syllables FROM words ORDER BY id')
          .get();
      final raw = {
        for (final r in rows) r.read<int>('id'): r.read<String>('syllables'),
      };
      expect(raw[1], good);
      for (var id = 2; id <= broken.length + 1; id++) {
        expect(raw[id], '[]', reason: 'word $id');
      }

      // 읽을 때 converter가 실패하지 않는다(debug assert 안 터짐).
      final words = await db.select(db.words).get();
      expect(words, hasLength(broken.length + 1));
      expect(words.firstWhere((w) => w.id == 1).syllables.single.hanzi, '你');

      expect(await db.select(db.savedWords).get(), hasLength(1));
      expect(await db.select(db.sentenceWords).get(), hasLength(2));

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 7);
    });

    test('업그레이드된 스키마가 새로 만든 스키마와 같다', () async {
      final db = open();
      final fresh = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      addTearDown(fresh.close);
      expect(await _schemaOf(db), await _schemaOf(fresh));
    });
  });
}
