import 'package:drift/drift.dart';

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(min: 1, max: 50)();
  TextColumn get translation => text().withLength(min: 1, max: 100)();
  TextColumn get pinyin => text().withLength(min: 1, max: 200)();

  TextColumn get pos => text().nullable()();

  TextColumn get syllables => text().withDefault(const Constant('[]'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {word, pinyin, translation},
  ];
}
