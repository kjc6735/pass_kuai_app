import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/table/database.dart';

final savedWordRepositoryProvider = Provider<SavedWordRepository>((ref) {
  return SavedWordRepository(database: ref.read(dbProvider));
});

class SavedWordsNotifier extends AsyncNotifier<List<Word>> {
  @override
  Future<List<Word>> build() {
    return ref.read(savedWordRepositoryProvider).findSavedWords();
  }

  Future<void> remove(int wordId) async {
    final previous = state.valueOrNull ?? const [];
    state = AsyncData(previous.where((w) => w.id != wordId).toList());
    try {
      await ref.read(savedWordRepositoryProvider).delete(wordId);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final savedWordsProvider =
    AsyncNotifierProvider<SavedWordsNotifier, List<Word>>(
      SavedWordsNotifier.new,
    );
