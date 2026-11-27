import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/service/srs.dart';

class StudySession {
  StudySession(List<Word> words)
    : _queue = List.of(words),
      total = words.length;

  final List<Word> _queue;
  final int total;
  int _finished = 0;

  Word? get current => _queue.isEmpty ? null : _queue.first;
  bool get isDone => _queue.isEmpty;
  int get finished => _finished;

  void answer({required bool correct}) {
    if (_queue.isEmpty) return;
    final word = _queue.removeAt(0);
    if (correct) {
      _finished++;
    } else {
      _queue.add(word);
    }
  }
}

class StudyService {
  StudyService({required this.savedWordRepository, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SavedWordRepository savedWordRepository;
  final DateTime Function() _now;

  static DateTime _endOfDay(DateTime day) => DateTime(
    day.year,
    day.month,
    day.day + 1,
  ).subtract(const Duration(milliseconds: 1));

  DateTime _endOfToday() => _endOfDay(_now());

  Future<StudySession> start() async {
    final words = await savedWordRepository.findDueWords(_endOfToday());
    return StudySession(words);
  }

  /// [day]가 끝날 때까지 복습할 때가 된 단어 수. 기준 시각은 구독 시점에 고정되므로
  /// 날짜가 바뀌면 새 [day]로 다시 구독해야 한다(drift watch는 테이블이 바뀔 때만 다시 실행됨).
  Stream<int> watchDueCount(DateTime day) =>
      savedWordRepository.watchDueCount(_endOfDay(day));

  Future<void> record(int wordId, {required bool correct}) async {
    final now = _now();
    final level = await savedWordRepository.findSrsLevel(wordId);
    final result = reviewWord(level: level, correct: correct, now: now);
    await savedWordRepository.updateReview(
      wordId,
      level: result.level,
      nextReviewAt: result.nextReviewAt,
      reviewedAt: now,
    );
  }
}
