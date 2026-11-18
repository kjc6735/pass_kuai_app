import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class SentenceWordsRepository {
  final AppDatabase database;
  late final $SentenceWordsTable table;
  SentenceWordsRepository({required this.database}) {
    table = database.sentenceWords;
  }

  Future<int> addSentenceWord(SentenceWordsCompanion word) {
    return database.into(table).insert(word);
  }

  Future<List<Word>> findWordsBySentence(int sentenceId) {
    final words = database.words;
    final query =
        database.select(table).join([
          innerJoin(words, words.id.equalsExp(table.wordId)),
        ])..where(table.sentenceId.equals(sentenceId));

    return query.map((row) => row.readTable(words)).get();
  }

  Future<void> deleteBySentenceId(int sentenceId) {
    return (database.delete(
      table,
    )..where((word) => word.sentenceId.equals(sentenceId))).go();
  }
}
