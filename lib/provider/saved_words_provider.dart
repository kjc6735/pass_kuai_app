import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/provider/saved_word_repository_provider.dart';

class SavedWordsNotifier extends AsyncNotifier<List<Word>> {
  @override
  Future<List<Word>> build() {
    return ref.watch(savedWordRepositoryProvider).findAllWords();
  }

  Future<void> remove(int wordId) async {
    final previous = state.valueOrNull ?? const [];
    state = AsyncData(previous.where((w) => w.id != wordId).toList());
    try {
      await ref.read(savedWordRepositoryProvider).deleteByWordId(wordId);
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
