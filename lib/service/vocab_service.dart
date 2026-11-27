import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/mapper/word_mapper.dart';
import 'package:pass_kuai/model/analyze_result.dart';
import 'package:pass_kuai/repository/saved_sentence_repository.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';
import 'package:pass_kuai/repository/word_repository.dart';
import 'package:pass_kuai/service/sentence_service.dart';

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

  Future<bool> saveWord(WordAnalysis word) {
    return database.transaction(() async {
      final wordId = await wordRepository.insertIfAbsent(word.toCompanion());
      return savedWordRepository.save(wordId);
    });
  }

  /// 조회 → 생성 → 저장을 한 트랜잭션으로 묶는다. drift 트랜잭션은 직렬화되므로
  /// 버튼 연타 등으로 동시에 호출돼도 같은 문장이 sentences에 중복 생성되지 않는다.
  /// (createSentence의 트랜잭션은 이 바깥 트랜잭션에 합류한다.)
  ///
  /// 같은 문장 = 원문이 같은 문장. 다시 분석해 번역·병음이 달라졌어도 원문이 같으면
  /// 처음 저장한 행을 그대로 쓰고 새 번역은 버린다. 이미 저장돼 있으면 false.
  Future<bool> saveSentence(SentenceAnalysis analysis) {
    return database.transaction(() async {
      final existingId = await sentenceRepository.findIdBySentence(
        analysis.sentence,
      );
      final sentenceId =
          existingId ?? await sentenceService.createSentence(analysis);
      return savedSentenceRepository.save(sentenceId);
    });
  }
}
