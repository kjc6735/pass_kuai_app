import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pass_kuai/provider/db_provider.dart';
import 'package:pass_kuai/repository/saved_sentence_repository.dart';
import 'package:pass_kuai/table/database.dart';

final savedSentenceRepositoryProvider = Provider<SavedSentenceRepository>((
  ref,
) {
  return SavedSentenceRepository(database: ref.read(dbProvider));
});

class SavedSentencesNotifier extends AsyncNotifier<List<Sentence>> {
  @override
  Future<List<Sentence>> build() {
    return ref.read(savedSentenceRepositoryProvider).findSavedSentences();
  }

  /// 낙관적 삭제: 화면에서 먼저 빼고 백그라운드로 DB 삭제. 실패하면 복구.
  Future<void> remove(int sentenceId) async {
    final previous = state.valueOrNull ?? const [];
    state = AsyncData(previous.where((s) => s.id != sentenceId).toList());
    try {
      await ref.read(savedSentenceRepositoryProvider).delete(sentenceId);
    } catch (_) {
      state = AsyncData(previous); // 복구
      rethrow;
    }
  }
}

/// 저장한 문장 목록 (최근 저장순)
final savedSentencesProvider =
    AsyncNotifierProvider<SavedSentencesNotifier, List<Sentence>>(
      SavedSentencesNotifier.new,
    );
