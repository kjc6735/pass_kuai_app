import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/database/converters/syllables_converter.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/mapper/word_mapper.dart';
import 'package:pass_kuai/model/analyze_result.dart';

void main() {
  late AppDatabase db;
  late List<(String, Object)> decodeErrors;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    decodeErrors = [];
    // 기본 처리기는 debug에서 assert로 터진다. 깨진 값을 일부러 읽는 테스트를 위해 바꿔 끼운다.
    SyllablesConverter.onDecodeError = (raw, error, _) =>
        decodeErrors.add((raw, error));
  });
  tearDown(() async {
    SyllablesConverter.onDecodeError = SyllablesConverter.defaultOnDecodeError;
    await db.close();
  });

  /// converter를 거치지 않고 syllables 원본 문자열을 그대로 넣는다.
  Future<Word> wordWithRawSyllables(String raw) async {
    await db.customStatement(
      'INSERT INTO words (id, word, translation, pinyin, syllables) '
      'VALUES (1, ?, ?, ?, ?)',
      ['你好', '안녕', 'nǐ hǎo', raw],
    );
    return (db.select(db.words)..where((w) => w.id.equals(1))).getSingle();
  }

  test('toCompanion → DB → toAnalysis 왕복에서 음절이 그대로 보존된다', () async {
    const analysis = WordAnalysis(
      text: '你好',
      pinyin: 'nǐ hǎo',
      meaning: '안녕',
      pos: 'interj',
      syllables: [
        Syllable(hanzi: '你', pinyin: 'nǐ', tone: 3),
        Syllable(hanzi: '好', pinyin: 'hǎo', tone: 3),
      ],
    );
    final id = await db.into(db.words).insert(analysis.toCompanion());
    final row = await (db.select(
      db.words,
    )..where((w) => w.id.equals(id))).getSingle();

    expect(row.syllables.map((s) => (s.hanzi, s.pinyin, s.tone)), [
      ('你', 'nǐ', 3),
      ('好', 'hǎo', 3),
    ]);
    final back = row.toAnalysis();
    expect(back.text, '你好');
    expect(back.pos, 'interj');
    expect(back.syllables.map((s) => s.tone), [3, 3]);

    // SQL에는 여전히 JSON TEXT로 들어간다.
    final raw = await db
        .customSelect(
          'SELECT syllables FROM words WHERE id = ?',
          variables: [Variable.withInt(id)],
        )
        .getSingle();
    expect(
      raw.read<String>('syllables'),
      '[{"hanzi":"你","pinyin":"nǐ","tone":3},{"hanzi":"好","pinyin":"hǎo","tone":3}]',
    );
  });

  test('syllables를 안 넣으면 기본값 [] → 빈 리스트, 실패로 치지 않는다', () async {
    await db
        .into(db.words)
        .insert(
          WordsCompanion.insert(word: '你', translation: '너', pinyin: 'nǐ'),
        );
    final row = await db.select(db.words).getSingle();
    expect(row.syllables, isEmpty);
    expect(decodeErrors, isEmpty);
  });

  test('정상 syllables JSON은 그대로 파싱된다', () async {
    final word = await wordWithRawSyllables(
      '[{"hanzi":"你","pinyin":"nǐ","tone":3},{"hanzi":"好","pinyin":"hǎo","tone":3}]',
    );
    expect(word.syllables.map((s) => s.hanzi), ['你', '好']);
    expect(decodeErrors, isEmpty);
  });

  for (final raw in ['not json', '{"a":1}', '[1, 2]', '[{"hanzi":1}]', '']) {
    test('깨진 syllables($raw)는 실패 콜백에 원본과 함께 알리고 빈 리스트', () async {
      final word = await wordWithRawSyllables(raw);
      expect(word.syllables, isEmpty);
      expect(word.toAnalysis().syllables, isEmpty);
      expect(decodeErrors, hasLength(1));
      expect(decodeErrors.single.$1, raw);
    });
  }

  test('기본 처리기는 debug(assert 켜짐)에서 AssertionError로 드러난다', () {
    SyllablesConverter.onDecodeError = SyllablesConverter.defaultOnDecodeError;
    expect(
      () => const SyllablesConverter().fromSql('not json'),
      throwsA(isA<AssertionError>()),
    );
  });
}
