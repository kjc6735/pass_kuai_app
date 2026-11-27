import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/sentence_repository.dart';

final sentenceRepositoryProvider = Provider<SentenceRepository>((ref) {
  return SentenceRepository(database: ref.watch(dbProvider));
});
