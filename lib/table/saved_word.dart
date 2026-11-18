import 'package:drift/drift.dart';
import 'package:pass_kuai/table/words_table.dart';

class SavedWords extends Table {
  IntColumn get wordId => integer().references(Words, #id)();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {wordId};
}
