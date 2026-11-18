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

  /// 낙관적 삭제: 화면에서 먼저 빼고 백그라운드로 DB 삭제. 실패하면 복구.
  Future<void> remove(int wordId) async {
    final previous = state.valueOrNull ?? const [];
    state = AsyncData(previous.where((w) => w.id != wordId).toList());
    try {
      await ref.read(savedWordRepositoryProvider).delete(wordId);
    } catch (_) {
      state = AsyncData(previous); // 복구
      rethrow;
    }
  }
}

/// 저장한 단어 목록 (최근 저장순)
final savedWordsProvider =
    AsyncNotifierProvider<SavedWordsNotifier, List<Word>>(
      SavedWordsNotifier.new,
    );
