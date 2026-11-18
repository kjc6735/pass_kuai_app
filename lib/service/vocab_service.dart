import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pass_kuai/model/analyze_result.dart' as model;
import 'package:pass_kuai/repository/saved_sentence_repository.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';
import 'package:pass_kuai/table/database.dart';

/// 분석 화면에서 단어/문장을 단어장(저장)에 넣는 로직.
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

  /// 단어 하나를 단어장에 저장한다.
  /// Words에 (있으면 재사용) 넣은 뒤 SavedWords에 북마크.
  /// 이미 저장돼 있으면 false.
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

  /// 문장 하나를 단어장에 저장한다.
  /// 같은 문장이 이미 있으면 그 id를 재사용하고, 없으면 문장+단어+매핑을 새로 저장한 뒤
  /// SavedSentences에 북마크. 이미 저장돼 있으면 false.
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
