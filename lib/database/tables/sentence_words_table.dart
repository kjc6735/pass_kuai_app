import 'package:drift/drift.dart';
import 'package:pass_kuai/database/tables/sentences_table.dart';
import 'package:pass_kuai/database/tables/words_table.dart';

/// 문장을 이루는 단어를 등장 순서대로 담는다.
/// 같은 단어가 한 문장에 여러 번 나올 수 있으므로(我爱我家의 我)
/// 행은 (문장, 순서)로 구분하고 word_id는 겹칠 수 있다.
class SentenceWords extends Table {
  IntColumn get sentenceId =>
      integer().references(Sentences, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId => integer().references(Words, #id)();

  /// 문장 안에서 단어의 위치(0부터).
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {sentenceId, position};
}
