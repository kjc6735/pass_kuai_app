import 'package:drift/drift.dart';
import 'package:pass_kuai/table/database.dart';

class SavedWordRepository {
  final AppDatabase database;
  late final $SavedWordsTable table;

  SavedWordRepository({required this.database}) {
    table = database.savedWords;
  }

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

  Expression<bool> _dueFilter(DateTime now) =>
      table.nextReviewAt.isNull() | table.nextReviewAt.isSmallerOrEqualValue(now);

  Future<List<Word>> findDueWords(DateTime now, {int limit = 50}) {
    final words = database.words;
    final query =
        database.select(table).join([
            innerJoin(words, words.id.equalsExp(table.wordId)),
          ])
          ..where(_dueFilter(now))
          ..orderBy([OrderingTerm.asc(table.nextReviewAt)])
          ..limit(limit);

    return query.map((row) => row.readTable(words)).get();
  }

  Stream<int> watchDueCount(DateTime now) {
    final count = table.wordId.count();
    final query = database.selectOnly(table)
      ..addColumns([count])
      ..where(_dueFilter(now));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<int> findLevel(int wordId) async {
    final row =
        await (database.select(table)..where((w) => w.wordId.equals(wordId)))
            .getSingleOrNull();
    return row?.srsLevel ?? 0;
  }

  Future<void> updateReview(
    int wordId, {
    required int level,
    required DateTime nextReviewAt,
    required DateTime reviewedAt,
  }) {
    return (database.update(table)..where((w) => w.wordId.equals(wordId))).write(
      SavedWordsCompanion(
        srsLevel: Value(level),
        nextReviewAt: Value(nextReviewAt),
        lastReviewedAt: Value(reviewedAt),
      ),
    );
  }
}
