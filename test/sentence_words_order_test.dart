import 'package:drift/drift.dart' show InvalidDataException;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';

void main() {
  late AppDatabase db;
  late SentenceRepository sentenceRepo;
  late SentenceWordRepository sentenceWordRepo;
  late SentenceService service;

  WordAnalysis w(String text, String pinyin, String meaning) => WordAnalysis(
    text: text,
    pinyin: pinyin,
    meaning: meaning,
    syllables: const [],
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sentenceRepo = SentenceRepository(database: db);
    sentenceWordRepo = SentenceWordRepository(database: db);
    service = SentenceService(
      database: db,
      sentenceRepository: sentenceRepo,
      wordRepository: WordRepository(database: db),
      sentenceWordRepository: sentenceWordRepo,
    );
  });

  tearDown(() async => db.close());

  test('같은 단어가 두 번 나오는 문장도 저장되고, 다시 열면 그대로 복원된다', () async {
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

    // 단어 행은 중복 없이 3개, 매핑은 4개.
    expect(await db.select(db.words).get(), hasLength(3));

    final loaded = await service.loadAnalysis(await sentenceRepo.findById(id));
    expect(loaded.words.map((w) => w.text), ['我', '爱', '我', '家']);
  });

  test('다시 열 때 word id 순서가 아니라 문장 속 순서로 돌려준다', () async {
    // 먼저 저장된 문장 때문에 뒤쪽 단어의 id가 더 작아지게 만든다.
    await service.createSentence(
      SentenceAnalysis(
        sentence: '世界',
        translation: '세계',
        words: [w('世界', 'shì jiè', '세계')],
      ),
    );
    final id = await service.createSentence(
      SentenceAnalysis(
        sentence: '你好世界',
        translation: '안녕 세계',
        words: [
          w('你', 'nǐ', '너'),
          w('好', 'hǎo', '좋다'),
          w('世界', 'shì jiè', '세계'),
        ],
      ),
    );

    final words = await sentenceWordRepo.findWordsBySentenceId(id);
    expect(words.map((w) => w.word), ['你', '好', '世界']);
  });

  test('길이 상한 이내의 긴 LLM 응답은 저장된다', () async {
    final id = await service.createSentence(
      SentenceAnalysis(
        sentence: '长',
        translation: '가' * 4000,
        words: [w('长' * 50, 'c' * 200, '길' * 200)],
      ),
    );
    final words = await sentenceWordRepo.findWordsBySentenceId(id);
    expect(words.single.word.length, 50);
    expect((await sentenceRepo.findById(id)).translation.length, 4000);
  });

  for (final (label, analysis) in [
    (
      '문장 번역 4001자',
      SentenceAnalysis(
        sentence: '长',
        translation: '가' * 4001,
        words: [w('长', 'cháng', '길다')],
      ),
    ),
    (
      '단어 51자',
      SentenceAnalysis(
        sentence: '长',
        translation: '길다',
        words: [w('长' * 51, 'cháng', '길다')],
      ),
    ),
    (
      '단어 뜻 201자',
      SentenceAnalysis(
        sentence: '长',
        translation: '길다',
        words: [w('长', 'cháng', '길' * 201)],
      ),
    ),
    (
      '단어 병음 201자',
      SentenceAnalysis(
        sentence: '长',
        translation: '길다',
        words: [w('长', 'c' * 201, '길다')],
      ),
    ),
  ]) {
    test('길이 상한 초과($label)는 저장이 통째로 실패한다', () async {
      await expectLater(
        service.createSentence(analysis),
        throwsA(isA<InvalidDataException>()),
      );
      // 트랜잭션이라 문장·매핑이 반쯤 남지 않는다.
      expect(await db.select(db.sentences).get(), isEmpty);
      expect(await db.select(db.sentenceWords).get(), isEmpty);
    });
  }

  test('원문이 같은 문장은 createSentence가 기존 id를 돌려주고 아무것도 쓰지 않는다', () async {
    final id = await service.createSentence(
      SentenceAnalysis(
        sentence: '你好',
        translation: '안녕',
        words: [w('你好', 'nǐ hǎo', '안녕')],
      ),
    );
    final again = await service.createSentence(
      SentenceAnalysis(
        sentence: '你好',
        translation: '안녕하세요',
        words: [w('你', 'nǐ', '너'), w('好', 'hǎo', '좋다')],
      ),
    );
    expect(again, id);
    expect((await sentenceRepo.findById(id)).translation, '안녕');
    final words = await sentenceWordRepo.findWordsBySentenceId(id);
    expect(words.map((w) => w.word), ['你好']);
    expect(await db.select(db.words).get(), hasLength(1));
  });

  test('중복 단어가 있는 문장을 지운 뒤 정리하면 단어도 지워진다', () async {
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
    await service.deleteSentence(id);
    expect(await db.select(db.sentenceWords).get(), isEmpty);

    await service.cleanupSearchData();
    expect(await db.select(db.words).get(), isEmpty);
  });
}
