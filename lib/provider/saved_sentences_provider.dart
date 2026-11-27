import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/provider/saved_sentence_repository_provider.dart';

class SavedSentencesNotifier extends AsyncNotifier<List<Sentence>> {
  @override
  Future<List<Sentence>> build() {
    return ref.watch(savedSentenceRepositoryProvider).findAllSentences();
  }

  Future<void> remove(int sentenceId) async {
    final previous = state.valueOrNull ?? const [];
    state = AsyncData(previous.where((s) => s.id != sentenceId).toList());
    try {
      await ref
          .read(savedSentenceRepositoryProvider)
          .deleteBySentenceId(sentenceId);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final savedSentencesProvider =
    AsyncNotifierProvider<SavedSentencesNotifier, List<Sentence>>(
      SavedSentencesNotifier.new,
    );
