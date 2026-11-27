import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/provider/saved_sentence_repository_provider.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';
import 'package:pass_kuai/provider/sentence_repository_provider.dart';
import 'package:pass_kuai/provider/sentence_service_provider.dart';
import 'package:pass_kuai/provider/word_repository_provider.dart';
import 'package:pass_kuai/service/vocab_service.dart';

final vocabServiceProvider = Provider<VocabService>((ref) {
  return VocabService(
    database: ref.watch(dbProvider),
    wordRepository: ref.watch(wordRepositoryProvider),
    savedWordRepository: ref.watch(savedWordRepositoryProvider),
    sentenceService: ref.watch(sentenceServiceProvider),
    sentenceRepository: ref.watch(sentenceRepositoryProvider),
    savedSentenceRepository: ref.watch(savedSentenceRepositoryProvider),
  );
});
