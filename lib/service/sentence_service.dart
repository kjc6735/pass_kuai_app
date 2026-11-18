import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/table/database.dart';

class SentenceService {
  final AppDatabase database;
  final SentenceRepository sentenceRepository;
  final WordRepository wordRepository;
  final SentenceWordsRepository sentenceWordsRepository;
  SentenceService({
    required this.database,
    required this.sentenceRepository,
    required this.wordRepository,
    required this.sentenceWordsRepository,
  });

  /// 검색 문장 하나를 삭제한다. SentenceWords 매핑은 cascade로 함께 사라진다.
  /// (FK가 켜져 있으면, 저장된 문장은 SavedSentences FK에 막혀 삭제되지 않는다.)
  Future<void> deleteSentence(int sentenceId) {
    return sentenceRepository.deleteSentence(sentenceId);
  }

  /// 저장하지 않은 검색 데이터를 정리한다.
  /// 1) SavedSentences에 없는 문장 삭제 → 그 SentenceWords 매핑은 cascade로 함께 삭제
  /// 2) 어떤 매핑에도 안 쓰이고 SavedWords에도 없는 '고아 단어' 삭제
  Future<void> cleanupSearchData() async {
    await database.transaction(() async {
      // 1) 저장 안 된 문장 삭제
      final savedSentenceIds = database.selectOnly(database.savedSentences)
        ..addColumns([database.savedSentences.sentenceId]);

      await (database.delete(database.sentences)
            ..where((s) => s.id.isNotInQuery(savedSentenceIds)))
          .go();

      // 2) 고아 단어 삭제 (남은 매핑에서 안 쓰이고 + 저장도 안 된 것)
      final usedWordIds = database.selectOnly(database.sentenceWords)
        ..addColumns([database.sentenceWords.wordId]);
      final savedWordIds = database.selectOnly(database.savedWords)
        ..addColumns([database.savedWords.wordId]);

      await (database.delete(database.words)
            ..where((w) =>
                w.id.isNotInQuery(usedWordIds) &
                w.id.isNotInQuery(savedWordIds)))
          .go();
    });
  }

  /// 분석 문장을 저장하고(문장 + 단어 + 매핑) 생성된 sentenceId를 반환한다.
  Future<int> addSentence(SentenceAnalysis sentenceAnalysis) async {
    String pinin = sentenceAnalysis.words.map((word) => word.pinyin).join(" ");

    SentencesCompanion sentencesCompanion = SentencesCompanion(
      sentence: Value(sentenceAnalysis.sentence),
      translation: Value(sentenceAnalysis.translation),
      pinyin: Value(pinin),
    );

    List<WordsCompanion> wordCompanions = sentenceAnalysis.words
        .map(
          (word) => WordsCompanion(
            word: Value(word.text),
            translation: Value(word.meaning),
            pinyin: Value(word.pinyin),
            pos: Value(word.pos),
            syllables: Value(
              jsonEncode(word.syllables.map((s) => s.toJson()).toList()),
            ),
          ),
        )
        .toList();
    return database.transaction(() async {
      int sentenceId = await sentenceRepository.addSentence(sentencesCompanion);

      for (final wordCompanion in wordCompanions) {
        int wordId = await wordRepository.addWord(wordCompanion);

        await sentenceWordsRepository.addSentenceWord(
          SentenceWordsCompanion(
            sentenceId: Value(sentenceId),
            wordId: Value(wordId),
          ),
        );
      }
      return sentenceId;
    });
  }
}
