import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/word_repository.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(database: ref.watch(dbProvider));
});
