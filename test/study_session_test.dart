import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/service/study_service.dart';
import 'package:pass_kuai/database/database.dart';

Word _word(int id, String text) => Word(
  id: id,
  word: text,
  translation: '뜻',
  pinyin: 'p',
  syllables: const [],
);

void main() {
  test('맞힌 카드는 빠지고, 틀린 카드는 맨 뒤로 가서 다시 나온다', () {
    final session = StudySession([_word(1, '你'), _word(2, '好')]);

    session.answer(correct: false);
    expect(session.current!.word, '好');

    session.answer(correct: true);
    expect(session.current!.word, '你');

    session.answer(correct: true);
    expect(session.isDone, isTrue);
    expect(session.finished, 2);
    expect(session.total, 2);
  });
}
