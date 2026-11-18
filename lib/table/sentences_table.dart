import 'package:drift/drift.dart';

class Sentences extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get sentence => text().withLength(min: 1, max: 1000)();
  TextColumn get translation => text().withLength(min: 1, max: 4000)();
  TextColumn get pinyin => text().withLength(min: 1, max: 8000)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
