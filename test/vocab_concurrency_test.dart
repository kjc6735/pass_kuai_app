import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/repository/saved_sentence_repository.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';
import 'package:pass_kuai/service/vocab_service.dart';

void main() {
  late AppDatabase db;
  late SentenceRepository sentenceRepo;
  late VocabService vocab;

  const analysis = SentenceAnalysis(
    sentence: '你好',
    translation: '안녕',
    words: [
      WordAnalysis(text: '你好', pinyin: 'nǐ hǎo', meaning: '안녕', syllables: []),
    ],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sentenceRepo = SentenceRepository(database: db);
    final wordRepo = WordRepository(database: db);
    vocab = VocabService(
      database: db,
      wordRepository: wordRepo,
      savedWordRepository: SavedWordRepository(database: db),
      sentenceService: SentenceService(
        database: db,
        sentenceRepository: sentenceRepo,
        wordRepository: wordRepo,
        sentenceWordRepository: SentenceWordRepository(database: db),
      ),
      sentenceRepository: sentenceRepo,
      savedSentenceRepository: SavedSentenceRepository(database: db),
    );
  });

  tearDown(() async => db.close());

  test('같은 문장을 동시에 저장해도 sentences는 1행, 한 번만 added', () async {
    final results = await Future.wait([
      vocab.saveSentence(analysis),
      vocab.saveSentence(analysis),
      vocab.saveSentence(analysis),
    ]);

    expect(results.where((r) => r).length, 1);
    expect(await db.select(db.sentences).get(), hasLength(1));
    expect(await db.select(db.savedSentences).get(), hasLength(1));
    // 중복 행이 있으면 getSingleOrNull이 던진다.
    expect(await sentenceRepo.findIdBySentence(analysis.sentence), isNotNull);
  });

  test('이미 있는 문장을 동시에 다시 저장해도 예외 없이 false', () async {
    expect(await vocab.saveSentence(analysis), isTrue);
    final results = await Future.wait([
      vocab.saveSentence(analysis),
      vocab.saveSentence(analysis),
    ]);
    expect(results, [false, false]);
    expect(await db.select(db.sentences).get(), hasLength(1));
  });

  test('원문이 같으면 번역·병음이 달라도 같은 문장: 처음 것을 유지하고 false', () async {
    expect(await vocab.saveSentence(analysis), isTrue);
    const reanalyzed = SentenceAnalysis(
      sentence: '你好',
      translation: '안녕하세요',
      words: [
        WordAnalysis(text: '你', pinyin: 'nǐ', meaning: '너', syllables: []),
        WordAnalysis(text: '好', pinyin: 'hǎo', meaning: '좋다', syllables: []),
      ],
    );
    expect(await vocab.saveSentence(reanalyzed), isFalse);

    final row = await db.select(db.sentences).getSingle();
    expect(row.translation, '안녕');
    expect(row.pinyin, 'nǐ hǎo');
    expect(await db.select(db.sentenceWords).get(), hasLength(1));
  });

  test('sentences.sentence 유니크: 같은 원문을 직접 넣으면 DB가 막는다', () async {
    await sentenceRepo.insert(
      SentencesCompanion.insert(sentence: '你好', translation: 'a', pinyin: 'b'),
    );
    await expectLater(
      sentenceRepo.insert(
        SentencesCompanion.insert(
          sentence: '你好',
          translation: 'c',
          pinyin: 'd',
        ),
      ),
      throwsA(isA<SqliteException>()),
    );
  });
}
