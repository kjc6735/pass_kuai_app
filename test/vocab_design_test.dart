import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/model/analyze_result.dart' as model;
import 'package:pass_kuai/repository/saved_sentence_repository.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';
import 'package:pass_kuai/service/vocab_service.dart';
import 'package:pass_kuai/table/database.dart';

void main() {
  late AppDatabase db;
  late SentenceRepository sentenceRepo;
  late WordRepository wordRepo;
  late SentenceWordsRepository sentenceWordsRepo;
  late SavedWordRepository savedWordRepo;
  late SavedSentenceRepository savedSentenceRepo;
  late SentenceService sentenceService;
  late VocabService vocab;

  // 분석 결과(model) 헬퍼: words = [[한자, 병음, 뜻], ...]
  model.SentenceAnalysis analysis(
    String sentence,
    String translation,
    List<List<String>> words,
  ) {
    return model.SentenceAnalysis(
      sentence: sentence,
      translation: translation,
      words: [
        for (final w in words)
          model.Word(
            text: w[0],
            pinyin: w[1],
            meaning: w[2],
            syllables: const [],
          ),
      ],
    );
  }

  Future<int> mappingCount(int sentenceId) async {
    final rows = await (db.select(
      db.sentenceWords,
    )..where((t) => t.sentenceId.equals(sentenceId))).get();
    return rows.length;
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sentenceRepo = SentenceRepository(database: db);
    wordRepo = WordRepository(database: db);
    sentenceWordsRepo = SentenceWordsRepository(database: db);
    savedWordRepo = SavedWordRepository(database: db);
    savedSentenceRepo = SavedSentenceRepository(database: db);
    sentenceService = SentenceService(
      database: db,
      sentenceRepository: sentenceRepo,
      wordRepository: wordRepo,
      sentenceWordsRepository: sentenceWordsRepo,
    );
    vocab = VocabService(
      database: db,
      wordRepository: wordRepo,
      savedWordRepository: savedWordRepo,
      sentenceService: sentenceService,
      sentenceRepository: sentenceRepo,
      savedSentenceRepository: savedSentenceRepo,
    );
  });

  tearDown(() async => db.close());

  test('FK가 켜져 있다 (cascade 동작 전제)', () async {
    final row = await db
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(row.data.values.first, 1);
  });

  test('단어 저장: DB에 들어가고 중복은 막힌다', () async {
    final w = model.Word(
      text: '你',
      pinyin: 'nǐ',
      meaning: '너',
      syllables: const [],
    );
    expect(await vocab.saveWord(w), isTrue); // 새로 저장
    expect(await vocab.saveWord(w), isFalse); // 중복 → false

    final saved = await savedWordRepo.findSavedWords();
    expect(saved.length, 1);
    expect(saved.first.word, '你');
    expect(saved.first.translation, '너');
  });

  test('같은 한자 다른 뜻은 별도 단어로 저장된다 (行 xíng / háng)', () async {
    final xing = model.Word(
      text: '行',
      pinyin: 'xíng',
      meaning: '가다',
      syllables: const [],
    );
    final hang = model.Word(
      text: '行',
      pinyin: 'háng',
      meaning: '업종',
      syllables: const [],
    );
    expect(await vocab.saveWord(xing), isTrue);
    expect(await vocab.saveWord(hang), isTrue);

    final saved = await savedWordRepo.findSavedWords();
    expect(saved.length, 2);
  });

  test('문장 저장: 문장+단어+매핑 저장 + 중복 방지', () async {
    final a = analysis('你好', '안녕', [
      ['你', 'nǐ', '너'],
      ['好', 'hǎo', '좋다'],
    ]);
    expect(await vocab.saveSentence(a), isTrue);
    expect(await vocab.saveSentence(a), isFalse); // 같은 문장 재저장 막힘

    final savedSentences = await savedSentenceRepo.findSavedSentences();
    expect(savedSentences.length, 1);
    expect(savedSentences.first.sentence, '你好');

    // 단어 분석(매핑)까지 저장돼 있어야 함
    expect(await mappingCount(savedSentences.first.id), 2);
  });

  test('cleanup: 저장 안 한 검색데이터만 삭제되고 저장본은 살아남는다', () async {
    // 하나는 단어장에 저장, 다른 하나는 검색만(저장 X)
    await vocab.saveSentence(analysis('你好', '안녕', [
      ['你', 'nǐ', '너'],
      ['好', 'hǎo', '좋다'],
    ]));
    await sentenceService.addSentence(analysis('再见', '잘가', [
      ['再', 'zài', '다시'],
      ['见', 'jiàn', '보다'],
    ]));

    await sentenceService.cleanupSearchData();

    // 저장 문장은 남고, 저장 안 한 문장은 삭제
    final sentences = await db.select(db.sentences).get();
    final sentenceTexts = sentences.map((s) => s.sentence).toSet();
    expect(sentenceTexts, contains('你好'));
    expect(sentenceTexts, isNot(contains('再见')));

    // 저장 문장의 단어분석(매핑)도 살아있어야 함
    final savedId = sentences.firstWhere((s) => s.sentence == '你好').id;
    expect(await mappingCount(savedId), 2);

    // 你/好는 저장 문장이 써서 생존, 再/见은 고아라 삭제
    final wordTexts =
        (await db.select(db.words).get()).map((w) => w.word).toSet();
    expect(wordTexts, containsAll(['你', '好']));
    expect(wordTexts, isNot(contains('再')));
    expect(wordTexts, isNot(contains('见')));
  });

  test('개별 저장한 단어는 cleanup에서 보호된다', () async {
    // 문장에 안 쓰인 단어를 단독 저장
    await vocab.saveWord(model.Word(
      text: '謝謝',
      pinyin: 'xièxie',
      meaning: '고마워',
      syllables: const [],
    ));

    await sentenceService.cleanupSearchData();

    final wordTexts =
        (await db.select(db.words).get()).map((w) => w.word).toSet();
    expect(wordTexts, contains('謝謝')); // SavedWords가 보호
  });

  test('cascade: 검색 문장 삭제 시 매핑도 함께 삭제된다', () async {
    final id = await sentenceService.addSentence(analysis('谢谢', '고마워', [
      ['谢', 'xiè', '감사'],
    ]));
    expect(await mappingCount(id), 1);

    await sentenceService.deleteSentence(id);
    expect(await mappingCount(id), 0); // cascade로 사라짐
  });

  test('저장된 문장은 FK 보호로 직접 삭제되지 않는다', () async {
    await vocab.saveSentence(analysis('你好', '안녕', [
      ['你', 'nǐ', '너'],
    ]));
    final saved = (await savedSentenceRepo.findSavedSentences()).first;

    // SavedSentences가 참조 중 → FK 위반 예외
    expect(
      () => sentenceService.deleteSentence(saved.id),
      throwsA(anything),
    );
  });
}
