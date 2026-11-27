import 'package:drift/drift.dart';
import 'package:pass_kuai/database/database.dart';

class WordRepository {
  final AppDatabase database;
  late final $WordsTable table;

  WordRepository({required this.database}) {
    table = database.words;
  }

  Future<Word?> findById(int wordId) {
    return (database.select(
      table,
    )..where((word) => word.id.equals(wordId))).getSingleOrNull();
  }

  Future<int> insertIfAbsent(WordsCompanion word) async {
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
