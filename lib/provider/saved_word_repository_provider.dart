import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';

final savedWordRepositoryProvider = Provider<SavedWordRepository>((ref) {
  return SavedWordRepository(database: ref.watch(dbProvider));
});
