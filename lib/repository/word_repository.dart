import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class WordRepository {
  final AppDatabase database;
  late final $WordsTable table;
  WordRepository({required this.database}) {
    table = database.words;
  }

  Future<Word?> findById(int id) {
    return (database.select(
      table,
    )..where((word) => word.id.equals(id))).getSingleOrNull();
  }

  /// 같은 (단어 + 병음 + 뜻)이 이미 있으면 그 id를 재사용하고,
  /// 없으면 새로 넣은 뒤 id를 반환한다. (unique 위반 예외 방지 + 단어 재사용)
  Future<int> addWord(WordsCompanion word) async {
    final existing =
        await (database.select(table)..where(
              (w) =>
                  w.word.equals(word.word.value) &
                  w.pinyin.equals(word.pinyin.value) &
                  w.translation.equals(word.translation.value),
            ))
            .getSingleOrNull();

    if (existing != null) return existing.id;

    return database.into(table).insert(word);
  }
}
