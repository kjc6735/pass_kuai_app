class AnalyzeResult {
  final List<SentenceAnalysis> sentences;

  const AnalyzeResult({required this.sentences});

  factory AnalyzeResult.fromJson(Map<String, dynamic> json) {
    final list = (json['sentences'] as List<dynamic>? ?? [])
        .map((e) => SentenceAnalysis.fromJson(e as Map<String, dynamic>))
        .toList();
    return AnalyzeResult(sentences: list);
  }
}

class SentenceAnalysis {
  final String sentence;
  final String translation;
  final List<WordAnalysis> words;

  const SentenceAnalysis({
    required this.sentence,
    required this.translation,
    required this.words,
  });

  factory SentenceAnalysis.fromJson(Map<String, dynamic> json) {
    final wordList = (json['words'] as List<dynamic>? ?? [])
        .map((e) => WordAnalysis.fromJson(e as Map<String, dynamic>))
        .toList();
    return SentenceAnalysis(
      sentence: json['sentence'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      words: wordList,
    );
  }

  String get pinyin => words.map((w) => w.pinyin).join(' ');
}

class WordAnalysis {
  final String text;
  final String pinyin;
  final String meaning;
  final String? pos;
  final List<Syllable> syllables;

  const WordAnalysis({
    required this.text,
    required this.pinyin,
    required this.meaning,
    this.pos,
    required this.syllables,
  });

  factory WordAnalysis.fromJson(Map<String, dynamic> json) {
    final syl = (json['syllables'] as List<dynamic>? ?? [])
        .map((e) => Syllable.fromJson(e as Map<String, dynamic>))
        .toList();
    return WordAnalysis(
      text: json['text'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      pos: json['pos'] as String?,
      syllables: syl,
    );
  }
}

class Syllable {
  final String hanzi;
  final String pinyin;
  final int tone;

  const Syllable({
    required this.hanzi,
    required this.pinyin,
    required this.tone,
  });

  factory Syllable.fromJson(Map<String, dynamic> json) {
    return Syllable(
      hanzi: json['hanzi'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      tone: (json['tone'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'hanzi': hanzi,
    'pinyin': pinyin,
    'tone': tone,
  };
}
