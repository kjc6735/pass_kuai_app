import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pass_kuai/model/analyze_result.dart' as model;
import 'package:pass_kuai/repository/saved_sentence_repository.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';
import 'package:pass_kuai/table/database.dart';

class VocabService {
  final AppDatabase database;
  final WordRepository wordRepository;
  final SavedWordRepository savedWordRepository;
  final SentenceService sentenceService;
  final SentenceRepository sentenceRepository;
  final SavedSentenceRepository savedSentenceRepository;

  VocabService({
    required this.database,
    required this.wordRepository,
    required this.savedWordRepository,
    required this.sentenceService,
    required this.sentenceRepository,
    required this.savedSentenceRepository,
  });

  Future<bool> saveWord(model.Word word) {
    return database.transaction(() async {
      final wordId = await wordRepository.addWord(
        WordsCompanion(
          word: Value(word.text),
          translation: Value(word.meaning),
          pinyin: Value(word.pinyin),
          pos: Value(word.pos),
          syllables: Value(
            jsonEncode(word.syllables.map((s) => s.toJson()).toList()),
          ),
        ),
      );
      return savedWordRepository.save(wordId);
    });
  }

  Future<bool> saveSentence(model.SentenceAnalysis analysis) async {
    final pinyin = analysis.words.map((w) => w.pinyin).join(" ");
    final existingId = await sentenceRepository.findIdByContent(
      analysis.sentence,
      pinyin,
      analysis.translation,
    );
    final sentenceId = existingId ?? await sentenceService.addSentence(analysis);
    return savedSentenceRepository.save(sentenceId);
  }
}
