import 'package:drift/drift.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/mapper/word_mapper.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';

class SentenceService {
  final AppDatabase database;
  final SentenceRepository sentenceRepository;
  final WordRepository wordRepository;
  final SentenceWordRepository sentenceWordRepository;

  SentenceService({
    required this.database,
    required this.sentenceRepository,
    required this.wordRepository,
    required this.sentenceWordRepository,
  });

  Future<void> deleteSentence(int sentenceId) {
    return sentenceRepository.deleteById(sentenceId);
  }

  Future<void> cleanupSearchData() async {
    await database.transaction(() async {
      final savedSentenceIds = database.selectOnly(database.savedSentences)
        ..addColumns([database.savedSentences.sentenceId]);

      await (database.delete(
        database.sentences,
      )..where((s) => s.id.isNotInQuery(savedSentenceIds))).go();

      final usedWordIds = database.selectOnly(database.sentenceWords)
        ..addColumns([database.sentenceWords.wordId]);
      final savedWordIds = database.selectOnly(database.savedWords)
        ..addColumns([database.savedWords.wordId]);

      await (database.delete(database.words)..where(
            (w) =>
                w.id.isNotInQuery(usedWordIds) &
                w.id.isNotInQuery(savedWordIds),
          ))
          .go();
    });
  }

  /// get-or-insert: 원문이 같은 문장이 이미 있으면 그 id를 그대로 돌려주고
  /// 아무것도 쓰지 않는다(처음 저장한 번역·병음·단어 매핑 유지).
  Future<int> createSentence(SentenceAnalysis analysis) async {
    final sentencesCompanion = SentencesCompanion(
      sentence: Value(analysis.sentence),
      translation: Value(analysis.translation),
      pinyin: Value(analysis.pinyin),
    );

    final wordCompanions = analysis.words.map((w) => w.toCompanion()).toList();
    return database.transaction(() async {
      final existingId = await sentenceRepository.findIdBySentence(
        analysis.sentence,
      );
      if (existingId != null) return existingId;

      final sentenceId = await sentenceRepository.insert(sentencesCompanion);

      for (var position = 0; position < wordCompanions.length; position++) {
        final wordId = await wordRepository.insertIfAbsent(
          wordCompanions[position],
        );

        await sentenceWordRepository.insert(
          SentenceWordsCompanion(
            sentenceId: Value(sentenceId),
            wordId: Value(wordId),
            position: Value(position),
          ),
        );
      }
      return sentenceId;
    });
  }

  Future<SentenceAnalysis> loadAnalysis(Sentence sentence) async {
    final words = await sentenceWordRepository.findWordsBySentenceId(
      sentence.id,
    );
    return SentenceAnalysis(
      sentence: sentence.sentence,
      translation: sentence.translation,
      words: words.map((w) => w.toAnalysis()).toList(),
    );
  }
}
