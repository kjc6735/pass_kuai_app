import 'package:drift/drift.dart';
import 'package:pass_kuai/database/database.dart';

class SentenceWordRepository {
  final AppDatabase database;
  late final $SentenceWordsTable table;

  SentenceWordRepository({required this.database}) {
    table = database.sentenceWords;
  }

  Future<int> insert(SentenceWordsCompanion sentenceWord) {
    return database.into(table).insert(sentenceWord);
  }

  Future<List<Word>> findWordsBySentenceId(int sentenceId) {
    final words = database.words;
    final query =
        database.select(table).join([
            innerJoin(words, words.id.equalsExp(table.wordId)),
          ])
          ..where(table.sentenceId.equals(sentenceId))
          ..orderBy([OrderingTerm.asc(table.position)]);

    return query.map((row) => row.readTable(words)).get();
  }

  Future<void> deleteBySentenceId(int sentenceId) {
    return (database.delete(
      table,
    )..where((word) => word.sentenceId.equals(sentenceId))).go();
  }
}
