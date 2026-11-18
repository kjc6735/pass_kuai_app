import 'package:flutter_test/flutter_test.dart';
import 'package:pass_kuai/service/srs.dart';

void main() {
  final evening = DateTime(2026, 11, 17, 22, 30);
  final today = DateTime(2026, 11, 17);

  group('reviewWord', () {
    test('새 단어를 맞히면 1단계, 다음 날 0시에 다시 나온다', () {
      final r = reviewWord(level: 0, correct: true, now: evening);

      expect(r.level, 1);
      expect(r.nextReviewAt, today.add(const Duration(days: 1)));
    });

    test('단계마다 간격이 1·3·7·14·30일로 늘어난다', () {
      final days = <int>[];
      var level = 0;
      for (var i = 0; i < 5; i++) {
        final r = reviewWord(level: level, correct: true, now: evening);
        days.add(r.nextReviewAt.difference(today).inDays);
        level = r.level;
      }

      expect(days, [1, 3, 7, 14, 30]);
    });

    test('5단계에서 또 맞혀도 5단계, 30일 뒤', () {
      final r = reviewWord(level: 5, correct: true, now: evening);

      expect(r.level, 5);
      expect(r.nextReviewAt.difference(today).inDays, 30);
    });

    test('틀리면 몇 단계였든 0단계, 바로 다시 복습 대상', () {
      final r = reviewWord(level: 4, correct: false, now: evening);

      expect(r.level, 0);
      expect(isDue(r.nextReviewAt, evening), isTrue);
    });
  });

  group('isDue', () {
    test('한 번도 안 본 단어(null)는 복습 대상', () {
      expect(isDue(null, evening), isTrue);
    });

    test('다음 복습 시각이 지나지 않았으면 대상이 아니다', () {
      expect(isDue(evening.add(const Duration(minutes: 1)), evening), isFalse);
    });
  });
}
