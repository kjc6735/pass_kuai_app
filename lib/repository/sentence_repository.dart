import 'package:pass_kuai/database/database.dart';

class SentenceRepository {
  final AppDatabase database;
  late final $SentencesTable table;

  SentenceRepository({required this.database}) {
    table = database.sentences;
  }

  /// 같은 문장 = 원문이 같은 문장(sentences.sentence 유니크).
  Future<int?> findIdBySentence(String sentence) async {
    final row = await (database.select(
      table,
    )..where((s) => s.sentence.equals(sentence))).getSingleOrNull();
    return row?.id;
  }

  Future<List<Sentence>> findAll() {
    return database.select(table).get();
  }

  Future<Sentence> findById(int sentenceId) {
    return (database.select(
      table,
    )..where((sentence) => sentence.id.equals(sentenceId))).getSingle();
  }

  Future<int> insert(SentencesCompanion sentence) {
    return database.into(table).insert(sentence);
  }

  Future<void> deleteById(int sentenceId) {
    return (database.delete(
      table,
    )..where((sentence) => sentence.id.equals(sentenceId))).go();
  }
}
