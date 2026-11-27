import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/saved_sentence_repository.dart';

final savedSentenceRepositoryProvider = Provider<SavedSentenceRepository>((
  ref,
) {
  return SavedSentenceRepository(database: ref.watch(dbProvider));
});
