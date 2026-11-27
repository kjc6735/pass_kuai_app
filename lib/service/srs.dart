library;

const srsMaxLevel = 5;
const srsIntervalDays = [0, 1, 3, 7, 14, 30];

class SrsResult {
  const SrsResult({required this.level, required this.nextReviewAt});

  final int level;
  final DateTime nextReviewAt;
}

SrsResult reviewWord({
  required int level,
  required bool correct,
  required DateTime now,
}) {
  if (!correct) return SrsResult(level: 0, nextReviewAt: now);

  final next = (level + 1).clamp(0, srsMaxLevel);
  final days = srsIntervalDays[next];
  final today = DateTime(now.year, now.month, now.day);
  return SrsResult(
    level: next,
    nextReviewAt: today.add(Duration(days: days)),
  );
}

bool isDue(DateTime? nextReviewAt, DateTime now) =>
    nextReviewAt == null || !nextReviewAt.isAfter(now);
