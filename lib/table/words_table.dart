import 'package:drift/drift.dart';

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text().withLength(min: 1, max: 50)();
  TextColumn get translation => text().withLength(min: 1, max: 100)();
  TextColumn get pinyin => text().withLength(min: 1, max: 200)();

  // 품사 (동사/명사/형용사 등). 없을 수 있음.
  TextColumn get pos => text().nullable()();

  // 음절·성조 JSON 배열: [{"hanzi","pinyin","tone"}, ...] (성조 색상 복원용)
  TextColumn get syllables => text().withDefault(const Constant('[]'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {word, pinyin, translation},
  ];
}
