class PronunciationResult {
  const PronunciationResult({required this.text, this.comparison});

  final String text;

  final PronunciationComparison? comparison;

  factory PronunciationResult.fromJson(Map<String, dynamic> json) {
    final c = json['comparison'];
    return PronunciationResult(
      text: json['text'] as String? ?? '',
      comparison: c is Map<String, dynamic>
          ? PronunciationComparison.fromJson(c)
          : null,
    );
  }
}

class PronunciationComparison {
  const PronunciationComparison({
    required this.syllables,
    required this.matchRate,
    required this.extraCount,
  });

  final List<SyllableMatch> syllables;

  final double matchRate;

  final int extraCount;

  factory PronunciationComparison.fromJson(Map<String, dynamic> json) {
    return PronunciationComparison(
      syllables: (json['syllables'] as List<dynamic>? ?? [])
          .map((e) => SyllableMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchRate: (json['matchRate'] as num? ?? 0).toDouble(),
      extraCount: (json['extraCount'] as num? ?? 0).toInt(),
    );
  }
}

class SyllableMatch {
  const SyllableMatch({required this.hanzi, required this.pinyin, required this.matched});

  final String hanzi;
  final String pinyin;
  final bool matched;

  factory SyllableMatch.fromJson(Map<String, dynamic> json) => SyllableMatch(
    hanzi: json['hanzi'] as String? ?? '',
    pinyin: json['pinyin'] as String? ?? '',
    matched: json['matched'] as bool? ?? false,
  );
}
