import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class SavedSentenceRepository {
  final AppDatabase database;
  late final $SavedSentencesTable table;

  SavedSentenceRepository({required this.database}) {
    table = database.savedSentences;
  }

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
