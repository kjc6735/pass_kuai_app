import 'package:drift/drift.dart';
import 'package:pass_kuai/database/database.dart';
import 'package:pass_kuai/model/analyze_result.dart';

// syllables의 JSON 인코딩/디코딩은 SyllablesConverter가 맡는다.
extension WordRowMapper on Word {
  WordAnalysis toAnalysis() => WordAnalysis(
    text: word,
    pinyin: pinyin,
    meaning: translation,
    pos: pos,
    syllables: syllables,
  );
}

extension WordAnalysisMapper on WordAnalysis {
  WordsCompanion toCompanion() => WordsCompanion(
    word: Value(text),
    translation: Value(meaning),
    pinyin: Value(pinyin),
    pos: Value(pos),
    syllables: Value(syllables),
  );
}
