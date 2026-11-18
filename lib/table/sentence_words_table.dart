import 'package:drift/drift.dart';
import 'package:pass_kuai/table/sentences_table.dart';
import 'package:pass_kuai/table/words_table.dart';

class SentenceWords extends Table {
  IntColumn get sentenceId =>
      integer().references(Sentences, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId => integer().references(Words, #id)();

  @override
  Set<Column> get primaryKey => {sentenceId, wordId};
}
