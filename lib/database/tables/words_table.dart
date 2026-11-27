import 'package:drift/drift.dart';
import 'package:pass_kuai/database/converters/syllables_converter.dart';

class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 앱 DB는 최후 방어선이다. 서버 검증 상한보다 넉넉하게 잡아, 정상 응답은 통과시키고
  // 비정상적으로 긴 값만 막는다. (withLength는 Dart 쪽 검사라 SQL 스키마에는 영향이 없다.)
  TextColumn get word => text().withLength(min: 1, max: 50)();
  TextColumn get translation => text().withLength(min: 1, max: 200)();
  TextColumn get pinyin => text().withLength(min: 1, max: 200)();

  TextColumn get pos => text().nullable()();

  /// SQL에서는 JSON TEXT, Dart에서는 `List<Syllable>`.
  TextColumn get syllables => text()
      .map(const SyllablesConverter())
      .withDefault(const Constant('[]'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {word, pinyin, translation},
  ];
}
