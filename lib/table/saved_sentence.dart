import 'package:drift/drift.dart';
import 'package:pass_kuai/table/sentences_table.dart';

class SavedSentences extends Table {
  IntColumn get sentenceId => integer().references(Sentences, #id)();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {sentenceId};
}
