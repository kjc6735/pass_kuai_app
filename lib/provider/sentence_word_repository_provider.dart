import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';

final sentenceWordRepositoryProvider = Provider<SentenceWordRepository>((ref) {
  return SentenceWordRepository(database: ref.watch(dbProvider));
});
