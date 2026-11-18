import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:pass_kuai/table/saved_sentence.dart';
import 'package:pass_kuai/table/saved_word.dart';
import 'package:pass_kuai/table/sentence_words_table.dart';
import 'package:pass_kuai/table/sentences_table.dart';
import 'package:pass_kuai/table/words_table.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Sentences, Words, SentenceWords, SavedWords, SavedSentences],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(words, words.syllables);
      }
      if (from < 3) {
        await m.addColumn(words, words.pos);
      }
      if (from < 4) {
        await m.addColumn(savedWords, savedWords.srsLevel);
        await m.addColumn(savedWords, savedWords.nextReviewAt);
        await m.addColumn(savedWords, savedWords.lastReviewedAt);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'passKuai',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
