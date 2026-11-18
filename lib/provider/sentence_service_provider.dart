import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/provider/sentence_repository_provider.dart';
import 'package:pass_kuai/provider/sentence_words_repository.provider.dart';
import 'package:pass_kuai/provider/word_repository_provider.dart';
import 'package:pass_kuai/service/sentence_service.dart';

final sentenceServiceProvider = Provider<SentenceService>((ref) {
  return SentenceService(
    database: ref.read(dbProvider),
    sentenceRepository: ref.read(sentenceRepositoryProvider),
    wordRepository: ref.read(workdRepositoryProvider),
    sentenceWordsRepository: ref.read(sentenceWordsRepositoryProvider),
  );
});
