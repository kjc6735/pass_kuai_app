import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class SentenceRepository {
  final AppDatabase database;
  late final $SentencesTable table;
  SentenceRepository({required this.database}) {
    table = database.sentences;
  }

  Future<int?> findIdByContent(
    String sentence,
    String pinyin,
    String translation,
  ) async {
    final row =
        await (database.select(table)..where(
              (s) =>
                  s.sentence.equals(sentence) &
                  s.pinyin.equals(pinyin) &
                  s.translation.equals(translation),
            ))
            .getSingleOrNull();
    return row?.id;
  }

  Future<List<Sentence>> findSentences() {
    return database.select(table).get();
  }

  Future<Sentence> findSentenceById(int senctenceId) {
    return (database.select(
      table,
    )..where((sentence) => sentence.id.equals(senctenceId))).getSingle();
  }

  Future<int> addSentence(SentencesCompanion sentence) {
    return database.into(table).insert(sentence);
  }

  Future<void> deleteSentence(int sentenceId) {
    return (database.delete(
      table,
    )..where((sentence) => sentence.id.equals(sentenceId))).go();
  }
}
