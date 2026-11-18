import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/sentence_word_repository.dart';

final sentenceWordsRepositoryProvider = Provider((ref) {
  return SentenceWordsRepository(database: ref.read(dbProvider));
});
