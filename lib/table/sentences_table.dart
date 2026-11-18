import 'package:drift/drift.dart';

class Sentences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sentence => text().withLength(min: 1, max: 50)();
  TextColumn get translation => text().withLength(min: 1, max: 100)();
  TextColumn get pinyin => text().withLength(min: 1, max: 200)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
