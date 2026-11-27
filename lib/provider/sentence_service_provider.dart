import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/provider/sentence_repository_provider.dart';
import 'package:pass_kuai/provider/sentence_word_repository_provider.dart';
import 'package:pass_kuai/provider/word_repository_provider.dart';
import 'package:pass_kuai/service/sentence_service.dart';

final sentenceServiceProvider = Provider<SentenceService>((ref) {
  return SentenceService(
    database: ref.watch(dbProvider),
    sentenceRepository: ref.watch(sentenceRepositoryProvider),
    wordRepository: ref.watch(wordRepositoryProvider),
    sentenceWordRepository: ref.watch(sentenceWordRepositoryProvider),
  );
});
