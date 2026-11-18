import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class SavedWordRepository {
  final AppDatabase database;
  late final $SavedWordsTable table;

  SavedWordRepository({required this.database}) {
    table = database.savedWords;
  }

  /// 저장한 단어들을 원본 Words와 조인해서 최근 저장순으로 가져온다.
  Future<List<Word>> findSavedWords() {
    final words = database.words;
    final query =
        database.select(table).join([
          innerJoin(words, words.id.equalsExp(table.wordId)),
        ])..orderBy([OrderingTerm.desc(table.savedAt)]);

    return query.map((row) => row.readTable(words)).get();
  }

  Future<SavedWord> findById(int id) {
    return (database.select(
      table,
    )..where((savedWord) => savedWord.wordId.equals(id))).getSingle();
  }

  Future<int> insert(SavedWordsCompanion word) {
    return database.into(table).insert(word);
  }

  /// 단어를 단어장에 저장한다. 이미 있으면 false, 새로 저장하면 true.
  Future<bool> save(int wordId) async {
    final existing =
        await (database.select(table)
              ..where((w) => w.wordId.equals(wordId)))
            .getSingleOrNull();
    if (existing != null) return false;

    await database.into(table).insert(SavedWordsCompanion(wordId: Value(wordId)));
    return true;
  }

  Future<void> delete(int id) {
    return (database.delete(
      table,
    )..where((savedWord) => savedWord.wordId.equals(id))).go();
  }
}
