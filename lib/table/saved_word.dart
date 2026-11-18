import 'package:drift/drift.dart';
import 'package:pass_kuai/table/words_table.dart';

class SavedWords extends Table {
  IntColumn get wordId => integer().references(Words, #id)();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get srsLevel => integer().withDefault(const Constant(0))();

  DateTimeColumn get nextReviewAt => dateTime().nullable()();

  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {wordId};
}
