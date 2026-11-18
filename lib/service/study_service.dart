import 'package:pass_kuai/repository/saved_word_repository.dart';
import 'package:pass_kuai/service/srs.dart';
import 'package:pass_kuai/table/database.dart';

class StudySession {
  StudySession(List<Word> words) : _queue = List.of(words), total = words.length;

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

  DateTime _endOfToday() {
    final now = _now();
    return DateTime(now.year, now.month, now.day + 1)
        .subtract(const Duration(milliseconds: 1));
  }

  Future<StudySession> start() async {
    final words = await savedWordRepository.findDueWords(_endOfToday());
    return StudySession(words);
  }

  Stream<int> watchDueCount() =>
      savedWordRepository.watchDueCount(_endOfToday());

  Future<void> record(int wordId, {required bool correct}) async {
    final now = _now();
    final level = await savedWordRepository.findLevel(wordId);
    final result = reviewWord(level: level, correct: correct, now: now);
    await savedWordRepository.updateReview(
      wordId,
      level: result.level,
      nextReviewAt: result.nextReviewAt,
      reviewedAt: now,
    );
  }
}
