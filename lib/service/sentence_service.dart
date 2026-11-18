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

  Future<void> deleteSentence(int sentenceId) {
    return sentenceRepository.deleteSentence(sentenceId);
  }

  Future<void> cleanupSearchData() async {
    await database.transaction(() async {
      final savedSentenceIds = database.selectOnly(database.savedSentences)
        ..addColumns([database.savedSentences.sentenceId]);

      await (database.delete(database.sentences)
            ..where((s) => s.id.isNotInQuery(savedSentenceIds)))
          .go();

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
