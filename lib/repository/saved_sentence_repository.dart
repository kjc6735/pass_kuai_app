import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class SavedSentenceRepository {
  final AppDatabase database;
  late final $SavedSentencesTable table;

  SavedSentenceRepository({required this.database}) {
    table = database.savedSentences;
  }

  /// 저장한 문장들을 원본 Sentences와 조인해서 최근 저장순으로 가져온다.
  Future<List<Sentence>> findSavedSentences() {
    final sentences = database.sentences;
    final query =
        database.select(table).join([
          innerJoin(sentences, sentences.id.equalsExp(table.sentenceId)),
        ])..orderBy([OrderingTerm.desc(table.savedAt)]);

    return query.map((row) => row.readTable(sentences)).get();
  }

  Future<SavedSentence> findById(int id) {
    return (database.select(
      table,
    )..where((sentence) => sentence.sentenceId.equals(id))).getSingle();
  }

  Future<int> insert(SavedSentencesCompanion sentence) {
    return database.into(table).insert(sentence);
  }

  /// 문장을 단어장에 저장한다. 이미 있으면 false, 새로 저장하면 true.
  Future<bool> save(int sentenceId) async {
    final existing =
        await (database.select(table)
              ..where((s) => s.sentenceId.equals(sentenceId)))
            .getSingleOrNull();
    if (existing != null) return false;

    await database
        .into(table)
        .insert(SavedSentencesCompanion(sentenceId: Value(sentenceId)));
    return true;
  }

  Future<void> delete(int id) {
    return (database.delete(
      table,
    )..where((sentence) => sentence.sentenceId.equals(id))).go();
  }
}
